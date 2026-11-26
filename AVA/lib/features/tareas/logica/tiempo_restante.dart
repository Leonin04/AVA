/// Tiempo que queda de una tarea con el temporizador activado (HU-22).
class TiempoRestante {
  const TiempoRestante._(this.restante, this.fraccion);

  /// Calcula lo que queda en [ahora] de una tarea de [inicio] a [fin].
  factory TiempoRestante.en(DateTime ahora, DateTime inicio, DateTime fin) {
    final total = fin.difference(inicio);
    final pasado = ahora.difference(inicio);
    final restante = fin.difference(ahora);
    final fraccion = total.inSeconds <= 0
        ? 0.0
        : 1 - (pasado.inSeconds / total.inSeconds).clamp(0.0, 1.0);
    return TiempoRestante._(
      restante.isNegative ? Duration.zero : restante,
      fraccion,
    );
  }

  /// Tiempo que queda (cero si ya ha pasado la hora de fin).
  final Duration restante;

  /// Parte del tiempo que queda, de 1 (recién empezada) a 0 (terminada).
  final double fraccion;

  bool get acabado => restante == Duration.zero;

  /// Texto sencillo, en minutos mientras quede más de uno.
  String get texto {
    final minutos = restante.inMinutes;
    final String resultado;
    if (acabado) {
      resultado = 'Se ha acabado el tiempo';
    } else if (minutos >= 2) {
      resultado = 'Quedan $minutos minutos';
    } else if (minutos == 1) {
      resultado = 'Queda 1 minuto';
    } else {
      resultado = 'Queda menos de 1 minuto';
    }
    return resultado;
  }
}
