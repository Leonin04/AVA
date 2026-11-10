import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../features/autenticacion/dominio/acceso.dart';
import '../../features/autenticacion/dominio/usuario.dart';
import '../../features/perfil/dominio/estudiante.dart';
import '../../firebase_options.dart';
import 'base_datos.dart';

/// Quién ha iniciado sesión. Solo uno de los dos campos tiene valor.
class Sesion {
  const Sesion({this.usuario, this.estudiante});

  /// Admin o tutor.
  final Usuario? usuario;

  /// Estudiante.
  final Estudiante? estudiante;

  bool get esAdmin => usuario?.esAdmin ?? false;
  bool get esTutor => usuario?.esTutor ?? false;
  bool get esEstudiante => estudiante != null;
}

/// Error con un mensaje claro para enseñar en pantalla (T-15, T-30).
class ErrorAcceso implements Exception {
  const ErrorAcceso(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}

/// Inicio de sesión y gestión de cuentas (HU-01, HU-03, HU-09, HU-18).
///
/// Cómo funcionan las cuentas:
/// - Admin y tutores: correo y contraseña normales.
/// - Estudiantes: también tienen cuenta de correo y contraseña, pero NO la ven.
///   Su correo es interno (`<usuario>@alumnos.ava.test`) y su contraseña sale
///   del PIN, de la secuencia de pictogramas o de su contraseña (ver [claveDe]).
/// - La tableta, antes de que entre un alumno, usa una sesión anónima para
///   poder mostrar aulas y avatares ([prepararTableta]).
class Autenticacion {
  Autenticacion({FirebaseAuth? auth, BaseDatos? bd})
      : _auth = auth ?? FirebaseAuth.instance,
        _bd = bd ?? BaseDatos();

  final FirebaseAuth _auth;
  final BaseDatos _bd;

  /// Dominio de los correos internos de los estudiantes.
  static const dominioAlumnos = 'alumnos.ava.test';

  /// Palabras de la clave de pictogramas (HU-09). La pantalla de acceso
  /// muestra el pictograma de ARASAAC de cada una y el alumno toca 3 en orden.
  static const pictogramasClave = ['sol', 'casa', 'perro', 'coche', 'flor', 'pelota'];

  /// Correo interno de un estudiante a partir de su usuario.
  static String correoEstudiante(String usuario) =>
      '${usuario.trim().toLowerCase()}@$dominioAlumnos';

  /// Contraseña real de Firebase a partir de lo que introduce el alumno.
  /// - PIN "1234"                      → "ava-pin-1234"
  /// - pictogramas ["sol","perro","flor"] → "ava-pic-sol-perro-flor"
  /// - contraseña "miclave"            → "miclave" (mínimo 6 caracteres)
  static String claveDe(MetodoLogin metodo, Object entrada) => switch (metodo) {
        MetodoLogin.pin => 'ava-pin-$entrada',
        MetodoLogin.pictograma => 'ava-pic-${(entrada as List).join('-')}',
        MetodoLogin.contrasena => entrada as String,
      };

  /// Cambios de sesión (para redirigir pantallas).
  Stream<User?> get cambiosDeSesion => _auth.authStateChanges();

  User? get usuarioFirebase => _auth.currentUser;

  // ------------------------------------------------------------------
  // Tableta del aula (HU-09)
  // ------------------------------------------------------------------

  /// Sesión anónima para que la tableta pueda mostrar aulas y alumnos.
  /// Llamarla al abrir la pantalla "elige tu aula".
  Future<void> prepararTableta() async {
    if (_auth.currentUser == null) await _auth.signInAnonymously();
  }

  // ------------------------------------------------------------------
  // Iniciar y cerrar sesión
  // ------------------------------------------------------------------

