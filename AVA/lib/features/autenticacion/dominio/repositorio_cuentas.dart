import 'cuenta.dart';

/// Gestión de las cuentas de usuario (HU-01, HU-02).
///
/// Al conectar Firebase se implementará con Cloud Firestore.
abstract interface class RepositorioCuentas {
  Future<List<Cuenta>> listar();

  Future<Cuenta?> obtener(String id);

  /// Crea una cuenta nueva. Lanza [CuentaDuplicada] si ya existe una con
  /// el mismo identificador.
  Future<void> crear(Cuenta cuenta);

  Future<void> actualizar(Cuenta cuenta);
}

class CuentaDuplicada implements Exception {
  const CuentaDuplicada(this.id);

  final String id;

  @override
  String toString() => 'Ya existe una cuenta con el usuario «$id».';
}
