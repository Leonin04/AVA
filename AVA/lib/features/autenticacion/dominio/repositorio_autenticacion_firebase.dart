import '../../../core/servicios/autenticacion.dart';
import '../../../core/utilidades/controlador_carga.dart';
import '../../perfil/dominio/conversion_firestore.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../../perfil/dominio/repositorio_estudiantes.dart';
import 'acceso.dart';
import 'clave_acceso.dart';
import 'cuenta.dart';
import 'repositorio_autenticacion.dart';
import 'rol.dart';
import 'usuario.dart' as bd;

/// Inicio de sesión con Firebase Authentication, a través del servicio
/// `Autenticacion`.
class RepositorioAutenticacionFirebase implements RepositorioAutenticacion {
  RepositorioAutenticacionFirebase({
    required RepositorioEstudiantes estudiantes,
    Autenticacion? autenticacion,
  }) : _estudiantes = estudiantes,
       _auth = autenticacion ?? Autenticacion();

  final RepositorioEstudiantes _estudiantes;
  final Autenticacion _auth;

  /// Cuenta de la interfaz a partir de un admin o tutor de la base de datos.
  static Cuenta cuentaDesde(bd.Usuario usuario) => Cuenta(
    id: usuario.id,
    nombre: usuario.nombre,
    rol: usuario.esAdmin ? Rol.administrador : Rol.tutor,
    email: usuario.email,
    esFamiliar: usuario.tipoTutor == bd.TipoTutor.familiar,
  );

  /// Lo que hay que pasar a `Autenticacion` según el tipo de clave.
  static Object entradaDe(ClaveAcceso clave) => switch (clave) {
    ClavePin(:final digitos) => digitos,
    ClavePictogramas(:final secuencia) => [for (final p in secuencia) p.name],
    ClaveContrasena(:final texto) => texto,
  };

  @override
  Future<void> prepararDispositivo() => _auth.prepararTableta();

  @override
  Future<Cuenta?> iniciarSesionGestion({
    required String usuario,
    required String contrasena,
  }) async {
    try {
      final sesion = await _auth.entrarPersonal(usuario, contrasena);
      final cuenta = sesion.usuario;
      return cuenta == null ? null : cuentaDesde(cuenta);
    } on ErrorAcceso catch (error) {
      throw ErrorConMensaje(error.mensaje);
    }
  }

  @override
  Future<Estudiante?> entrarEstudiante({
    required Estudiante estudiante,
    required ClaveAcceso clave,
  }) async {
    final acceso = Acceso(
      id: estudiante.id,
      nombre: estudiante.nombre,
      usuario: estudiante.usuario,
      aulaId: estudiante.idAula,
      fotoUrl: estudiante.avatar?.url ?? '',
      metodoLogin: ConversionFirestore.metodoA(estudiante.metodoAcceso),
    );
    try {
      final sesion = await _auth.entrarEstudiante(acceso, entradaDe(clave));
      final id = sesion.estudiante?.id;
      return id == null ? null : _estudiantes.obtener(id);
    } on ErrorAcceso catch (error) {
      if (error.mensaje.startsWith('Clave incorrecta')) return null;
      throw ErrorConMensaje(error.mensaje);
    }
  }

  @override
  Future<void> guardarClave(String idCuenta, ClaveAcceso clave) async {
    throw const ErrorConMensaje(
      'Por ahora la clave de un alumno no se puede cambiar desde la app '
      '(hace falta un servidor). Hay que crear su cuenta de nuevo.',
    );
  }

  @override
  Future<void> solicitarRecuperacion(String email) async {
    try {
      await _auth.recuperarContrasena(email);
    } on ErrorAcceso {
      // Por seguridad no se dice si el correo existe o no.
    }
  }

  @override
  Future<void> cerrarSesion() async {
    await _auth.salir();
    await _auth.prepararTableta();
  }
}
