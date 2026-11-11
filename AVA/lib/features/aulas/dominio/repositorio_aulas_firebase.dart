import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constantes/paleta.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/modelos/recurso_visual.dart';
import '../../../core/servicios/base_datos.dart';
import 'ficha_aula.dart';
import 'repositorio_aulas.dart';

/// Aulas en Cloud Firestore (`aulas/{id}`).
///
/// Además de `nombre` y `tutorResponsable`, guarda `color` y `pictograma`
/// para que cada clase se reconozca en la tableta. Si un aula aún no los
/// tiene, se le asignan por orden.
class RepositorioAulasFirebase implements RepositorioAulas {
  RepositorioAulasFirebase({BaseDatos? baseDatos, FirebaseFirestore? firestore})
    : _bd = baseDatos ?? BaseDatos(),
      _db = firestore ?? FirebaseFirestore.instance;

  static const _pictogramasPorDefecto = [
    Pictogramas.sol,
    Pictogramas.flor,
    Pictogramas.mariposa,
    Pictogramas.musica,
    Pictogramas.pelota,
    Pictogramas.casa,
  ];

  final BaseDatos _bd;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _aulas =>
      _db.collection('aulas');

  static Aula _desde(String id, Map<String, dynamic> d, int indice) {
    final tutor = d['tutorResponsable'] as String?;
    return Aula(
      id: id,
      nombre: d['nombre'] as String? ?? '',
      color: d['color'] == null
          ? ColorPastel.paraIndice(indice)
          : ColorPastel.porNombre(d['color'] as String?),
      pictograma:
          RecursoVisual.desdeUrl(d['pictograma'] as String?) ??
          _pictogramasPorDefecto[indice % _pictogramasPorDefecto.length],
      idTutor: tutor == null || tutor.isEmpty ? null : tutor,
    );
  }

  @override
  Future<List<Aula>> obtenerAulas() async {
    final resultado = await _aulas.orderBy('nombre').get();
    return [
      for (final (i, doc) in resultado.docs.indexed)
        _desde(doc.id, doc.data(), i),
    ];
  }

  @override
  Future<Aula?> obtener(String id) async {
    final aulas = await obtenerAulas();
    return aulas.where((a) => a.id == id).firstOrNull;
  }

  @override
  Future<void> guardar(Aula aula) async {
    final ref = _aulas.doc(aula.id);
    final existe = (await ref.get()).exists;
    await ref.set({
      'nombre': aula.nombre,
      'tutorResponsable': aula.idTutor ?? '',
      'color': aula.color.name,
      'pictograma': aula.pictograma?.url,
      if (!existe) 'creadoEn': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Los alumnos del aula pasan a tener como tutor al responsable, para
    // que pueda verlos y gestionarlos (HU-16, HU-17).
    final tutor = aula.idTutor;
    if (tutor == null) return;
    final alumnos = await _db
        .collection('estudiantes')
        .where('aulaId', isEqualTo: aula.id)
        .get();
    for (final alumno in alumnos.docs) {
      await _bd.asignarTutor(alumno.id, tutor);
    }
  }

  @override
  String nuevoId() => _bd.nuevoId('aulas');
}
