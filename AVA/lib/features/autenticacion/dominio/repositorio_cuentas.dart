import 'clave_acceso.dart';
import 'cuenta.dart';

/// Gestión de las cuentas de usuario (HU-01, HU-02).
///
/// Implementaciones: `RepositorioCuentasSimulado` (pruebas) y
/// `RepositorioCuentasFirebase`.
abstract interface class RepositorioCuentas {
  Future<List<Cuenta>> listar();

  Future<Cuenta?> obtener(String id);

  /// Crea una cuenta con su [clave] y devuelve su identificador. Si es de
  /// estudiante, crea también su perfil en [idAula].
  ///
  /// Lanza [CuentaDuplicada] si ya existe una con el mismo usuario o correo.
  Future<String> crear(Cuenta cuenta, ClaveAcceso clave, {String? idAula});

  /// Cambia nombre, rol y correo.
  Future<void> actualizar(Cuenta cuenta);
}

class CuentaDuplicada implements Exception {
  const CuentaDuplicada(this.id);

  final String id;

  @override
  String toString() => 'Ya existe una cuenta con el usuario o correo «$id».';
}
