import '../../../core/utilidades/controlador_carga.dart';
import '../../autenticacion/dominio/cuenta.dart';
import '../../autenticacion/logica/permisos.dart';
import '../../aulas/dominio/ficha_aula.dart';
import '../../aulas/dominio/repositorio_aulas.dart';
import '../../avisos/logica/planificador_avisos.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../../perfil/dominio/repositorio_estudiantes.dart';
import '../../tareas/dominio/evento_historial.dart';
import '../../tareas/dominio/repositorio_tareas.dart';
import '../../tareas/dominio/tarea_agenda.dart';

/// Estado y progreso de las tareas de hoy de un estudiante (HU-26).
class ProgresoAlumno {
  const ProgresoAlumno({
    required this.estudiante,
    required this.aula,
    required this.tareas,
    required this.retrasos,
  });

  final Estudiante estudiante;
  final Aula? aula;
  final List<Tarea> tareas;

  /// Tareas que no se han empezado o terminado a tiempo (HU-29).
  final List<AvisoRetraso> retrasos;

  int get total => tareas.length;

  int contar(EstadoTarea estado) =>
      tareas.where((t) => t.estado == estado).length;

  /// Parte de las tareas de hoy ya terminadas, de 0 a 1.
  double get fraccion =>
      total == 0 ? 0 : contar(EstadoTarea.completada) / total;
}

/// Seguimiento del tutor (HU-26): el estado y el progreso de hoy de sus
/// estudiantes asignados (todos, para la administración), con los avisos
/// de las tareas que van con retraso (HU-29).
///
/// Los avisos se calculan cada vez a partir de los registros, así nunca se
/// envía uno incorrecto ni duplicado (T-135).
class SeguimientoControlador extends ControladorCarga<List<ProgresoAlumno>> {
  SeguimientoControlador({
    required RepositorioEstudiantes estudiantes,
    required RepositorioAulas aulas,
    required RepositorioTareas tareas,
    required this.cuenta,
    DateTime Function()? reloj,
  }) : _estudiantes = estudiantes,
       _aulas = aulas,
       _tareas = tareas,
       _reloj = reloj ?? DateTime.now;

  final RepositorioEstudiantes _estudiantes;
  final RepositorioAulas _aulas;
  final RepositorioTareas _tareas;
  final Cuenta cuenta;
  final DateTime Function() _reloj;

  DateTime get ahora => _reloj();

  /// La administración y los tutores del centro pueden confirmar que una
  /// tarea está terminada; los tutores familiares solo la consultan (T-124,
  /// matriz de permisos).
  bool get puedeConfirmar => Permisos.puedeConfirmarTareas(cuenta);

  /// Todos los avisos de retraso, del primero al último.
  List<AvisoRetraso> get avisos => [
    for (final progreso in datos ?? const <ProgresoAlumno>[])
      ...progreso.retrasos,
  ]..sort((a, b) => a.tarea.inicio.compareTo(b.tarea.inicio));

  @override
  Future<List<ProgresoAlumno>> obtenerDatos() async {
    final ahora = _reloj();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final aulas = await _aulas.obtenerAulas();
    final visibles = Permisos.estudiantesVisibles(
      cuenta,
      await _estudiantes.listar(),
      aulas,
    ).where((e) => e.activo);

    final progreso = <ProgresoAlumno>[];
    for (final estudiante in visibles) {
      final tareas = await _tareas.obtenerTareas(
        idEstudiante: estudiante.id,
        desde: hoy,
        hasta: hoy.add(const Duration(days: 1)),
      );
      progreso.add(
        ProgresoAlumno(
          estudiante: estudiante,
          aula: aulas.where((a) => a.id == estudiante.idAula).firstOrNull,
          tareas: tareas,
          retrasos: PlanificadorAvisos.retrasos(
            tareas,
            ahora,
            nombreEstudiante: estudiante.nombre,
          ),
        ),
      );
    }
    return progreso;
  }

  @override
  String get mensajeErrorCarga => 'No se ha podido cargar el seguimiento.';

  /// El tutor confirma que [tarea] está terminada (T-124). Queda en el
  /// historial como hecha por el tutor. Devuelve un mensaje de error o
  /// `null`.
  Future<String?> confirmarTerminada(Tarea tarea) async {
    String? error;
    if (!puedeConfirmar) {
      error = 'Tu cuenta no puede confirmar tareas.';
    } else {
      try {
        await _tareas.actualizarEstado(
          tarea.id,
          EstadoTarea.completada,
          origen: OrigenCambio.tutor,
          idActor: cuenta.id,
        );
        await cargar();
      } on Exception {
        error = 'No se ha podido guardar. Prueba otra vez.';
      }
    }
    return error;
  }
}
