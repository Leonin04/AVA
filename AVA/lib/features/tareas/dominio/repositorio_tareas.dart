import 'evento_historial.dart';
import 'tarea_agenda.dart';

/// Acceso a las tareas de los estudiantes.
///
/// Implementaciones: `RepositorioTareasSimulado` (pruebas) y
/// `RepositorioTareasFirebase` (Cloud Firestore).
///
/// Una tarea que se repite (HU-14) se devuelve una vez por cada día que le
/// toca, con identificador `{idTarea}|{yyyy-MM-dd}`. Al guardar una de esas
/// apariciones se cambia la tarea entera: las próximas apariciones cambian y
/// lo ya registrado en el historial se conserva.
abstract interface class RepositorioTareas {
  /// Tareas del estudiante que empiezan en el intervalo [desde, hasta),
  /// ordenadas por hora de inicio.
  Future<List<Tarea>> obtenerTareas({
    required String idEstudiante,
    required DateTime desde,
    required DateTime hasta,
  });

  /// Crea o actualiza una tarea (HU-04 a HU-07, HU-14).
  Future<void> guardar(Tarea tarea);

  /// Crea un encargo del centro (HU-08) a partir de [plantilla] para
  /// [idsEstudiantes] o, si se indica, para toda el aula [idAula].
  Future<void> crearEncargo(
    Tarea plantilla, {
    required Set<String> idsEstudiantes,
    String? idAula,
  });

  Future<void> eliminar(String idTarea);

  /// Guarda el nuevo estado de una tarea, añade el cambio al historial y
  /// devuelve la tarea actualizada (HU-12, HU-26, T-124). [idActor] es la
  /// cuenta que hace el cambio.
  Future<Tarea> actualizarEstado(
    String idTarea,
    EstadoTarea estado, {
    OrigenCambio origen = OrigenCambio.estudiante,
    String? idActor,
  });

  /// Guarda por qué paso va el estudiante (HU-21, T-109).
  Future<Tarea> guardarPasoActual(String idTarea, int paso);

  /// Cambios de estado de las tareas del estudiante entre [desde] y
  /// [hasta] (sin incluir), del más antiguo al más reciente (HU-27).
  Future<List<EventoHistorial>> historial({
    required String idEstudiante,
    required DateTime desde,
    required DateTime hasta,
  });

  /// Identificador libre para una tarea o un encargo nuevo.
  String nuevoId(String prefijo);
}
