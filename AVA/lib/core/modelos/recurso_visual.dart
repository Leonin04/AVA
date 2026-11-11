/// Imagen de apoyo de una tarea, un aula o un perfil (HU-06).
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

  static final _urlArasaac = RegExp(r'arasaac\.org/pictograms/(\d+)/');

  /// Recurso a partir de la dirección guardada en la base de datos
  /// (`fotoUrl`, `pictogramaUrl`): si es de ARASAAC se reconoce su número.
  static RecursoVisual? desdeUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final arasaac = _urlArasaac.firstMatch(url);
    return arasaac == null
        ? FotoPropia(url)
        : PictogramaArasaac(int.parse(arasaac.group(1)!));
  }

  /// Dirección que se guarda en la base de datos.
  String get url => switch (this) {
    PictogramaArasaac(:final id) =>
      'https://static.arasaac.org/pictograms/$id/${id}_300.png',
    FotoPropia(:final url) => url,
  };
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

/// Fotografía propia. [url] es una dirección web o, recién elegida y antes
/// de subirla a Cloud Storage, una imagen incrustada
/// (`data:image/...;base64,...`).
final class FotoPropia extends RecursoVisual {
  const FotoPropia(this.url);

  @override
  final String url;

  @override
  Map<String, Object?> toMap() => {'tipo': 'foto', 'url': url};

  @override
  bool operator ==(Object other) => other is FotoPropia && other.url == url;

  @override
  int get hashCode => url.hashCode;
}
