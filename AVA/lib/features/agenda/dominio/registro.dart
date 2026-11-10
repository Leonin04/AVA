import 'package:cloud_firestore/cloud_firestore.dart';

/// Estado de una tarea en un día concreto (HU-11, HU-12).
enum EstadoTarea { pendiente, iniciada, terminada }

/// Documento `estudiantes/{uid}/registros/{fecha_tareaId}`.
/// Un registro por tarea y día: cuándo empezó y cuándo terminó.
class Registro {
  final String tareaId;
  final String fecha; // "yyyy-MM-dd"
  final EstadoTarea estado;
  final DateTime? inicio;
  final DateTime? fin;

  const Registro({
    required this.tareaId,
    required this.fecha,
    this.estado = EstadoTarea.pendiente,
    this.inicio,
    this.fin,
  });

  /// Id del documento: un registro por tarea y día.
  static String idPara(String fecha, String tareaId) => '${fecha}_$tareaId';

  String get id => idPara(fecha, tareaId);

  factory Registro.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Registro(
      tareaId: d['tareaId'] as String? ?? '',
      fecha: d['fecha'] as String? ?? '',
      estado: EstadoTarea.values.byName(d['estado'] as String? ?? 'pendiente'),
      inicio: (d['inicio'] as Timestamp?)?.toDate(),
      fin: (d['fin'] as Timestamp?)?.toDate(),
    );
  }
}
