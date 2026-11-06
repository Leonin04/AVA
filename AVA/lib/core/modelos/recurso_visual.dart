/// Imagen de apoyo de una tarea, un aula o un perfil (RF-13, HU-05).
///
/// Puede ser un pictograma de ARASAAC o una fotografía propia.
sealed class RecursoVisual {
  const RecursoVisual();

  Map<String, Object?> toMap();

  static RecursoVisual? fromMap(Object? datos) {
    if (datos is! Map) return null;
    return switch (datos['tipo']) {
      'arasaac' => PictogramaArasaac(datos['id']! as int),
      'foto' => FotoPropia(datos['url']! as String),
      _ => null,
    };
  }
}

/// Pictograma de ARASAAC identificado por su número.
final class PictogramaArasaac extends RecursoVisual {
  const PictogramaArasaac(this.id);

  final int id;

  @override
  Map<String, Object?> toMap() => {'tipo': 'arasaac', 'id': id};

  @override
  bool operator ==(Object other) =>
      other is PictogramaArasaac && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Fotografía propia. [url] puede ser una dirección web o, mientras no hay
/// Firebase Storage, una imagen incrustada (`data:image/...;base64,...`).
final class FotoPropia extends RecursoVisual {
  const FotoPropia(this.url);

  final String url;

  @override
  Map<String, Object?> toMap() => {'tipo': 'foto', 'url': url};

  @override
  bool operator ==(Object other) => other is FotoPropia && other.url == url;

  @override
  int get hashCode => url.hashCode;
}
