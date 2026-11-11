import '../../../core/constantes/paleta.dart';
import '../../../core/modelos/recurso_visual.dart';

/// Grupo o clase del centro (HU-16).
class Aula {
  const Aula({
    required this.id,
    required this.nombre,
    this.color = ColorPastel.cielo,
    this.pictograma,
    this.idTutor,
  });

  final String id;
  final String nombre;

  /// Color con el que se reconoce el aula en la pantalla de inicio.
  final ColorPastel color;
  final RecursoVisual? pictograma;

  /// Cuenta del tutor responsable.
  final String? idTutor;

  Aula copyWith({
    String? nombre,
    ColorPastel? color,
    RecursoVisual? pictograma,
    String? idTutor,
    bool quitarTutor = false,
  }) => Aula(
    id: id,
    nombre: nombre ?? this.nombre,
    color: color ?? this.color,
    pictograma: pictograma ?? this.pictograma,
    idTutor: quitarTutor ? null : idTutor ?? this.idTutor,
  );

  Map<String, Object?> toMap() => {
    'nombre': nombre,
    'color': color.name,
    'pictograma': pictograma?.toMap(),
    'idTutor': idTutor,
  };

  factory Aula.fromMap(String id, Map<String, Object?> datos) => Aula(
    id: id,
    nombre: datos['nombre'] as String? ?? '',
    color: ColorPastel.porNombre(datos['color'] as String?),
    pictograma: RecursoVisual.fromMap(datos['pictograma']),
    idTutor: datos['idTutor'] as String?,
  );
}
