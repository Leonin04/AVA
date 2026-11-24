import '../../../core/constantes/paleta.dart';
import '../../../core/modelos/recurso_visual.dart';

/// Estado de realización de una tarea (HU-12, HU-26).
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

/// Un paso de las instrucciones de una tarea (HU-07, HU-20): una frase
/// corta y, si se quiere, un pictograma o una foto de apoyo.
class PasoTarea {
  const PasoTarea(this.texto, {this.imagen});

  final String texto;
  final RecursoVisual? imagen;

  Map<String, Object?> toMap() => {'texto': texto, 'imagen': imagen?.toMap()};

  /// Acepta también el formato antiguo, en el que cada paso era solo texto.
  static PasoTarea desde(Object? datos) => switch (datos) {
    final String texto => PasoTarea(texto),
    final Map<Object?, Object?> mapa => PasoTarea(
      mapa['texto'] as String? ?? '',
      imagen: RecursoVisual.fromMap(mapa['imagen']),
    ),
    _ => const PasoTarea(''),
  };

  @override
  bool operator ==(Object other) =>
      other is PasoTarea && other.texto == texto && other.imagen == imagen;

  @override
  int get hashCode => Object.hash(texto, imagen);
}

/// Actividad programada en la agenda de un estudiante (RI04).
///
/// Es la tarea de un día concreto. Si se repite cada semana, [diasSemana]
/// dice qué días (1 = lunes … 7 = domingo).
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
    this.diasSemana = const [],
    this.temporizador = false,
    this.avisoMinutos,
    this.pasoActual = 0,
  }) : assert(fin.isAfter(inicio), 'La tarea debe terminar después de empezar');

  final String id;
  final String idEstudiante;
  final String titulo;

  /// Descripción breve en lectura fácil (HU-06).
  final String descripcion;
  final DateTime inicio;
  final DateTime fin;

  /// Instrucciones ordenadas para realizar la tarea (HU-07, HU-20).
  final List<PasoTarea> pasos;
  final TipoTarea tipo;
  final EstadoTarea estado;

  /// Pictograma o foto de apoyo (HU-06).
  final RecursoVisual? pictograma;

  /// Cuenta que creó la tarea.
  final String? creadaPor;

  /// Si la tarea viene de un encargo del centro, su identificador (HU-08).
  final String? idEncargo;

  /// Días en que se repite (HU-14), ordenados. Vacío si es de un solo día.
  final List<int> diasSemana;

  /// El tutor ha activado el temporizador: mientras se hace, el alumno ve
  /// cuánto tiempo queda (HU-22).
  final bool temporizador;

  /// Minutos de antelación del aviso previo, o `null` si no hay aviso
  /// (HU-28).
  final int? avisoMinutos;

  /// Paso por el que va el estudiante (0 = el primero). Se guarda al
  /// confirmar cada paso (HU-21).
  final int pasoActual;

  bool get seRepite => diasSemana.isNotEmpty;

  /// Indica si [instante] cae dentro del horario de la tarea.
  bool contiene(DateTime instante) =>
      !instante.isBefore(inicio) && instante.isBefore(fin);

  Tarea copyWith({
    String? titulo,
    String? descripcion,
    DateTime? inicio,
    DateTime? fin,
    List<PasoTarea>? pasos,
    TipoTarea? tipo,
    EstadoTarea? estado,
    RecursoVisual? pictograma,
    bool quitarPictograma = false,
    List<int>? diasSemana,
    bool? temporizador,
    int? avisoMinutos,
    bool quitarAviso = false,
    int? pasoActual,
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
      diasSemana: diasSemana ?? this.diasSemana,
      temporizador: temporizador ?? this.temporizador,
      avisoMinutos: quitarAviso ? null : avisoMinutos ?? this.avisoMinutos,
      pasoActual: pasoActual ?? this.pasoActual,
    );
  }

  Map<String, Object?> toMap() => {
    'idEstudiante': idEstudiante,
    'titulo': titulo,
    'descripcion': descripcion,
    'inicio': inicio.toIso8601String(),
    'fin': fin.toIso8601String(),
    'pasos': [for (final paso in pasos) paso.toMap()],
    'tipo': tipo.name,
    'estado': estado.name,
    'pictograma': pictograma?.toMap(),
    'creadaPor': creadaPor,
    'idEncargo': idEncargo,
    'diasSemana': diasSemana,
    'temporizador': temporizador,
    'avisoMinutos': avisoMinutos,
    'pasoActual': pasoActual,
  };

  factory Tarea.fromMap(String id, Map<String, Object?> datos) => Tarea(
    id: id,
    idEstudiante: datos['idEstudiante']! as String,
    titulo: datos['titulo'] as String? ?? '',
    descripcion: datos['descripcion'] as String? ?? '',
    inicio: DateTime.parse(datos['inicio']! as String),
    fin: DateTime.parse(datos['fin']! as String),
    pasos: [
      for (final paso in datos['pasos'] as List? ?? const [])
        PasoTarea.desde(paso),
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
    diasSemana: [
      for (final dia in datos['diasSemana'] as List? ?? const [])
        (dia as num).toInt(),
    ],
    temporizador: datos['temporizador'] as bool? ?? false,
    avisoMinutos: (datos['avisoMinutos'] as num?)?.toInt(),
    pasoActual: (datos['pasoActual'] as num?)?.toInt() ?? 0,
  );
}
