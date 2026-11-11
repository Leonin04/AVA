import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/agenda/dominio/registro.dart';
import '../../features/aulas/dominio/aula.dart';
import '../../features/autenticacion/dominio/acceso.dart';
import '../../features/autenticacion/dominio/usuario.dart';
import '../../features/perfil/dominio/estudiante.dart';
import '../../features/perfil/dominio/preferencias.dart';
import '../../features/tareas/dominio/paso.dart';
import '../../features/tareas/dominio/tarea.dart';

/// Acceso a Cloud Firestore de AVA.
///
/// Todas las pantallas leen y escriben a través de esta clase: así los datos
/// se guardan siempre igual y las consultas cumplen las reglas de seguridad.
/// Las cuentas (login, crear usuarios) están en `Autenticacion` y las fotos
/// en `Almacenamiento`.
class BaseDatos {
  BaseDatos({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _usuarios =>
      _db.collection('usuarios');
  CollectionReference<Map<String, dynamic>> get _estudiantes =>
      _db.collection('estudiantes');
  CollectionReference<Map<String, dynamic>> get _acceso =>
      _db.collection('acceso');
  CollectionReference<Map<String, dynamic>> get _aulas =>
      _db.collection('aulas');
  CollectionReference<Map<String, dynamic>> get _tareas =>
      _db.collection('tareas');
  CollectionReference<Map<String, dynamic>> _pasos(String tareaId) =>
      _tareas.doc(tareaId).collection('pasos');
  CollectionReference<Map<String, dynamic>> _registros(String estId) =>
      _estudiantes.doc(estId).collection('registros');

  /// Id nuevo para un documento (útil para crear tareas o estudiantes).
  String nuevoId(String coleccion) => _db.collection(coleccion).doc().id;

  // ===================================================================
  // Usuarios: admin y tutores (HU-01, HU-02, HU-03, HU-18)
  // ===================================================================

  /// Datos del admin o tutor con ese uid; null si no lo es (p. ej. estudiante).
  Future<Usuario?> obtenerUsuario(String uid) async {
    final doc = await _usuarios.doc(uid).get();
    return doc.exists ? Usuario.fromDoc(doc) : null;
  }

  /// Todas las cuentas de admin y tutores (solo admin).
  Stream<List<Usuario>> usuarios() => _usuarios.snapshots().map((s) =>
      s.docs.map(Usuario.fromDoc).toList()
        ..sort((a, b) => a.nombre.compareTo(b.nombre)));

  /// Solo los tutores (solo admin).
  Stream<List<Usuario>> tutores() => usuarios()
      .map((l) => l.where((u) => u.rol == Rol.tutor).toList());

  /// Crea o actualiza el documento de un admin o tutor (HU-02, HU-03).
  /// La cuenta de Authentication la crea `Autenticacion.crearCuentaPersonal`.
  Future<void> guardarUsuario(Usuario u) =>
      _usuarios.doc(u.id).set(u.toMap(), SetOptions(merge: true));

  Future<void> eliminarUsuario(String uid) => _usuarios.doc(uid).delete();

  // ===================================================================
  // Estudiantes (HU-01, HU-02, HU-15, HU-16, HU-17, HU-19)
  // ===================================================================

  Future<Estudiante?> obtenerEstudiante(String uid) async {
    final doc = await _estudiantes.doc(uid).get();
    return doc.exists ? Estudiante.fromDoc(doc) : null;
  }

  /// Un estudiante en tiempo real.
  Stream<Estudiante?> estudiante(String id) => _estudiantes
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Estudiante.fromDoc(d) : null);

  /// HU-17: estudiantes de un tutor. Usar SIEMPRE esta consulta para el tutor;
  /// si se pide la colección entera, las reglas la rechazan.
  Stream<List<Estudiante>> estudiantesDeTutor(String tutorUid) => _estudiantes
      .where('tutores', arrayContains: tutorUid)
      .orderBy('nombre')
      .snapshots()
      .map((s) => s.docs.map(Estudiante.fromDoc).toList());

  /// Todos los estudiantes (solo admin).
  Stream<List<Estudiante>> todosLosEstudiantes() => _estudiantes
      .orderBy('nombre')
      .snapshots()
      .map((s) => s.docs.map(Estudiante.fromDoc).toList());

  /// Estudiantes de un aula (solo admin).
  Stream<List<Estudiante>> estudiantesDeAula(String aulaId) => _estudiantes
      .where('aulaId', isEqualTo: aulaId)
      .orderBy('nombre')
      .snapshots()
      .map((s) => s.docs.map(Estudiante.fromDoc).toList());

  /// HU-01: guarda el estudiante y su ficha de acceso (solo admin).
  /// La cuenta de Authentication la crea `Autenticacion.crearCuentaEstudiante`,
  /// que llama a este método.
  Future<void> crearEstudiante(Estudiante e) async {
    final batch = _db.batch();
    batch.set(_estudiantes.doc(e.id), {
      ...e.toMap(),
      'creadoEn': FieldValue.serverTimestamp(),
    });
    batch.set(_acceso.doc(e.id), Acceso.deEstudiante(e).toMap());
    await batch.commit();
  }

  /// HU-19: datos del perfil (admin o tutor del estudiante).
  /// También actualiza el nombre y la foto de su ficha de acceso.
  Future<void> actualizarPerfil(Estudiante e) async {
    final batch = _db.batch();
    batch.update(_estudiantes.doc(e.id), e.toMapPerfil());
    batch.update(_acceso.doc(e.id), {
      'nombre': Acceso.deEstudiante(e).nombre,
      'fotoUrl': e.fotoUrl,
    });
    await batch.commit();
  }

  /// HU-15: preferencias (admin, tutor, o el propio estudiante si está autorizado).
  /// Solo cambia `comunicacion` y `visual`: el resto de `preferencias` (como
  /// `ava`, que usa la interfaz) se conserva.
  Future<void> actualizarPreferencias(String estudianteId, Preferencias p) =>
      _estudiantes.doc(estudianteId).update({
        'preferencias.comunicacion': p.comunicacion.toMap(),
        'preferencias.visual': p.visual.toMap(),
      });

  /// HU-15: el tutor autoriza o no al estudiante a cambiar sus preferencias.
  Future<void> permitirCambiarPreferencias(String estudianteId, bool permitir) =>
      _estudiantes
          .doc(estudianteId)
          .update({'puedeCambiarPreferencias': permitir});

  /// T-31: método de acceso del estudiante (admin o tutor).
  /// Ojo: la clave en sí está en Authentication; si cambia el método hay que
  /// darle una clave nueva (ver README, "Limitaciones").
  Future<void> cambiarMetodoLogin(String estudianteId, MetodoLogin m) async {
    final batch = _db.batch();
    batch.update(_estudiantes.doc(estudianteId), {'metodoLogin': m.name});
    batch.update(_acceso.doc(estudianteId), {'metodoLogin': m.name});
    await batch.commit();
  }

  /// Borra los datos del estudiante y su ficha de acceso (solo admin).
  /// La cuenta de Authentication se queda (ver README, "Limitaciones").
  Future<void> eliminarEstudiante(String estudianteId) async {
    final batch = _db.batch();
    batch.delete(_estudiantes.doc(estudianteId));
    batch.delete(_acceso.doc(estudianteId));
    await batch.commit();
  }

  /// HU-16 / T-33: asignar un tutor (solo admin).
  Future<void> asignarTutor(String estudianteId, String tutorUid) =>
      _estudiantes.doc(estudianteId).update({
        'tutores': FieldValue.arrayUnion([tutorUid]),
      });

  /// HU-16 / T-34: desasignar un tutor (solo admin).
  Future<void> desasignarTutor(String estudianteId, String tutorUid) =>
      _estudiantes.doc(estudianteId).update({
        'tutores': FieldValue.arrayRemove([tutorUid]),
      });

  // ===================================================================
  // Acceso desde la tableta (HU-09)
  // ===================================================================

  /// Alumnos de un aula para la pantalla "¿quién eres?".
  /// Funciona con la sesión anónima de la tableta.
  Stream<List<Acceso>> alumnosParaAcceso(String aulaId) => _acceso
      .where('aulaId', isEqualTo: aulaId)
      .orderBy('nombre')
      .snapshots()
      .map((s) => s.docs.map(Acceso.fromDoc).toList());

  // ===================================================================
  // Aulas (HU-16)
  // ===================================================================

  /// Lista de aulas. Se puede leer con la sesión anónima de la tableta.
  Stream<List<Aula>> aulas() => _aulas
      .orderBy('nombre')
      .snapshots()
      .map((s) => s.docs.map(Aula.fromDoc).toList());

  /// T-38: crea un aula y devuelve su id.
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

  /// T-39 y T-43: nombre y tutor responsable.
  Future<void> actualizarAula(Aula a) => _aulas.doc(a.id).update(a.toMap());

  /// T-41 y T-42: pone o quita (aulaId = null) un estudiante de un aula.
  Future<void> cambiarAula(String estudianteId, String? aulaId) async {
    final batch = _db.batch();
    batch.update(_estudiantes.doc(estudianteId), {'aulaId': aulaId});
    batch.update(_acceso.doc(estudianteId), {'aulaId': aulaId});
    await batch.commit();
  }

  /// T-40: elimina el aula y deja a sus estudiantes sin aula (no los borra).
  Future<void> eliminarAula(String aulaId) async {
    final batch = _db.batch();
    final est = await _estudiantes.where('aulaId', isEqualTo: aulaId).get();
    for (final d in est.docs) {
      batch.update(d.reference, {'aulaId': null});
      batch.update(_acceso.doc(d.id), {'aulaId': null});
    }
    batch.delete(_aulas.doc(aulaId));
    await batch.commit();
  }

  // ===================================================================
  // Tareas y pasos (HU-04 a HU-08)
  // ===================================================================

  /// T-65: tareas asignadas directamente al estudiante, por hora de inicio.
  Stream<List<Tarea>> tareasDeEstudiante(String estudianteUid) => _tareas
      .where('estudiantes', arrayContains: estudianteUid)
      .orderBy('horaInicio')
      .snapshots()
      .map((s) => s.docs.map(Tarea.fromDoc).toList());

  /// HU-08: encargos asignados a toda un aula.
  Stream<List<Tarea>> tareasDeAula(String aulaId) => _tareas
      .where('aulaId', isEqualTo: aulaId)
      .orderBy('horaInicio')
      .snapshots()
      .map((s) => s.docs.map(Tarea.fromDoc).toList());

  /// HU-10: TODAS las tareas que ve un estudiante en su agenda:
  /// las suyas y los encargos de su aula, sin repetir.
  Stream<List<Tarea>> tareasParaAgenda(Estudiante e) {
    final propias = tareasDeEstudiante(e.id);
    if (e.aulaId == null) return propias;
    return _unir(propias, tareasDeAula(e.aulaId!));
  }

  /// Tareas creadas por un usuario (lista de "mis tareas" del tutor).
  Stream<List<Tarea>> tareasCreadasPor(String uid) => _tareas
      .where('creadaPor', isEqualTo: uid)
      .orderBy('nombre')
      .snapshots()
      .map((s) => s.docs.map(Tarea.fromDoc).toList());

  /// Una tarea en tiempo real (detalle, T-85).
  Stream<Tarea?> tarea(String tareaId) => _tareas
      .doc(tareaId)
      .snapshots()
      .map((d) => d.exists ? Tarea.fromDoc(d) : null);

  /// Pasos de una tarea, en orden (T-86).
  Future<List<Paso>> pasosDe(String tareaId) async {
    final s = await _pasos(tareaId).orderBy('orden').get();
    return s.docs.map(Paso.fromDoc).toList();
  }

  /// Crea una tarea con sus pasos y devuelve su id (T-66).
  /// Un estudiante solo puede crear tareas `personal` para sí mismo (HU-04).
  Future<String> crearTarea(Tarea t, List<Paso> pasos) async {
    final ref = _tareas.doc();
    await ref.set({...t.toMap(), 'creadoEn': FieldValue.serverTimestamp()});
    // Los pasos van después: sus reglas comprueban quién creó la tarea.
    await _guardarPasos(ref.id, pasos);
    return ref.id;
  }

  /// Actualiza la tarea y sustituye todos sus pasos (T-79).
  Future<void> actualizarTarea(Tarea t, List<Paso> pasos) async {
    await _tareas.doc(t.id).update(t.toMap());
    await _borrarPasos(t.id);
    await _guardarPasos(t.id, pasos);
  }

  /// Elimina la tarea y sus pasos (T-80).
  Future<void> eliminarTarea(String tareaId) async {
    await _borrarPasos(tareaId);
    await _tareas.doc(tareaId).delete();
  }

  Future<void> _guardarPasos(String tareaId, List<Paso> pasos) async {
    if (pasos.isEmpty) return;
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

  // ===================================================================
  // Registros de inicio y fin (HU-11, HU-12)
  // ===================================================================

  /// Registros de un estudiante en un día (para saber qué está hecho).
  Stream<List<Registro>> registrosDelDia(String estudianteId, DateTime dia) =>
      _registros(estudianteId)
          .where('fecha', isEqualTo: Tarea.claveFecha(dia))
          .snapshots()
          .map((s) => s.docs.map(Registro.fromDoc).toList());

  /// HU-12: el estudiante empieza una tarea (solo el propio estudiante).
  Future<void> marcarInicio(String estudianteId, String tareaId, DateTime dia) {
    final fecha = Tarea.claveFecha(dia);
    return _registros(estudianteId).doc(Registro.idPara(fecha, tareaId)).set({
      'tareaId': tareaId,
      'fecha': fecha,
      'estado': EstadoTarea.iniciada.name,
      'inicio': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// HU-12: el estudiante termina una tarea (solo el propio estudiante).
  Future<void> marcarFin(String estudianteId, String tareaId, DateTime dia) {
    final fecha = Tarea.claveFecha(dia);
    return _registros(estudianteId).doc(Registro.idPara(fecha, tareaId)).set({
      'tareaId': tareaId,
      'fecha': fecha,
      'estado': EstadoTarea.terminada.name,
      'fin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ===================================================================
  // Utilidades
  // ===================================================================

  /// Une dos streams de tareas en uno, sin duplicados y ordenado por hora.
  static Stream<List<Tarea>> _unir(
      Stream<List<Tarea>> a, Stream<List<Tarea>> b) {
    late StreamController<List<Tarea>> ctrl;
    StreamSubscription<List<Tarea>>? sa;
    StreamSubscription<List<Tarea>>? sb;
    List<Tarea>? ua;
    List<Tarea>? ub;

    void emitir() {
      if (ua == null || ub == null) return;
      final porId = <String, Tarea>{for (final t in [...ua!, ...ub!]) t.id: t};
      ctrl.add(porId.values.toList()
        ..sort((x, y) => x.horaInicio.compareTo(y.horaInicio)));
    }

    ctrl = StreamController<List<Tarea>>(
      onListen: () {
        sa = a.listen((v) {
          ua = v;
          emitir();
        }, onError: ctrl.addError);
        sb = b.listen((v) {
          ub = v;
          emitir();
        }, onError: ctrl.addError);
      },
      onCancel: () async {
        await sa?.cancel();
        await sb?.cancel();
      },
    );
    return ctrl.stream;
  }
}
