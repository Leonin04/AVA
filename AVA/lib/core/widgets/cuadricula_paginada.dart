import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constantes/dimensiones.dart';
import '../constantes/paleta.dart';
import '../utilidades/paginacion.dart';
import 'boton_accesible.dart';

/// Cuadrícula que nunca necesita desplazamiento.
///
/// Calcula cuántos elementos caben en el espacio disponible (teniendo en
/// cuenta el tamaño de letra elegido) y, si no caben todos, los reparte en
/// páginas con botones grandes de «Anterior» y «Siguiente». Así se evita
/// el desplazamiento, difícil para personas con dificultades motoras o de
/// atención (COGA: «evitar la sobrecarga», WCAG 2.5.7 sin arrastres).
class CuadriculaPaginada<T> extends StatefulWidget {
  const CuadriculaPaginada({
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
  final double anchoMinimoCelda;
  final double altoMinimoCelda;
  final double altoMaximoCelda;
  final int maxColumnas;
  final double espaciado;

  @override
  State<CuadriculaPaginada<T>> createState() => _CuadriculaPaginadaState<T>();
}

class _CuadriculaPaginadaState<T> extends State<CuadriculaPaginada<T>> {
  static const _altoControles = Dimensiones.objetivoTactilMinimo + 16;

  int _pagina = 0;

  @override
  void didUpdateWidget(CuadriculaPaginada<T> anterior) {
    super.didUpdateWidget(anterior);
    if (anterior.elementos.length != widget.elementos.length) _pagina = 0;
  }

  @override
  Widget build(BuildContext context) {
    final escala = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);

    return LayoutBuilder(
      builder: (context, restricciones) {
        final esp = widget.espaciado;
        final columnas = Paginacion.cuantosCaben(
          disponible: restricciones.maxWidth,
          tamanoMinimo: widget.anchoMinimoCelda * math.sqrt(escala),
          espaciado: esp,
          maximo: widget.maxColumnas,
        );
        final filasSinControles = Paginacion.cuantosCaben(
          disponible: restricciones.maxHeight,
          tamanoMinimo: widget.altoMinimoCelda * escala,
          espaciado: esp,
        );

        final caben = columnas * filasSinControles;
        final paginado = widget.elementos.length > caben;
        final filas = paginado
            ? Paginacion.cuantosCaben(
                disponible: restricciones.maxHeight - _altoControles,
                tamanoMinimo: widget.altoMinimoCelda * escala,
                espaciado: esp,
              )
            : filasSinControles;

        final paginas = Paginacion(
          total: widget.elementos.length,
          porPagina: columnas * filas,
        );
        final pagina = _pagina.clamp(0, paginas.numeroPaginas - 1);
        final visibles = widget.elementos.sublist(
          paginas.inicio(pagina),
          paginas.fin(pagina),
        );

        final filasUsadas = math.max(1, (visibles.length / columnas).ceil());
        final altoRejilla =
            restricciones.maxHeight - (paginado ? _altoControles : 0);
        final altoCelda = math.min(
          (altoRejilla - esp * (filasUsadas - 1)) / filasUsadas,
          widget.altoMaximoCelda * escala,
        );

        return Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var fila = 0; fila < filasUsadas; fila++) ...[
                      if (fila > 0) SizedBox(height: esp),
                      SizedBox(
                        height: altoCelda,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var col = 0; col < columnas; col++) ...[
                              if (col > 0) SizedBox(width: esp),
                              Expanded(
                                child: fila * columnas + col < visibles.length
                                    ? widget.constructor(
                                        context,
                                        visibles[fila * columnas + col],
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
              ),
            ),
            if (paginado)
              _ControlesPagina(
                pagina: pagina,
                totalPaginas: paginas.numeroPaginas,
                alCambiar: (nueva) => setState(() => _pagina = nueva),
              ),
          ],
        );
      },
    );
  }
}

class _ControlesPagina extends StatelessWidget {
  const _ControlesPagina({
    required this.pagina,
    required this.totalPaginas,
    required this.alCambiar,
  });

  final int pagina;
  final int totalPaginas;
  final ValueChanged<int> alCambiar;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        height: Dimensiones.objetivoTactilMinimo,
        child: Row(
          children: [
            Expanded(
              child: BotonAccesible(
                texto: 'Anterior',
                icono: Icons.arrow_back_rounded,
                color: ColorPastel.lavanda,
                disposicion: DisposicionBoton.horizontal,
                alPulsar: pagina > 0 ? () => alCambiar(pagina - 1) : null,
              ),
            ),
            const SizedBox(width: Dimensiones.espaciado),
            Semantics(
              liveRegion: true,
              label: 'Página ${pagina + 1} de $totalPaginas',
              excludeSemantics: true,
              child: Row(
                children: [
                  for (var i = 0; i < totalPaginas; i++)
                    Container(
                      width: i == pagina ? 28 : 16,
                      height: 16,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: i == pagina
                            ? esquema.onSurface
                            : esquema.outlineVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: Dimensiones.espaciado),
            Expanded(
              child: BotonAccesible(
                texto: 'Siguiente',
                icono: Icons.arrow_forward_rounded,
                color: ColorPastel.lavanda,
                disposicion: DisposicionBoton.horizontal,
                alPulsar: pagina < totalPaginas - 1
                    ? () => alCambiar(pagina + 1)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
