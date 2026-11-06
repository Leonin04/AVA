import '../../../core/utilidades/controlador_carga.dart';
import '../../tareas/dominio/repositorio_tareas.dart';
import '../../tareas/dominio/tarea.dart';
import 'calculos_agenda.dart';

/// Carga las tareas de una semana del estudiante y las organiza para las
/// distintas vistas de la agenda (HU-09 y HU-10).
class AgendaControlador extends ControladorCarga<List<Tarea>> {
  AgendaControlador({
    required RepositorioTareas repositorio,
    required String idEstudiante,
    DateTime? diaReferencia,
    DateTime Function()? reloj,
  })  : _repositorio = repositorio,
        _idEstudiante = idEstudiante,
        _diaReferencia = diaReferencia,
        _reloj = reloj ?? DateTime.now;

  final RepositorioTareas _repositorio;
  final String _idEstudiante;

  /// Día cuya semana se carga. Si es `null`, se usa la semana actual.
  final DateTime? _diaReferencia;

  /// Permite fijar la hora en las pruebas.
  final DateTime Function() _reloj;

  DateTime get ahora => _reloj();

  List<DateTime> get diasSemana =>
      CalculosAgenda.diasDeSemana(_diaReferencia ?? ahora);

  List<Tarea> get _tareasSemana => datos ?? const [];

  List<Tarea> tareasDelDia(DateTime dia) =>
      CalculosAgenda.tareasDelDia(_tareasSemana, dia);

  Tarea? get tareaActual => CalculosAgenda.tareaActual(_tareasSemana, ahora);

  Tarea? get siguienteTarea =>
      CalculosAgenda.siguienteTarea(_tareasSemana, ahora);

  @override
  Future<List<Tarea>> obtenerDatos() {
    final dias = diasSemana;
    final ultimo = dias.last;
    return _repositorio.obtenerTareas(
      idEstudiante: _idEstudiante,
      desde: dias.first,
      hasta: DateTime(ultimo.year, ultimo.month, ultimo.day + 1),
    );
  }

  @override
  String get mensajeErrorCarga => 'No se ha podido cargar la agenda.';
}
