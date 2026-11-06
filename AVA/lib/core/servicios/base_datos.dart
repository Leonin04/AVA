import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/aulas/dominio/aula.dart';
import '../../features/autenticacion/dominio/usuario.dart';
import '../../features/perfil/dominio/estudiante.dart';
import '../../features/perfil/dominio/preferencias.dart';
import '../../features/tareas/dominio/paso.dart';
import '../../features/tareas/dominio/tarea.dart';

/// Acceso a Cloud Firestore para la iteración 1.
///
/// Todas las pantallas deberían leer y escribir a través de esta clase,
/// así las consultas cumplen siempre las reglas de seguridad
/// (por ejemplo, el filtro por tutor de RF-06).
class BaseDatos {
  BaseDatos({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _usuarios =>
      _db.collection('usuarios');
  CollectionReference<Map<String, dynamic>> get _estudiantes =>
      _db.collection('estudiantes');
  CollectionReference<Map<String, dynamic>> get _aulas =>
      _db.collection('aulas');
  CollectionReference<Map<String, dynamic>> get _tareas =>
      _db.collection('tareas');
  CollectionReference<Map<String, dynamic>> _pasos(String tareaId) =>
      _tareas.doc(tareaId).collection('pasos');

  // ===================================================================
  // Usuarios (RF-01, RF-02)
  // ===================================================================

  /// Datos del usuario que acaba de iniciar sesión.
  /// Devuelve null si no es admin ni tutor (por ejemplo, un estudiante).
  Future<Usuario?> obtenerUsuario(String uid) async {
    final doc = await _usuarios.doc(uid).get();
    return doc.exists ? Usuario.fromDoc(doc) : null;
  }

  /// Lista de tutores (solo administrador).
  Stream<List<Usuario>> tutores() => _usuarios
      .where('rol', isEqualTo: Rol.tutor.name)
      .snapshots()
      .map((s) => s.docs.map(Usuario.fromDoc).toList()
        ..sort((a, b) => a.nombre.compareTo(b.nombre)));

  /// Crea o actualiza el documento de un admin o tutor. La cuenta de
  /// Authentication se crea aparte y su uid se usa como id.
  Future<void> guardarUsuario(Usuario u) => _usuarios.doc(u.id).set({
        ...u.toMap(),
        'creadoEn': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  Future<void> eliminarUsuario(String uid) => _usuarios.doc(uid).delete();

  // ===================================================================
  // Estudiantes (RF-01, RF-03, RF-04, RF-06 a RF-09)
  // ===================================================================

  /// Estudiante que ha iniciado sesión (RF-03).
  Future<Estudiante?> obtenerEstudiante(String uid) async {
    final doc = await _estudiantes.doc(uid).get();
    return doc.exists ? Estudiante.fromDoc(doc) : null;
  }

  /// RF-06: estudiantes de un tutor. Usar SIEMPRE esta consulta para el
  /// tutor; si se pide la colección entera, las reglas la rechazan.
  Stream<List<Estudiante>> estudiantesDeTutor(String tutorUid) => _estudiantes
      .where('tutores', arrayContains: tutorUid)
      .orderBy('nombre')
      .snapshots()
      .map((s) => s.docs.map(Estudiante.fromDoc).toList());

  /// Todos los estudiantes (solo administrador).
  Stream<List<Estudiante>> todosLosEstudiantes() => _estudiantes
      .orderBy('nombre')
      .snapshots()
      .map((s) => s.docs.map(Estudiante.fromDoc).toList());

  /// RF-05: estudiantes de un aula (solo administrador).
  Stream<List<Estudiante>> estudiantesDeAula(String aulaId) => _estudiantes
      .where('aulaId', isEqualTo: aulaId)
      .orderBy('nombre')
      .snapshots()
      .map((s) => s.docs.map(Estudiante.fromDoc).toList());

  /// RF-01: alta del estudiante (solo administrador).
  Future<void> crearEstudiante(Estudiante e) => _estudiantes.doc(e.id).set({
        ...e.toMap(),
        'creadoEn': FieldValue.serverTimestamp(),
      });

  /// RF-07: datos del perfil (admin o tutor del estudiante).
  Future<void> actualizarPerfil(Estudiante e) =>
      _estudiantes.doc(e.id).update(e.toMapPerfil());

  /// RF-08 y RF-09: preferencias (admin o tutor del estudiante).
  Future<void> actualizarPreferencias(String estudianteId, Preferencias p) =>
      _estudiantes.doc(estudianteId).update({'preferencias': p.toMap()});

  /// RF-01: baja del estudiante (solo administrador).
  Future<void> eliminarEstudiante(String estudianteId) =>
      _estudiantes.doc(estudianteId).delete();

  /// RF-04: asignar un tutor (solo administrador).
  Future<void> asignarTutor(String estudianteId, String tutorUid) =>
      _estudiantes.doc(estudianteId).update({
        'tutores': FieldValue.arrayUnion([tutorUid]),
      });

  /// RF-04: desasignar un tutor (solo administrador).
  Future<void> desasignarTutor(String estudianteId, String tutorUid) =>
      _estudiantes.doc(estudianteId).update({
        'tutores': FieldValue.arrayRemove([tutorUid]),
      });

  // ===================================================================
  // Aulas (RF-05)
  // ===================================================================

  Stream<List<Aula>> aulas() => _aulas
      .orderBy('nombre')
      .snapshots()
      .map((s) => s.docs.map(Aula.fromDoc).toList());

  /// Crea un aula y devuelve su id.
  Future<String> crearAula({
    required String nombre,
    required String tutorResponsable,
  }) async {
    final ref = await _aulas.add({
      'nombre': nombre,
      'tutorResponsable': tutorResponsable,
      'creadoEn': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> actualizarAula(Aula a) => _aulas.doc(a.id).update(a.toMap());

  /// Pone o quita (aulaId = null) un estudiante de un aula.
  Future<void> cambiarAula(String estudianteId, String? aulaId) =>
      _estudiantes.doc(estudianteId).update({'aulaId': aulaId});

  /// Elimina el aula y deja a sus estudiantes sin aula (no los borra).
  Future<void> eliminarAula(String aulaId) async {
    final batch = _db.batch();
    final est = await _estudiantes.where('aulaId', isEqualTo: aulaId).get();
    for (final d in est.docs) {
      batch.update(d.reference, {'aulaId': null});
    }
    batch.delete(_aulas.doc(aulaId));
    await batch.commit();
  }

  // ===================================================================
  // Tareas y pasos (RF-15, RF-22)
  // ===================================================================

  /// T-65: todas las tareas de un estudiante, ordenadas por hora de inicio.
  Stream<List<Tarea>> tareasDeEstudiante(String estudianteUid) => _tareas
      .where('estudiantes', arrayContains: estudianteUid)
      .orderBy('horaInicio')
      .snapshots()
      .map((s) => s.docs.map(Tarea.fromDoc).toList());

  /// RF-22: tareas de hoy de un estudiante, ordenadas por hora.
  /// Firestore no permite dos filtros array-contains en la misma consulta,
  /// así que el día de la semana se filtra en la app.
  Stream<List<Tarea>> tareasDelDia(String estudianteUid, {DateTime? dia}) {
    final hoy = dia ?? DateTime.now();
    return _tareas
        .where('estudiantes', arrayContains: estudianteUid)
        .orderBy('horaInicio')
        .snapshots()
        .map((s) => s.docs
            .map(Tarea.fromDoc)
            .where((t) => t.esParaDia(hoy))
            .toList());
  }

  /// Tareas creadas por un tutor (para su lista de tareas).
  Stream<List<Tarea>> tareasCreadasPor(String uid) => _tareas
      .where('creadaPor', isEqualTo: uid)
      .orderBy('nombre')
      .snapshots()
      .map((s) => s.docs.map(Tarea.fromDoc).toList());

  /// Una tarea concreta (para el detalle, T-85).
  Stream<Tarea?> tarea(String tareaId) => _tareas
      .doc(tareaId)
      .snapshots()
      .map((d) => d.exists ? Tarea.fromDoc(d) : null);

  /// Pasos de una tarea, en orden.
  Future<List<Paso>> pasosDe(String tareaId) async {
    final s = await _pasos(tareaId).orderBy('orden').get();
    return s.docs.map(Paso.fromDoc).toList();
  }

  /// RF-15: crea una tarea con sus pasos y devuelve su id.
  /// [pasos]: textos en orden (las imágenes se pueden añadir después).
  Future<String> crearTarea(Tarea t, List<Paso> pasos) async {
    final ref = _tareas.doc();
    await ref.set({...t.toMap(), 'creadoEn': FieldValue.serverTimestamp()});
    // Los pasos van después de la tarea: las reglas de los pasos
    // comprueban quién creó la tarea, así que esta tiene que existir antes.
    await _guardarPasos(ref.id, pasos);
    return ref.id;
  }

  /// RF-15: actualiza la tarea y sustituye todos sus pasos.
  Future<void> actualizarTarea(Tarea t, List<Paso> pasos) async {
    await _tareas.doc(t.id).update(t.toMap());
    await _borrarPasos(t.id);
    await _guardarPasos(t.id, pasos);
  }

  /// RF-15: elimina la tarea y sus pasos.
  Future<void> eliminarTarea(String tareaId) async {
    await _borrarPasos(tareaId);
    await _tareas.doc(tareaId).delete();
  }

  Future<void> _guardarPasos(String tareaId, List<Paso> pasos) async {
    final batch = _db.batch();
    for (var i = 0; i < pasos.length; i++) {
      final p = pasos[i];
      batch.set(_pasos(tareaId).doc('paso-${i + 1}'), {
        'orden': i + 1,
        'texto': p.texto,
        'imagenUrl': p.imagenUrl,
      });
    }
    await batch.commit();
  }

  Future<void> _borrarPasos(String tareaId) async {
    final s = await _pasos(tareaId).get();
    if (s.docs.isEmpty) return;
    final batch = _db.batch();
    for (final d in s.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }
}
