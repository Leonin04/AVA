import '../constantes/pictogramas.dart';
import '../modelos/recurso_visual.dart';

/// Parte del día, para quien no lee la hora en un reloj (persona Álex).
enum MomentoDia {
  manana('Por la mañana', Pictogramas.manana),
  mediodia('A mediodía', Pictogramas.mediodia),
  tarde('Por la tarde', Pictogramas.tarde),
  noche('Por la noche', Pictogramas.noche);

  const MomentoDia(this.nombre, this.pictograma);

  final String nombre;
  final PictogramaArasaac pictograma;

  static MomentoDia de(DateTime fecha) => switch (fecha.hour) {
    < 12 => MomentoDia.manana,
    < 15 => MomentoDia.mediodia,
    < 20 => MomentoDia.tarde,
    _ => MomentoDia.noche,
  };
}

/// Formateo de fechas y horas en español, sin depender de paquetes externos.
abstract final class FormatoFecha {
  static const _dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  static const _meses = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  /// Ejemplo: `09:30`.
  static String hora(DateTime fecha) =>
      '${_dosCifras(fecha.hour)}:${_dosCifras(fecha.minute)}';

  /// Ejemplo: `09:30 - 11:00`.
  static String intervalo(DateTime inicio, DateTime fin) =>
      '${hora(inicio)} - ${hora(fin)}';

  /// Hora dicha en voz: `de 9:30 a 11:00`.
  static String intervaloHablado(DateTime inicio, DateTime fin) =>
      'de ${inicio.hour}:${_dosCifras(inicio.minute)} '
      'a ${fin.hour}:${_dosCifras(fin.minute)}';

  /// Ejemplo: `Lunes`.
  static String nombreDia(DateTime fecha) => _dias[fecha.weekday - 1];

  /// Ejemplo: `Lunes 9 de noviembre`.
  static String diaCompleto(DateTime fecha) =>
      '${nombreDia(fecha)} ${fecha.day} de ${_meses[fecha.month - 1]}';

  /// Ejemplo: `9/11/2026`.
  static String fechaCorta(DateTime fecha) =>
      '${fecha.day}/${fecha.month}/${fecha.year}';

  static String _dosCifras(int valor) => valor.toString().padLeft(2, '0');
}
