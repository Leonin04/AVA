import '../../../core/servicios/almacen_simulado.dart';
import '../../../core/utilidades/orden_alfabetico.dart';
import 'cuenta.dart';
import 'repositorio_cuentas.dart';

/// Cuentas guardadas en el [AlmacenSimulado].
class RepositorioCuentasSimulado implements RepositorioCuentas {
  RepositorioCuentasSimulado(this._almacen);

  static const coleccion = 'cuentas';

  final AlmacenSimulado _almacen;

  @override
  Future<List<Cuenta>> listar() async => [
    for (final (id, datos) in _almacen.listar(coleccion))
      Cuenta.fromMap(id, datos),
  ]..sort((a, b) => compararAlfabeticamente(a.nombre, b.nombre));

  @override
  Future<Cuenta?> obtener(String id) async {
    final datos = _almacen.obtener(coleccion, id);
    return datos == null ? null : Cuenta.fromMap(id, datos);
  }

  @override
  Future<void> crear(Cuenta cuenta) async {
    if (_almacen.existe(coleccion, cuenta.id)) throw CuentaDuplicada(cuenta.id);
    _almacen.guardar(coleccion, cuenta.id, cuenta.toMap());
  }

  @override
  Future<void> actualizar(Cuenta cuenta) async {
    if (!_almacen.existe(coleccion, cuenta.id)) {
      throw StateError('No existe la cuenta ${cuenta.id}');
    }
    _almacen.guardar(coleccion, cuenta.id, cuenta.toMap());
  }
}
