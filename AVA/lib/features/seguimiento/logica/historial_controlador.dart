import '../../../core/utilidades/controlador_carga.dart';
import '../../agenda/logica/calculos_agenda.dart';
import '../../tareas/dominio/evento_historial.dart';
import '../../tareas/dominio/repositorio_tareas.dart';
import '../../tareas/dominio/tarea_agenda.dart';

/// Periodo del historial (HU-27).
enum PeriodoHistorial {
  dia('Día'),
  semana('Semana');

  const PeriodoHistorial(this.nombre);

  final String nombre;
}

/// Historial de tareas completadas de un estudiante por día o semana
/// (HU-27, T-126, T-127).
class HistorialControlador extends ControladorCarga<List<EventoHistorial>> {
  HistorialControlador({
    required RepositorioTareas tareas,
    required this.idEstudiante,
    DateTime Function()? reloj,
  }) : _tareas = tareas,
       _referencia = _soloDia((reloj ?? DateTime.now)());

  final RepositorioTareas _tareas;
  final String idEstudiante;

  PeriodoHistorial _periodo = PeriodoHistorial.semana;
  DateTime _referencia;

  PeriodoHistorial get periodo => _periodo;

  static DateTime _soloDia(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Primer día del periodo que se consulta.
  DateTime get desde => _periodo == PeriodoHistorial.dia
      ? _referencia
      : CalculosAgenda.diasDeSemana(_referencia).first;

  /// Día siguiente al último del periodo.
  DateTime get hasta => DateTime(
    desde.year,
    desde.month,
    desde.day + (_periodo == PeriodoHistorial.dia ? 1 : 7),
  );

  /// Tareas completadas del periodo, agrupadas por día y en orden.
  Map<DateTime, List<EventoHistorial>> get completadasPorDia {
    final porDia = <DateTime, List<EventoHistorial>>{};
    for (final evento in datos ?? const <EventoHistorial>[]) {
      if (evento.estadoNuevo == EstadoTarea.completada) {
        porDia.putIfAbsent(_soloDia(evento.dia), () => []).add(evento);
      }
    }
    return porDia;
  }

  @override
  Future<List<EventoHistorial>> obtenerDatos() =>
      _tareas.historial(idEstudiante: idEstudiante, desde: desde, hasta: hasta);

  @override
  String get mensajeErrorCarga => 'No se ha podido cargar el historial.';

  Future<void> cambiarPeriodo(PeriodoHistorial periodo) async {
    _periodo = periodo;
    await cargar();
  }

  /// Pasa al periodo anterior (-1) o al siguiente (1).
  Future<void> mover(int sentido) async {
    final dias = _periodo == PeriodoHistorial.dia ? 1 : 7;
    _referencia = DateTime(
      _referencia.year,
      _referencia.month,
      _referencia.day + sentido * dias,
    );
    await cargar();
  }
}
