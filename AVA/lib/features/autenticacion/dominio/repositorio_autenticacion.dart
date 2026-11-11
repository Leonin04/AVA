import '../../perfil/dominio/perfil_estudiante.dart';
import 'clave_acceso.dart';
import 'cuenta.dart';

/// Inicio y cierre de sesión y gestión de claves.
///
/// Implementaciones: `RepositorioAutenticacionSimulado` (pruebas) y
/// `RepositorioAutenticacionFirebase` (Firebase Authentication).
///
/// Los errores que se deben enseñar al usuario se lanzan como
/// `ErrorConMensaje`.
abstract interface class RepositorioAutenticacion {
  /// Deja el dispositivo listo para mostrar las aulas y los alumnos antes de
  /// que entre nadie (sesión de la tableta, HU-09).
  Future<void> prepararDispositivo();

  /// Devuelve la cuenta de administrador o tutor si las credenciales son
  /// correctas, o `null` si no lo son (HU-18). [usuario] es el correo.
  Future<Cuenta?> iniciarSesionGestion({
    required String usuario,
    required String contrasena,
  });

  /// Comprueba la clave del estudiante (HU-09). Si es correcta, inicia su
  /// sesión y devuelve su perfil completo; si no, devuelve `null`.
  Future<Estudiante?> entrarEstudiante({
    required Estudiante estudiante,
    required ClaveAcceso clave,
  });

  /// Cambia la clave de un estudiante.
  Future<void> guardarClave(String idCuenta, ClaveAcceso clave);

  /// Envía un enlace para recuperar la contraseña al correo indicado, si
  /// pertenece a alguna cuenta (HU-18).
  Future<void> solicitarRecuperacion(String email);

  /// Cierra la sesión y vuelve a dejar el dispositivo listo.
  Future<void> cerrarSesion();
}
