import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipo de tarea (RF-15).
enum TipoTarea { colegio, personal }

/// Documento `tareas/{tareaId}` (RF-15, RF-22).
/// Los pasos están en la subcolección `pasos` (ver [Paso]).
class Tarea {
  final String id;
  final String nombre;
  final String pictogramaUrl;
  final String descripcion;
  final TipoTarea tipo;
  final String horaInicio; // "HH:mm"
  final String horaFin; // "HH:mm"
  final List<int> diasSemana; // 1 = lunes ... 7 = domingo
  final String creadaPor; // uid
  final List<String> estudiantes; // uids

  const Tarea({
    required this.id,
    required this.nombre,
    this.pictogramaUrl = '',
    this.descripcion = '',
    this.tipo = TipoTarea.colegio,
    required this.horaInicio,
    required this.horaFin,
    required this.diasSemana,
    required this.creadaPor,
    this.estudiantes = const [],
  });

  /// true si la tarea toca el día indicado ([DateTime.weekday]: 1 = lunes).
  bool esParaDia(DateTime dia) => diasSemana.contains(dia.weekday);

  factory Tarea.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Tarea(
      id: doc.id,
      nombre: d['nombre'] as String? ?? '',
      pictogramaUrl: d['pictogramaUrl'] as String? ?? '',
      descripcion: d['descripcion'] as String? ?? '',
      tipo: TipoTarea.values.byName(d['tipo'] as String? ?? 'colegio'),
      horaInicio: d['horaInicio'] as String? ?? '00:00',
      horaFin: d['horaFin'] as String? ?? '00:00',
      diasSemana: (d['diasSemana'] as List? ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
      creadaPor: d['creadaPor'] as String? ?? '',
      estudiantes: List<String>.from(d['estudiantes'] as List? ?? const []),
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'pictogramaUrl': pictogramaUrl,
        'descripcion': descripcion,
        'tipo': tipo.name,
        'horaInicio': horaInicio,
        'horaFin': horaFin,
        'diasSemana': diasSemana,
        'creadaPor': creadaPor,
        'estudiantes': estudiantes,
      };
}
