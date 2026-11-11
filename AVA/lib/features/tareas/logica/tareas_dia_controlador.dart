import '../../../core/utilidades/controlador_carga.dart';
import '../dominio/repositorio_tareas.dart';
import '../dominio/tarea_agenda.dart';

/// Tareas de un estudiante en un día, para que el tutor las gestione
/// (HU-04 a HU-07).
class TareasDiaControlador extends ControladorCarga<List<Tarea>> {
  TareasDiaControlador({
    required RepositorioTareas repositorio,
    required this.idEstudiante,
    required DateTime dia,
  }) : _repositorio = repositorio,
       _dia = DateTime(dia.year, dia.month, dia.day);

  final RepositorioTareas _repositorio;
  final String idEstudiante;
  DateTime _dia;

  DateTime get dia => _dia;

  Future<void> cambiarDia(DateTime dia) {
    _dia = DateTime(dia.year, dia.month, dia.day);
    return cargar();
  }

  Future<void> diaAnterior() =>
      cambiarDia(DateTime(_dia.year, _dia.month, _dia.day - 1));

  Future<void> diaSiguiente() =>
      cambiarDia(DateTime(_dia.year, _dia.month, _dia.day + 1));

  Future<void> eliminar(Tarea tarea) async {
    await _repositorio.eliminar(tarea.id);
    await cargar();
  }

  @override
  Future<List<Tarea>> obtenerDatos() => _repositorio.obtenerTareas(
    idEstudiante: idEstudiante,
    desde: _dia,
    hasta: DateTime(_dia.year, _dia.month, _dia.day + 1),
  );

  @override
  String get mensajeErrorCarga => 'No se han podido cargar las tareas.';
}
