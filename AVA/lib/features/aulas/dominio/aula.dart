import 'package:cloud_firestore/cloud_firestore.dart';

/// Documento `aulas/{aulaId}` (HU-16).
class Aula {
  final String id;
  final String nombre;
  final String tutorResponsable; // uid

  const Aula({
    required this.id,
    required this.nombre,
    required this.tutorResponsable,
  });

  factory Aula.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Aula(
      id: doc.id,
      nombre: d['nombre'] as String? ?? '',
      tutorResponsable: d['tutorResponsable'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'tutorResponsable': tutorResponsable,
      };
}
