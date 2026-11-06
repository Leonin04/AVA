import 'pictograma_clave.dart';
import 'repositorio_autenticacion.dart';

/// Credenciales de prueba mientras no se conecta Firebase Authentication.
///
/// - Administrador: usuario `admin`, contraseña `admin1234`.
/// - Estudiantes con contraseña: `1234`.
/// - Estudiantes con pictogramas: los N primeros pictogramas en orden
///   (sol, luna, estrella, corazón, flor, coche), siendo N la longitud de su
///   clave.
///
/// Los identificadores coinciden con los de `RepositorioEstudiantesSimulado`.
class RepositorioAutenticacionSimulado implements RepositorioAutenticacion {
  static const _administradores = {'admin': 'admin1234'};

  static const _contrasenasEstudiantes = {
    'e02': '1234',
    'e05': '1234',
    'e07': '1234',
    'e10': '1234',
    'e14': '1234',
  };

  static const _longitudClavePictogramas = {
    'e01': 4,
    'e03': 3,
    'e04': 6,
    'e06': 5,
    'e08': 3,
    'e09': 4,
    'e11': 4,
    'e12': 3,
    'e13': 5,
    'e15': 4,
  };

  @override
  Future<bool> validarAdministrador({
    required String usuario,
    required String contrasena,
  }) async =>
      _administradores[usuario] == contrasena;

  @override
  Future<bool> validarContrasenaEstudiante({
    required String idEstudiante,
    required String contrasena,
  }) async =>
      _contrasenasEstudiantes[idEstudiante] == contrasena;

  @override
  Future<bool> validarPictogramasEstudiante({
    required String idEstudiante,
    required List<PictogramaClave> secuencia,
  }) async {
    final longitud = _longitudClavePictogramas[idEstudiante];
    if (longitud == null || secuencia.length != longitud) return false;

    final esperada = PictogramaClave.values.take(longitud).toList();
    for (var i = 0; i < longitud; i++) {
      if (secuencia[i] != esperada[i]) return false;
    }
    return true;
  }
}
