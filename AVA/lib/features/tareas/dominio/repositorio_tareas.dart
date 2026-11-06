import 'tarea.dart';

/// Acceso a las tareas de los estudiantes.
///
/// Al conectar Firebase se implementará con Cloud Firestore.
abstract interface class RepositorioTareas {
  /// Tareas del estudiante que empiezan en el intervalo [desde, hasta),
  /// ordenadas por hora de inicio.
  Future<List<Tarea>> obtenerTareas({
    required String idEstudiante,
    required DateTime desde,
    required DateTime hasta,
  });

  /// Crea o actualiza una tarea (HU-03 a HU-07).
  Future<void> guardar(Tarea tarea);

  Future<void> eliminar(String idTarea);

  /// Guarda el nuevo estado de una tarea y devuelve la tarea actualizada.
  Future<Tarea> actualizarEstado(String idTarea, EstadoTarea estado);

  /// Identificador libre para una tarea o un encargo nuevo.
  String nuevoId(String prefijo);
}
