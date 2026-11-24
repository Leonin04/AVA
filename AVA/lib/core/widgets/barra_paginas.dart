import 'package:flutter/material.dart';

import '../constantes/dimensiones.dart';
import '../constantes/paleta.dart';
import 'boton_accesible.dart';

/// Barra para pasar de página cuando el contenido no cabe legible en una
/// sola pantalla: «Anterior», el texto de la página y «Siguiente».
///
/// Los botones mantienen su hueco aunque no aparezcan (primera o última
/// página), para que nada cambie de sitio (WCAG 3.2.3).
class BarraPaginas extends StatelessWidget {
  const BarraPaginas({
    super.key,
    required this.pagina,
    required this.totalPaginas,
    required this.alCambiar,
    this.texto,
  });

  /// Página actual, empezando en 0.
  final int pagina;
  final int totalPaginas;
  final ValueChanged<int> alCambiar;

  /// Texto central. Por defecto, «1 de 3».
  final String? texto;

  @override
  Widget build(BuildContext context) {
    final hayAnterior = pagina > 0;
    final haySiguiente = pagina < totalPaginas - 1;
    final textoPagina = texto ?? '${pagina + 1} de $totalPaginas';

    return SizedBox(
      height: Dimensiones.altoBarraPaginas,
      child: Row(
        children: [
          Expanded(
            child: hayAnterior
                ? BotonAccesible(
                    texto: 'Anterior',
                    etiquetaSemantica: 'Página anterior',
                    icono: Icons.arrow_back_rounded,
                    color: ColorPastel.lavanda,
                    disposicion: DisposicionBoton.horizontal,
                    alPulsar: () => alCambiar(pagina - 1),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    textoPagina,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: haySiguiente
                ? BotonAccesible(
                    texto: 'Siguiente',
                    etiquetaSemantica: 'Página siguiente',
                    icono: Icons.arrow_forward_rounded,
                    color: ColorPastel.menta,
                    disposicion: DisposicionBoton.horizontal,
                    alPulsar: () => alCambiar(pagina + 1),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
