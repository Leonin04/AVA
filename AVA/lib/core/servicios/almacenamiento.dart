import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Subida de imágenes a Cloud Storage (HU-06, HU-19).
///
/// Para elegir la imagen desde la galería o la cámara, usar el paquete
/// `image_picker` y pasar aquí sus bytes:
///
/// ```dart
/// final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800);
/// if (x != null) {
///   final url = await Almacenamiento().subirFotoEstudiante(id, await x.readAsBytes());
/// }
/// ```
class Almacenamiento {
  Almacenamiento({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// T-51: sube la foto de un estudiante y devuelve su URL.
  /// Después hay que guardarla con `BaseDatos.actualizarPerfil(e.copyWith(fotoUrl: url))`.
  Future<String> subirFotoEstudiante(String estudianteId, Uint8List bytes,
          {String tipo = 'image/jpeg'}) =>
      _subir('estudiantes/$estudianteId/foto_${DateTime.now().millisecondsSinceEpoch}.jpg',
          bytes, tipo);

  /// HU-06: sube una imagen propia para una tarea o un paso y devuelve su URL.
  Future<String> subirImagenTarea(String tareaId, Uint8List bytes,
          {String tipo = 'image/jpeg'}) =>
      _subir('tareas/$tareaId/${DateTime.now().millisecondsSinceEpoch}.jpg',
          bytes, tipo);

  Future<String> _subir(String ruta, Uint8List bytes, String tipo) async {
    final ref = _storage.ref(ruta);
    await ref.putData(bytes, SettableMetadata(contentType: tipo));
    return ref.getDownloadURL();
  }
}
