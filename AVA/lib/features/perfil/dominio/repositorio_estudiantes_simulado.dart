import '../../../core/servicios/almacen_simulado.dart';
import '../../../core/utilidades/orden_alfabetico.dart';
import 'estudiante.dart';
import 'repositorio_estudiantes.dart';

/// Perfiles guardados en el [AlmacenSimulado].
class RepositorioEstudiantesSimulado implements RepositorioEstudiantes {
  RepositorioEstudiantesSimulado(this._almacen);

  static const coleccion = 'estudiantes';

  final AlmacenSimulado _almacen;

  @override
  Future<Estudiante?> obtener(String id) async {
    final datos = _almacen.obtener(coleccion, id);
    return datos == null ? null : Estudiante.fromMap(id, datos);
  }

  @override
  Future<List<Estudiante>> listar({String? idAula}) async => [
    for (final (id, datos) in _almacen.listar(
      coleccion,
      donde: idAula == null ? null : (d) => d['idAula'] == idAula,
    ))
      Estudiante.fromMap(id, datos),
  ]..sort((a, b) => compararAlfabeticamente(a.nombre, b.nombre));

  @override
  Future<void> guardar(Estudiante estudiante) async {
    _almacen.guardar(coleccion, estudiante.id, estudiante.toMap());
  }
}
