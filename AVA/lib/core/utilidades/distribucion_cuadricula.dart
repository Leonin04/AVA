import 'dart:math' as math;

/// Reparto de una cuadrícula en la que caben todos los elementos a la vez.
class DistribucionCuadricula {
  const DistribucionCuadricula({
    required this.columnas,
    required this.filas,
    required this.anchoCelda,
    required this.altoCelda,
  });

  final int columnas;
  final int filas;
  final double anchoCelda;
  final double altoCelda;

  /// Elige el número de columnas que deja las celdas más grandes para
  /// [total] elementos en un espacio de [ancho] × [alto], de modo que todos
  /// quepan sin desplazarse ni pasar de página.
  ///
  /// [proporcion] es la relación ancho/alto deseada de cada celda, y
  /// [altoMaximo] evita celdas desproporcionadamente altas cuando hay pocos
  /// elementos.
  static DistribucionCuadricula calcular({
    required int total,
    required double ancho,
    required double alto,
    required double espaciado,
    int maxColumnas = 6,
    double proporcion = 1,
    double altoMaximo = double.infinity,
  }) {
    final n = math.max(1, total);
    DistribucionCuadricula? mejor;
    var mejorTamano = -1.0;

    for (var columnas = 1; columnas <= math.min(n, maxColumnas); columnas++) {
      final filas = (n / columnas).ceil();
      final anchoCelda = (ancho - espaciado * (columnas - 1)) / columnas;
      final altoCelda = math.min(
        (alto - espaciado * (filas - 1)) / filas,
        altoMaximo,
      );
      // Lado útil de una celda con la proporción deseada.
      final tamano = math.min(anchoCelda / proporcion, altoCelda);
      // Con el mismo tamaño se prefieren más columnas (más a la vista).
      if (tamano >= mejorTamano) {
        mejorTamano = tamano;
        mejor = DistribucionCuadricula(
          columnas: columnas,
          filas: filas,
          anchoCelda: math.max(0, anchoCelda),
          altoCelda: math.max(0, altoCelda),
        );
      }
    }
    return mejor!;
  }

  /// Cuántas celdas de al menos [anchoMinimo] × [altoMinimo] caben en
  /// [ancho] × [alto] (como mínimo 1). Si hay más elementos que esta
  /// cantidad, no se pueden ver todos a la vez sin que queden ilegibles.
  static int capacidad({
    required double ancho,
    required double alto,
    required double espaciado,
    required double anchoMinimo,
    required double altoMinimo,
    int maxColumnas = 6,
  }) {
    final columnas = ((ancho + espaciado) / (anchoMinimo + espaciado))
        .floor()
        .clamp(1, maxColumnas);
    final filas = math.max(
      1,
      ((alto + espaciado) / (altoMinimo + espaciado)).floor(),
    );
    return columnas * filas;
  }
}
