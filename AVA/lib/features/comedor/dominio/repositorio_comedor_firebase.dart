import 'package:cloud_firestore/cloud_firestore.dart';

import '../../tareas/dominio/tarea.dart' as bd;
import 'comedor.dart';
import 'repositorio_comedor.dart';

/// Datos del comedor en Cloud Firestore (HU-23 a HU-25):
/// - `comedor/{aulaId}_{yyyy-MM-dd}`: la asistencia del aula ese día, con
///   un campo por estudiante en `asistencia`.
/// - `dietas/{estudianteId}`: la dieta autorizada, con sus cambios en
///   `dietas/{id}/cambios` (T-118). Las reglas solo dejan leerla a la
///   administración y a los tutores del centro (T-117).
///
/// El esquema del entregable no preveía dónde guardar el comedor; estas dos
/// colecciones se documentan en `INTEGRACION_FIREBASE.md`.
class RepositorioComedorFirebase implements RepositorioComedor {
  RepositorioComedorFirebase({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _dia(String idAula, DateTime f) =>
      _db.collection('comedor').doc('${idAula}_${bd.Tarea.claveFecha(f)}');

  DocumentReference<Map<String, dynamic>> _dieta(String idEstudiante) =>
      _db.collection('dietas').doc(idEstudiante);

  @override
  Future<Map<String, AsistenciaComedor>> asistencia({
    required String idAula,
    required DateTime fecha,
  }) async {
    final datos = (await _dia(idAula, fecha).get()).data();
    final porEstudiante = datos?['asistencia'] as Map? ?? const {};
    return {
      for (final MapEntry(:key, :value) in porEstudiante.entries)
        key as String: AsistenciaComedor.fromMap(key, value as Map),
    };
  }

  @override
  Future<void> registrarAsistencia({
    required String idAula,
    required DateTime fecha,
    required AsistenciaComedor asistencia,
  }) => _dia(idAula, fecha).set({
    'aulaId': idAula,
    'fecha': bd.Tarea.claveFecha(fecha),
    // Solo se cambia la respuesta de ese estudiante: así el encargado o
    // el propio alumno no pueden tocar las de los demás sin permiso.
    'asistencia': {
      asistencia.idEstudiante: {
        ...asistencia.toMap(),
        'actualizadoEn': FieldValue.serverTimestamp(),
      },
    },
  }, SetOptions(merge: true));

  @override
  Future<Dieta?> dieta(String idEstudiante) async {
    final datos = (await _dieta(idEstudiante).get()).data();
    return datos == null ? null : Dieta.fromMap(idEstudiante, datos);
  }

  @override
  Future<void> guardarDieta(Dieta dieta, {required String idActor}) async {
    final ref = _dieta(dieta.idEstudiante);
    final batch = _db.batch();
    batch.set(ref, {
      ...dieta.toMap(),
      'actualizadaEn': FieldValue.serverTimestamp(),
      'actualizadaPor': idActor,
    });
    batch.set(ref.collection('cambios').doc(), {
      'momento': FieldValue.serverTimestamp(),
      'idActor': idActor,
      'resumen': dieta.vacia ? 'Sin dieta especial' : dieta.resumen,
    });
    await batch.commit();
  }

  @override
  Future<List<CambioDieta>> cambiosDieta(String idEstudiante) async {
    final cambios = await _dieta(
      idEstudiante,
    ).collection('cambios').orderBy('momento', descending: true).get();
    return [
      for (final doc in cambios.docs)
        CambioDieta(
          momento:
              (doc.data()['momento'] as Timestamp?)?.toDate() ?? DateTime(0),
          idActor: doc.data()['idActor'] as String? ?? '',
          resumen: doc.data()['resumen'] as String? ?? '',
        ),
    ];
  }
}
