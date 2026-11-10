import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constantes/paleta.dart';
import '../../../core/modelos/recurso_visual.dart';
import '../../../core/servicios/almacenamiento.dart';
import '../../../core/servicios/autenticacion.dart';
import '../../../core/servicios/base_datos.dart';
import '../../../core/utilidades/orden_alfabetico.dart';
import 'conversion_firestore.dart';
import 'perfil_estudiante.dart';
import 'repositorio_estudiantes.dart';

/// Perfiles de los estudiantes en Cloud Firestore.
///
/// Lee los documentos completos para conservar los campos propios de la
/// interfaz (ver [ConversionFirestore]) y escribe con `BaseDatos` siempre
/// que el servicio tiene el método correspondiente.
class RepositorioEstudiantesFirebase implements RepositorioEstudiantes {
  RepositorioEstudiantesFirebase({
    BaseDatos? baseDatos,
    Autenticacion? autenticacion,
    Almacenamiento? almacenamiento,
    FirebaseFirestore? firestore,
  }) : _bd = baseDatos ?? BaseDatos(),
       _auth = autenticacion ?? Autenticacion(),
       _almacenamiento = almacenamiento ?? Almacenamiento(),
       _db = firestore ?? FirebaseFirestore.instance;

  final BaseDatos _bd;
  final Autenticacion _auth;
  final Almacenamiento _almacenamiento;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _estudiantes =>
      _db.collection('estudiantes');

  @override
  Future<Estudiante?> obtener(String id) async {
    final doc = await _estudiantes.doc(id).get();
    final datos = doc.data();
    return datos == null
        ? null
        : ConversionFirestore.estudianteDesde(doc.id, datos);
  }

  @override
  Future<List<Estudiante>> listar({String? idAula}) async {
    // Antes de que entre nadie, la tableta solo puede leer las fichas de
    // acceso del aula (nombre, foto y método de acceso).
    if (idAula != null) {
      final accesos = await _bd.alumnosParaAcceso(idAula).first;
      return [
        for (final (i, a) in accesos.indexed)
          Estudiante(
            id: a.id,
            nombre: a.nombre,
            usuario: a.usuario,
            idAula: a.aulaId,
            metodoAcceso: ConversionFirestore.metodoDesde(a.metodoLogin.name),
            avatar: RecursoVisual.desdeUrl(a.fotoUrl),
            color: ColorPastel.paraIndice(i),
          ),
      ];
    }

    // Un tutor solo puede pedir sus estudiantes (HU-16); el administrador,
    // todos.
    final sesion = await _auth.quienSoy();
    final consulta = sesion.esAdmin
        ? _estudiantes
        : _estudiantes.where(
            'tutores',
            arrayContains: sesion.usuario?.id ?? '',
          );
    final resultado = await consulta.get();
    return [
      for (final doc in resultado.docs)
        ConversionFirestore.estudianteDesde(doc.id, doc.data()),
    ]..sort((a, b) => compararAlfabeticamente(a.nombre, b.nombre));
  }

  @override
  Future<void> guardar(Estudiante estudiante) async {
    final ref = _estudiantes.doc(estudiante.id);
    final datos = (await ref.get()).data();
    if (datos == null) {
      throw StateError('No existe el estudiante ${estudiante.id}');
    }
    final anterior = ConversionFirestore.estudianteDesde(estudiante.id, datos);
    var nuevo = estudiante;

    // Foto nueva elegida desde el dispositivo: se sube a Cloud Storage.
    final foto = ConversionFirestore.fotoIncrustada(nuevo.avatar);
    if (foto != null) {
      final url = await _almacenamiento.subirFotoEstudiante(
        nuevo.id,
        foto.bytes,
        tipo: foto.tipo,
      );
      nuevo = nuevo.copyWith(avatar: FotoPropia(url));
    }

    if (_cambiaPerfil(anterior, nuevo)) {
      final perfil = await _bd.obtenerEstudiante(nuevo.id);
      await _bd.actualizarPerfil(
        perfil!.copyWith(
          nombre: nuevo.nombre,
          lugarResidencia: nuevo.lugarResidencia,
          fotoUrl: nuevo.avatar?.url ?? '',
          queLeCalma: nuevo.autorregulacion,
          queNecesita: nuevo.necesidades,
          intereses: nuevo.intereses,
        ),
      );
    }

    final extras = <String, Object?>{
      if (anterior.color != nuevo.color) 'color': nuevo.color.name,
      if (anterior.observaciones != nuevo.observaciones)
        'observaciones': nuevo.observaciones,
      if (anterior.puedeGestionarTareas != nuevo.puedeGestionarTareas)
        'puedeGestionarTareas': nuevo.puedeGestionarTareas,
    };
    if (extras.isNotEmpty) await ref.update(extras);

    if (anterior.preferencias != nuevo.preferencias) {
      await ref.update({
        'preferencias': ConversionFirestore.preferenciasA(
          nuevo.preferencias,
          anteriores: datos['preferencias'] as Map<String, dynamic>?,
        ),
      });
    }

    if (anterior.puedeModificarPreferencias !=
        nuevo.puedeModificarPreferencias) {
      await _bd.permitirCambiarPreferencias(
        nuevo.id,
        nuevo.puedeModificarPreferencias,
      );
    }

    if (anterior.metodoAcceso.runtimeType != nuevo.metodoAcceso.runtimeType) {
      await _bd.cambiarMetodoLogin(
        nuevo.id,
        ConversionFirestore.metodoA(nuevo.metodoAcceso),
      );
    }

    if (anterior.idAula != nuevo.idAula) {
      await _bd.cambiarAula(nuevo.id, nuevo.idAula);
      // El tutor responsable del aula pasa a ser tutor del alumno, para
      // que pueda verlo (HU-15, HU-16).
      final idAula = nuevo.idAula;
      if (idAula != null) {
        final aula = await _db.collection('aulas').doc(idAula).get();
        final tutor = aula.data()?['tutorResponsable'] as String?;
        if (tutor != null && tutor.isNotEmpty) {
          await _bd.asignarTutor(nuevo.id, tutor);
        }
      }
    }
  }

  static bool _cambiaPerfil(Estudiante a, Estudiante b) =>
      a.nombre != b.nombre ||
      a.lugarResidencia != b.lugarResidencia ||
      a.avatar != b.avatar ||
      a.autorregulacion != b.autorregulacion ||
      a.necesidades != b.necesidades ||
      a.intereses.join('|') != b.intereses.join('|');
}
