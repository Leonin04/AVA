/// Estado de realización de una tarea (HU-11).
enum EstadoTarea {
  pendiente('Pendiente'),
  enCurso('En curso'),
  completada('Terminada');

  const EstadoTarea(this.nombre);

  final String nombre;
}

/// Origen de la tarea: personal del estudiante o encargo del centro (HU-07).
enum TipoTarea { personal, encargoCentro }

/// Actividad programada en la agenda de un estudiante.
class Tarea {
  Tarea({
    required this.id,
    required this.idEstudiante,
    required this.titulo,
    required this.inicio,
    required this.fin,
    this.descripcion = '',
    this.pasos = const [],
    this.tipo = TipoTarea.personal,
    this.estado = EstadoTarea.pendiente,
  }) : assert(fin.isAfter(inicio), 'La tarea debe terminar después de empezar');

  final String id;
  final String idEstudiante;
  final String titulo;
  final String descripcion;
  final DateTime inicio;
  final DateTime fin;

  /// Instrucciones ordenadas para realizar la tarea (HU-06).
  final List<String> pasos;
  final TipoTarea tipo;
  final EstadoTarea estado;

  /// Indica si [instante] cae dentro del horario de la tarea.
  bool contiene(DateTime instante) =>
      !instante.isBefore(inicio) && instante.isBefore(fin);

  Tarea copyWith({EstadoTarea? estado}) {
    return Tarea(
      id: id,
      idEstudiante: idEstudiante,
      titulo: titulo,
      descripcion: descripcion,
      inicio: inicio,
      fin: fin,
      pasos: pasos,
      tipo: tipo,
      estado: estado ?? this.estado,
    );
  }
}
