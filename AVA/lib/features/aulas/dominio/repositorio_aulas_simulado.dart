import '../../../core/servicios/almacen_simulado.dart';
import '../../../core/utilidades/orden_alfabetico.dart';
import 'aula.dart';
import 'repositorio_aulas.dart';

/// Aulas guardadas en el [AlmacenSimulado].
class RepositorioAulasSimulado implements RepositorioAulas {
  RepositorioAulasSimulado(this._almacen);

  static const coleccion = 'aulas';

  final AlmacenSimulado _almacen;

  @override
  Future<List<Aula>> obtenerAulas() async => [
    for (final (id, datos) in _almacen.listar(coleccion))
      Aula.fromMap(id, datos),
  ]..sort((a, b) => compararAlfabeticamente(a.nombre, b.nombre));

  @override
  Future<Aula?> obtener(String id) async {
    final datos = _almacen.obtener(coleccion, id);
    return datos == null ? null : Aula.fromMap(id, datos);
  }

  @override
  Future<void> guardar(Aula aula) async {
    _almacen.guardar(coleccion, aula.id, aula.toMap());
  }

  @override
  String nuevoId() => _almacen.nuevoId('aula');
}
