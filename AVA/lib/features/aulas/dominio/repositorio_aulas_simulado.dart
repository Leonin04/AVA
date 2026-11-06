import 'aula.dart';
import 'repositorio_aulas.dart';

/// Datos de prueba de las aulas mientras no se conecta la base de datos.
class RepositorioAulasSimulado implements RepositorioAulas {
  static const _aulas = [
    Aula(id: '1A', nombre: '1ºA'),
    Aula(id: '1B', nombre: '1ºB'),
    Aula(id: '2A', nombre: '2ºA'),
    Aula(id: '2B', nombre: '2ºB'),
  ];

  @override
  Future<List<Aula>> obtenerAulas() async => List.unmodifiable(_aulas);
}
