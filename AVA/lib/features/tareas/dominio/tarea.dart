import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipo de tarea (T-69).
enum TipoTarea { colegio, personal }

extension TipoTareaTexto on TipoTarea {
  String get texto => switch (this) {
        TipoTarea.colegio => 'Del colegio',
        TipoTarea.personal => 'Personal',
      };
}

/// Documento `tareas/{tareaId}`.
/// Los pasos están en la subcolección `pasos` (ver [Paso]).
///
/// Una tarea se hace:
/// - los días de la semana de [diasSemana] (tarea que se repite, T-73), o
/// - el día concreto de [fecha] si no tiene días (tarea de un solo día).
class Tarea {
  final String id;
  final String nombre; // T-66
  final String pictogramaUrl; // T-70
  final String descripcion; // T-68
  final TipoTarea tipo; // T-69
  final String horaInicio; // "HH:mm" (T-71)
  final String horaFin; // "HH:mm" (T-72)
  final List<int> diasSemana; // 1 = lunes ... 7 = domingo (T-73)
  final String? fecha; // "yyyy-MM-dd" si no se repite
  final String creadaPor; // uid
  final List<String> estudiantes; // uids (T-67)

  const Tarea({
    required this.id,
    required this.nombre,
    this.pictogramaUrl = '',
    this.descripcion = '',
    this.tipo = TipoTarea.colegio,
    required this.horaInicio,
    required this.horaFin,
    this.diasSemana = const [],
    this.fecha,
    required this.creadaPor,
    this.estudiantes = const [],
  });

  /// "2026-11-07" para un [DateTime].
  static String claveFecha(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  bool get seRepite => diasSemana.isNotEmpty;

  /// true si la tarea toca el día indicado (T-81).
  bool esParaDia(DateTime dia) {
    if (seRepite) return diasSemana.contains(dia.weekday);
    return fecha == claveFecha(dia);
  }

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
      fecha: d['fecha'] as String?,
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
        'fecha': seRepite ? null : fecha,
        'creadaPor': creadaPor,
        'estudiantes': estudiantes,
      };
}
