import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constantes/dimensiones.dart';
import '../tema/ajustes_interfaz.dart';
import '../utilidades/distribucion_cuadricula.dart';
import '../utilidades/medida_texto.dart';
import 'barra_paginas.dart';

/// Cuadrícula que reparte los elementos en el espacio disponible sin
/// desplazamiento.
///
/// Por defecto todos los elementos se ven a la vez, lo más fácil para
/// alumnado con dificultades motoras o de atención: si hay muchos, las
/// celdas se hacen más pequeñas.
///
/// Con [permitirPaginas] (pantallas con muchas opciones, como el perfil),
/// si no caben con celdas de al menos [anchoMinimoCelda] × [altoMinimoCelda]
/// (multiplicado por el tamaño de letra elegido), en lugar de hacerlos
/// ilegibles se reparten en páginas con «Anterior» y «Siguiente».
class CuadriculaAjustada<T> extends StatefulWidget {
  const CuadriculaAjustada({
    super.key,
    required this.elementos,
    required this.constructor,
    this.anchoMinimoCelda = 220,
    this.altoMinimoCelda = 180,
    this.altoMaximoCelda = 320,
    this.maxColumnas = 4,
    this.espaciado = Dimensiones.espaciado,
    this.permitirPaginas = false,
    this.textosDe,
  });

  /// Lado mínimo del pictograma que se reserva al calcular la letra común.
  static const _imagenMinima = 32.0;

  /// Letra común que la cuadrícula ha calculado para sus celdas (ver
  /// [textosDe]), para pasarla a [BotonAccesible.tamanoTexto].
  static double? letraDe(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_LetraComun>()?.tamano;

  final List<T> elementos;
  final Widget Function(BuildContext context, T elemento) constructor;

  /// Tamaño mínimo legible de cada celda con letra normal. También marca la
  /// proporción deseada de las celdas.
  final double anchoMinimoCelda;
  final double altoMinimoCelda;
  final double altoMaximoCelda;
  final int maxColumnas;
  final double espaciado;

  /// Repartir en páginas si no caben legibles. Solo para pantallas con
  /// muchas opciones; el resto muestra siempre todo junto.
  final bool permitirPaginas;

  /// Textos de cada celda. Si se indica, todas las celdas usan la misma
  /// letra (la mayor con la que caben todas, leída con [letraDe]), y si no
  /// llega a la mínima legible se ponen menos celdas por página.
  final TextosTarjeta Function(T elemento)? textosDe;

  @override
  State<CuadriculaAjustada<T>> createState() => _CuadriculaAjustadaState<T>();
}

class _CuadriculaAjustadaState<T> extends State<CuadriculaAjustada<T>> {
  int _pagina = 0;

  /// Letra común a todas las celdas cuando hay [porPagina] por página en
  /// [ancho] × [alto], o `null` si la cuadrícula no tiene [textosDe]. Se
  /// reserva sitio para un pictograma pequeño si se muestran dibujos.
  double? _letraComun(
    BuildContext context, {
    required int porPagina,
    required double ancho,
    required double alto,
    required double escala,
  }) {
    final textosDe = widget.textosDe;
    final estilo = Theme.of(context).textTheme.titleLarge;
    double? letra;
    if (textosDe != null && estilo != null) {
      final reparto = DistribucionCuadricula.calcular(
        total: porPagina,
        ancho: ancho,
        alto: alto,
        espaciado: widget.espaciado,
        maxColumnas: widget.maxColumnas,
        proporcion: widget.anchoMinimoCelda / widget.altoMinimoCelda,
        altoMaximo: widget.altoMaximoCelda * escala,
      );
      const relleno = 2 * Dimensiones.rellenoCompacto;
      final reservaImagen = AjustesInterfaz.of(context).mostrarPictogramas
          ? CuadriculaAjustada._imagenMinima
          : 0.0;
      letra = MedidaTexto.tamanoComun(
        tarjetas: widget.elementos.map(textosDe),
        estilo: estilo,
        escala: MediaQuery.textScalerOf(context),
        ancho: reparto.anchoCelda - relleno,
        alto: reparto.altoCelda - relleno - reservaImagen,
        maximo: estilo.fontSize ?? 22,
      );
    }
    return letra;
  }

