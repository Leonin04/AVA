/// Almacén de documentos en memoria que imita a Cloud Firestore.
///
/// Los datos se organizan en colecciones de documentos (`Map`) con un
/// identificador, igual que en Firestore. Así, los modelos ya tienen su
/// `toMap`/`fromMap` y los repositorios simulados se podrán sustituir por
/// los de Firebase sin cambiar el formato de los datos.
///
/// Todo se pierde al cerrar la aplicación.
class AlmacenSimulado {
  final Map<String, Map<String, Map<String, Object?>>> _colecciones = {};
  int _contador = 0;

  Map<String, Map<String, Object?>> _coleccion(String nombre) =>
      _colecciones.putIfAbsent(nombre, () => {});

  /// Documento [id] de [coleccion], o `null` si no existe.
  Map<String, Object?>? obtener(String coleccion, String id) {
    final documento = _coleccion(coleccion)[id];
    return documento == null ? null : Map.of(documento);
  }

  bool existe(String coleccion, String id) =>
      _coleccion(coleccion).containsKey(id);

  /// Documentos de [coleccion] que cumplen [donde] (todos si es `null`).
  /// Cada documento se devuelve junto a su identificador.
  List<(String id, Map<String, Object?> datos)> listar(
    String coleccion, {
    bool Function(Map<String, Object?> datos)? donde,
  }) {
    return [
      for (final MapEntry(:key, :value) in _coleccion(coleccion).entries)
        if (donde == null || donde(value)) (key, Map.of(value)),
    ];
  }

  void guardar(String coleccion, String id, Map<String, Object?> datos) {
    _coleccion(coleccion)[id] = Map.of(datos);
  }

  void eliminar(String coleccion, String id) {
    _coleccion(coleccion).remove(id);
  }

  /// Identificador nuevo y único, por ejemplo `tarea-12`.
  String nuevoId(String prefijo) => '$prefijo-${++_contador}';
}
