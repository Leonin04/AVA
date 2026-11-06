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

  /// Ejemplo: `Lunes`.
  static String nombreDia(DateTime fecha) => _dias[fecha.weekday - 1];

  /// Ejemplo: `Lunes 9 de noviembre`.
  static String diaCompleto(DateTime fecha) =>
      '${nombreDia(fecha)} ${fecha.day} de ${_meses[fecha.month - 1]}';

  static String _dosCifras(int valor) => valor.toString().padLeft(2, '0');
}