  @override
  Widget build(BuildContext context) {
    final escala = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    final total = widget.elementos.length;

    return total == 0
        ? const SizedBox.shrink()
        : LayoutBuilder(
            builder: (context, restricciones) {
              final ancho = restricciones.maxWidth;
              final alto = restricciones.maxHeight;
              int capacidadEn(double altoDisponible) =>
                  DistribucionCuadricula.capacidad(
                    ancho: ancho,
                    alto: altoDisponible,
                    espaciado: widget.espaciado,
                    anchoMinimo: math.min(
                      widget.anchoMinimoCelda * escala,
                      ancho,
                    ),
                    altoMinimo: math.min(
                      widget.altoMinimoCelda * escala,
                      altoDisponible,
                    ),
                    maxColumnas: widget.maxColumnas,
                  );

              double? letraCon(int porPagina, double altoDisponible) =>
                  _letraComun(
                    context,
                    porPagina: porPagina,
                    ancho: ancho,
                    alto: altoDisponible,
                    escala: escala,
                  );
              bool legible(int porPagina, double altoDisponible) =>
                  (letraCon(porPagina, altoDisponible) ??
                      Dimensiones.letraMinimaLegible) >=
                  Dimensiones.letraMinimaLegible;

              final paginar =
                  widget.permitirPaginas &&
                  (total > capacidadEn(alto) || !legible(total, alto));
              final altoCuadricula = paginar
                  ? alto - Dimensiones.altoBarraPaginas - widget.espaciado
                  : alto;
              var porPagina = paginar
                  ? math.min(capacidadEn(altoCuadricula), total)
                  : total;
              while (paginar &&
                  porPagina > 1 &&
                  !legible(porPagina, altoCuadricula)) {
                porPagina--;
              }
              final letra = letraCon(porPagina, altoCuadricula);
              final totalPaginas = math.max(1, (total / porPagina).ceil());
              final pagina = _pagina.clamp(0, totalPaginas - 1);
              final visibles = widget.elementos
                  .skip(pagina * porPagina)
                  .take(porPagina)
                  .toList();

              return Column(
                children: [
                  Expanded(
                    child: _LetraComun(
                      tamano: letra,
                      child: _Rejilla<T>(
                        elementos: visibles,
                        // Todas las páginas usan las mismas celdas, para que nada
                        // cambie de tamaño al pasar de página.
                        huecos: porPagina,
                        cuadricula: widget,
                        escala: escala,
                      ),
                    ),
                  ),
                  if (paginar) ...[
                    SizedBox(height: widget.espaciado),
                    BarraPaginas(
                      pagina: pagina,
                      totalPaginas: totalPaginas,
                      alCambiar: (nueva) => setState(() => _pagina = nueva),
                    ),
                  ],
                ],
              );
            },
          );
  }
}

class _Rejilla<T> extends StatelessWidget {
  const _Rejilla({
    required this.elementos,
    required this.huecos,
    required this.cuadricula,
    required this.escala,
  });

  final List<T> elementos;
  final int huecos;
  final CuadriculaAjustada<T> cuadricula;
  final double escala;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final reparto = DistribucionCuadricula.calcular(
          total: huecos,
          ancho: restricciones.maxWidth,
          alto: restricciones.maxHeight,
          espaciado: cuadricula.espaciado,
          maxColumnas: cuadricula.maxColumnas,
          proporcion: cuadricula.anchoMinimoCelda / cuadricula.altoMinimoCelda,
          altoMaximo: cuadricula.altoMaximoCelda * escala,
        );
        final filas = math.max(1, (elementos.length / reparto.columnas).ceil());

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var fila = 0; fila < filas; fila++) ...[
                if (fila > 0) SizedBox(height: cuadricula.espaciado),
                SizedBox(
                  height: reparto.altoCelda,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var col = 0; col < reparto.columnas; col++) ...[
                        if (col > 0) SizedBox(width: cuadricula.espaciado),
                        Expanded(
                          child: _celda(context, fila * reparto.columnas + col),
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

  Widget _celda(BuildContext context, int indice) => indice < elementos.length
      ? cuadricula.constructor(context, elementos[indice])
      : const SizedBox.shrink();
}

/// Letra común de las celdas de una [CuadriculaAjustada].
class _LetraComun extends InheritedWidget {
  const _LetraComun({required this.tamano, required super.child});

  final double? tamano;

  @override
  bool updateShouldNotify(_LetraComun oldWidget) => tamano != oldWidget.tamano;
}
