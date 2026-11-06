import 'clave_acceso.dart';
import 'cuenta.dart';

/// Comprobación y gestión de credenciales.
///
/// Al conectar Firebase se implementará con Firebase Authentication.
abstract interface class RepositorioAutenticacion {
  /// Devuelve la cuenta de administrador o tutor si las credenciales son
  /// correctas, o `null` si no lo son (HU-17).
  Future<Cuenta?> iniciarSesionGestion({
    required String usuario,
    required String contrasena,
  });

  /// Comprueba la clave de un estudiante (HU-08).
  Future<bool> validarEstudiante({
    required String idEstudiante,
    required ClaveAcceso clave,
  });

  /// Guarda o cambia la clave de una cuenta.
  Future<void> guardarClave(String idCuenta, ClaveAcceso clave);

  /// Envía un enlace para recuperar la contraseña al correo indicado, si
  /// pertenece a alguna cuenta (HU-17).
  Future<void> solicitarRecuperacion(String email);
}