  /// HU-18: tutor o administrador. Devuelve quién es (T-18).
  Future<Sesion> entrarPersonal(String correo, String contrasena) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: correo.trim(), password: contrasena);
    } on FirebaseAuthException catch (e) {
      throw ErrorAcceso(_mensaje(e));
    }
    final s = await quienSoy();
    if (s.usuario == null) {
      await salir();
      throw const ErrorAcceso('Esta cuenta no es de un tutor ni de un administrador.');
    }
    return s;
  }

  /// HU-09: estudiante con su método (PIN, pictogramas o contraseña).
  /// [entrada] es el PIN (String), la lista de palabras de pictogramas
  /// o la contraseña (String).
  Future<Sesion> entrarEstudiante(Acceso alumno, Object entrada) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: correoEstudiante(alumno.usuario),
        password: claveDe(alumno.metodoLogin, entrada),
      );
    } on FirebaseAuthException catch (e) {
      // Volvemos a la sesión anónima para que la tableta siga funcionando.
      await prepararTableta();
      throw ErrorAcceso(e.code == 'invalid-credential' || e.code == 'wrong-password'
          ? 'Clave incorrecta. Prueba otra vez.'
          : _mensaje(e));
    }
    return quienSoy();
  }

  /// T-18: quién ha iniciado sesión (admin, tutor o estudiante).
  Future<Sesion> quienSoy() async {
    final u = _auth.currentUser;
    if (u == null || u.isAnonymous) return const Sesion();
    final usuario = await _bd.obtenerUsuario(u.uid);
    if (usuario != null) return Sesion(usuario: usuario);
    return Sesion(estudiante: await _bd.obtenerEstudiante(u.uid));
  }

  /// T-16: recuperar contraseña (solo admin y tutores, que tienen correo real).
  Future<void> recuperarContrasena(String correo) async {
    try {
      await _auth.sendPasswordResetEmail(email: correo.trim());
    } on FirebaseAuthException catch (e) {
      throw ErrorAcceso(_mensaje(e));
    }
  }

  /// T-17: cerrar sesión.
  Future<void> salir() => _auth.signOut();

  // ------------------------------------------------------------------
  // Crear cuentas (solo admin) — HU-01
  // ------------------------------------------------------------------

  /// Crea la cuenta de un admin o tutor y su documento en `usuarios`.
  /// Devuelve su uid. El administrador NO pierde su sesión.
  Future<String> crearCuentaPersonal({
    required String nombre,
    required String correo,
    required String contrasena,
    required Rol rol,
    TipoTutor? tipoTutor,
  }) async {
    final uid = await _crearCuenta(correo.trim(), contrasena);
    await _bd.guardarUsuario(Usuario(
      id: uid,
      nombre: nombre,
      email: correo.trim(),
      rol: rol,
      tipoTutor: rol == Rol.tutor ? tipoTutor : null,
    ));
    return uid;
  }

  /// Crea la cuenta de un estudiante, su documento y su ficha de acceso.
  /// [datos] lleva todo menos el id (se ignora); [entrada] es su PIN,
  /// su lista de pictogramas o su contraseña. Devuelve el uid.
  Future<String> crearCuentaEstudiante(Estudiante datos, Object entrada) async {
    final uid = await _crearCuenta(
      correoEstudiante(datos.usuario),
      claveDe(datos.metodoLogin, entrada),
    );
    await _bd.crearEstudiante(Estudiante(
      id: uid,
      nombre: datos.nombre,
      usuario: datos.usuario.trim().toLowerCase(),
      lugarResidencia: datos.lugarResidencia,
      fotoUrl: datos.fotoUrl,
      queLeCalma: datos.queLeCalma,
      queNecesita: datos.queNecesita,
      intereses: datos.intereses,
      metodoLogin: datos.metodoLogin,
      aulaId: datos.aulaId,
      tutores: datos.tutores,
      puedeCambiarPreferencias: datos.puedeCambiarPreferencias,
      preferencias: datos.preferencias,
    ));
    return uid;
  }

  /// Crea la cuenta en una segunda instancia de Firebase para que el
  /// administrador no pierda su sesión.
  Future<String> _crearCuenta(String correo, String contrasena) async {
    FirebaseApp app;
    try {
      app = Firebase.app('secundaria');
    } catch (_) {
      app = await Firebase.initializeApp(
        name: 'secundaria',
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    final auth2 = FirebaseAuth.instanceFor(app: app);
    try {
      final cred = await auth2.createUserWithEmailAndPassword(
          email: correo, password: contrasena);
      return cred.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw ErrorAcceso(_mensaje(e));
    } finally {
      await auth2.signOut();
    }
  }

  static String _mensaje(FirebaseAuthException e) => switch (e.code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' =>
          'El correo o la contraseña no son correctos.',
        'invalid-email' => 'El correo no es válido.',
        'email-already-in-use' => 'Ya existe una cuenta con ese correo o usuario.',
        'weak-password' => 'La contraseña es demasiado corta (mínimo 6 caracteres).',
        'too-many-requests' => 'Demasiados intentos. Espera un momento.',
        'network-request-failed' => 'No hay conexión a Internet.',
        _ => 'No se pudo completar (${e.code}).',
      };
}
