import '../../../core/modelos/recurso_visual.dart';
import '../dominio/repositorio_tareas.dart';
import '../dominio/tarea_agenda.dart';
import 'validacion_tareas.dart';

/// Creación de encargos del centro para varios estudiantes o un aula
/// (HU-07).
class EncargosControlador {
  EncargosControlador(this._repositorio);

  final RepositorioTareas _repositorio;

  /// Crea el encargo en la agenda de cada estudiante de [idsEstudiantes].
  /// Devuelve cuántas tareas se han creado. Lanza [ArgumentError] si los
  /// datos no son válidos.
  Future<int> crear({
    required String titulo,
    required DateTime inicio,
    required DateTime fin,
    required Set<String> idsEstudiantes,
    required String creadaPor,
    String descripcion = '',
    List<String> pasos = const [],
    RecursoVisual? pictograma,
  }) async {
    final error =
        ValidacionTareas.titulo(titulo) ??
        ValidacionTareas.horario(inicio, fin) ??
        (idsEstudiantes.isEmpty ? 'Elige al menos un alumno o un aula.' : null);
    if (error != null) throw ArgumentError(error);

    final idEncargo = _repositorio.nuevoId('encargo');
    for (final idEstudiante in idsEstudiantes) {
      await _repositorio.guardar(
        Tarea(
          id: _repositorio.nuevoId('tarea'),
          idEstudiante: idEstudiante,
          titulo: titulo.trim(),
          descripcion: descripcion.trim(),
          pasos: ValidacionTareas.limpiarPasos(pasos),
          inicio: inicio,
          fin: fin,
          tipo: TipoTarea.encargoCentro,
          pictograma: pictograma,
          creadaPor: creadaPor,
          idEncargo: idEncargo,
        ),
      );
    }
    return idsEstudiantes.length;
  }
}
