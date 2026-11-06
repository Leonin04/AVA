import 'pictograma_clave.dart';

/// Comprobación de credenciales de administradores, tutores y estudiantes.
///
/// Al conectar Firebase se implementará con Firebase Authentication.
abstract interface class RepositorioAutenticacion {
  Future<bool> validarAdministrador({
    required String usuario,
    required String contrasena,
  });

  Future<bool> validarContrasenaEstudiante({
    required String idEstudiante,
    required String contrasena,
  });

  Future<bool> validarPictogramasEstudiante({
    required String idEstudiante,
    required List<PictogramaClave> secuencia,
  });
}
