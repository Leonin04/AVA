import 'tarea_agenda.dart';

/// Quién ha cambiado el estado de una tarea (HU-26, HU-27).
enum OrigenCambio {
  estudiante('El alumno'),
  tutor('El tutor'),
  sistema('Automático');

  const OrigenCambio(this.nombre);

  final String nombre;

  static OrigenCambio desde(Object? valor) => OrigenCambio.values.firstWhere(
    (origen) => origen.name == valor,
    orElse: () => OrigenCambio.estudiante,
  );
}

/// Un cambio de estado de una tarea en un día concreto (HU-27).
///
/// Cada cambio se añade al historial sin borrar los anteriores, así se puede
/// consultar qué hizo el alumno cada día o cada semana.
class EventoHistorial {
  const EventoHistorial({
    required this.idEstudiante,
    required this.idTarea,
    required this.tituloTarea,
    required this.dia,
    required this.estadoNuevo,
    required this.momento,
    required this.origen,
    this.estadoAnterior,
    this.idActor,
  });

  final String idEstudiante;

  /// Identificador de la tarea (sin el día).
  final String idTarea;
  final String tituloTarea;

  /// Día al que corresponde la tarea.
  final DateTime dia;
  final EstadoTarea? estadoAnterior;
  final EstadoTarea estadoNuevo;

  /// Cuándo se hizo el cambio.
  final DateTime momento;
  final OrigenCambio origen;

  /// Cuenta que hizo el cambio, o `null` si fue automático.
  final String? idActor;

  Map<String, Object?> toMap() => {
    'idEstudiante': idEstudiante,
    'idTarea': idTarea,
    'tituloTarea': tituloTarea,
    'dia': dia.toIso8601String(),
    'estadoAnterior': estadoAnterior?.name,
    'estadoNuevo': estadoNuevo.name,
    'momento': momento.toIso8601String(),
    'origen': origen.name,
    'idActor': idActor,
  };

  factory EventoHistorial.fromMap(Map<String, Object?> datos) {
    EstadoTarea? estado(Object? nombre) =>
        EstadoTarea.values.where((e) => e.name == nombre).firstOrNull;
    return EventoHistorial(
      idEstudiante: datos['idEstudiante'] as String? ?? '',
      idTarea: datos['idTarea'] as String? ?? '',
      tituloTarea: datos['tituloTarea'] as String? ?? '',
      dia: DateTime.parse(datos['dia']! as String),
      estadoAnterior: estado(datos['estadoAnterior']),
      estadoNuevo: estado(datos['estadoNuevo']) ?? EstadoTarea.pendiente,
      momento: DateTime.parse(datos['momento']! as String),
      origen: OrigenCambio.desde(datos['origen']),
      idActor: datos['idActor'] as String?,
    );
  }
}
