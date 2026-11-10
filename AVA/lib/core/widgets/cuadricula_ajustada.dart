import 'package:flutter/material.dart';

import '../constantes/dimensiones.dart';
import '../utilidades/distribucion_cuadricula.dart';

/// Cuadrícula en la que siempre caben todos los elementos a la vez.
///
/// Calcula cuántas columnas y filas dejan las celdas más grandes en el
/// espacio disponible. No hay desplazamiento ni páginas: todo se ve de un
/// vistazo, que es lo más fácil para alumnado con dificultades motoras o
/// de atención. Si hay muchos elementos, las celdas se hacen más pequeñas y
/// su contenido se reduce sin cortarse.
class CuadriculaAjustada<T> extends StatelessWidget {
  const CuadriculaAjustada({
    super.key,
    required this.elementos,
    required this.constructor,
    this.anchoMinimoCelda = 220,
    this.altoMinimoCelda = 180,
    this.altoMaximoCelda = 320,
    this.maxColumnas = 4,
    this.espaciado = Dimensiones.espaciado,
  });

  final List<T> elementos;
  final Widget Function(BuildContext context, T elemento) constructor;

  /// Junto con [altoMinimoCelda], marca la proporción deseada de cada celda.
  final double anchoMinimoCelda;
  final double altoMinimoCelda;
  final double altoMaximoCelda;
  final int maxColumnas;
  final double espaciado;

  @override
  Widget build(BuildContext context) {
    if (elementos.isEmpty) return const SizedBox.shrink();
    final escala = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);

    return LayoutBuilder(
      builder: (context, restricciones) {
        final reparto = DistribucionCuadricula.calcular(
          total: elementos.length,
          ancho: restricciones.maxWidth,
          alto: restricciones.maxHeight,
          espaciado: espaciado,
          maxColumnas: maxColumnas,
          proporcion: anchoMinimoCelda / altoMinimoCelda,
          altoMaximo: altoMaximoCelda * escala,
        );

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var fila = 0; fila < reparto.filas; fila++) ...[
                if (fila > 0) SizedBox(height: espaciado),
                SizedBox(
                  height: reparto.altoCelda,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var col = 0; col < reparto.columnas; col++) ...[
                        if (col > 0) SizedBox(width: espaciado),
                        Expanded(
                          child: _indice(fila, col, reparto) < elementos.length
                              ? constructor(
                                  context,
                                  elementos[_indice(fila, col, reparto)],
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  int _indice(int fila, int columna, DistribucionCuadricula reparto) =>
      fila * reparto.columnas + columna;
}
