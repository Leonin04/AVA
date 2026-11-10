import 'package:cloud_firestore/cloud_firestore.dart';

/// Documento `tareas/{tareaId}/pasos/{pasoId}` (RF-15).
class Paso {
  final String id;
  final int orden;
  final String texto;
  final String imagenUrl;

  const Paso({
    required this.id,
    required this.orden,
    required this.texto,
    this.imagenUrl = '',
  });

  factory Paso.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Paso(
      id: doc.id,
      orden: (d['orden'] as num?)?.toInt() ?? 0,
      texto: d['texto'] as String? ?? '',
      imagenUrl: d['imagenUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'orden': orden,
        'texto': texto,
        'imagenUrl': imagenUrl,
      };
}
