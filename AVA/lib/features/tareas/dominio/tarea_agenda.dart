import '../../../core/constantes/paleta.dart';
import '../../../core/modelos/recurso_visual.dart';

/// Estado de realización de una tarea (HU-12).
enum EstadoTarea {
  pendiente('Por hacer'),
  enCurso('Haciendo'),
  completada('Terminada');

  const EstadoTarea(this.nombre);

  final String nombre;
}

/// Tipo de tarea (RI04). Cada tipo tiene su color para reconocerlo.
enum TipoTarea {
  escolar('Clase', ColorPastel.cielo),
  personal('Personal', ColorPastel.lavanda),
  ocio('Ocio', ColorPastel.amarillo),
  domestica('Casa', ColorPastel.melocoton),
  encargoCentro('Encargo del colegio', ColorPastel.menta);

  const TipoTarea(this.nombre, this.color);

  final String nombre;
  final ColorPastel color;
}

/// Actividad programada en la agenda de un estudiante (RI04).
class Tarea {
  Tarea({
    required this.id,
    required this.idEstudiante,
    required this.titulo,
    required this.inicio,
    required this.fin,
    this.descripcion = '',
    this.pasos = const [],
    this.tipo = TipoTarea.escolar,
    this.estado = EstadoTarea.pendiente,
    this.pictograma,
    this.creadaPor,
    this.idEncargo,
  }) : assert(fin.isAfter(inicio), 'La tarea debe terminar después de empezar');

  final String id;
  final String idEstudiante;
  final String titulo;

  /// Descripción breve en lectura fácil (HU-06).
  final String descripcion;
  final DateTime inicio;
  final DateTime fin;

  /// Instrucciones ordenadas para realizar la tarea (HU-07).
  final List<String> pasos;
  final TipoTarea tipo;
  final EstadoTarea estado;

  /// Pictograma o foto de apoyo (HU-06).
  final RecursoVisual? pictograma;

  /// Cuenta que creó la tarea.
  final String? creadaPor;

  /// Si la tarea viene de un encargo del centro, su identificador (HU-08).
  final String? idEncargo;

  /// Indica si [instante] cae dentro del horario de la tarea.
  bool contiene(DateTime instante) =>
      !instante.isBefore(inicio) && instante.isBefore(fin);

  Tarea copyWith({
    String? titulo,
    String? descripcion,
    DateTime? inicio,
    DateTime? fin,
    List<String>? pasos,
    TipoTarea? tipo,
    EstadoTarea? estado,
    RecursoVisual? pictograma,
    bool quitarPictograma = false,
  }) {
    return Tarea(
      id: id,
      idEstudiante: idEstudiante,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      inicio: inicio ?? this.inicio,
      fin: fin ?? this.fin,
      pasos: pasos ?? this.pasos,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      pictograma: quitarPictograma ? null : pictograma ?? this.pictograma,
      creadaPor: creadaPor,
      idEncargo: idEncargo,
    );
  }

  Map<String, Object?> toMap() => {
    'idEstudiante': idEstudiante,
    'titulo': titulo,
    'descripcion': descripcion,
    'inicio': inicio.toIso8601String(),
    'fin': fin.toIso8601String(),
    'pasos': pasos,
    'tipo': tipo.name,
    'estado': estado.name,
    'pictograma': pictograma?.toMap(),
    'creadaPor': creadaPor,
    'idEncargo': idEncargo,
  };

  factory Tarea.fromMap(String id, Map<String, Object?> datos) => Tarea(
    id: id,
    idEstudiante: datos['idEstudiante']! as String,
    titulo: datos['titulo'] as String? ?? '',
    descripcion: datos['descripcion'] as String? ?? '',
    inicio: DateTime.parse(datos['inicio']! as String),
    fin: DateTime.parse(datos['fin']! as String),
    pasos: [
      for (final paso in datos['pasos'] as List? ?? const []) paso as String,
    ],
    tipo: TipoTarea.values.firstWhere(
      (t) => t.name == datos['tipo'],
      orElse: () => TipoTarea.escolar,
    ),
    estado: EstadoTarea.values.firstWhere(
      (e) => e.name == datos['estado'],
      orElse: () => EstadoTarea.pendiente,
    ),
    pictograma: RecursoVisual.fromMap(datos['pictograma']),
    creadaPor: datos['creadaPor'] as String?,
    idEncargo: datos['idEncargo'] as String?,
  );
}
