import 'package:flutter/material.dart';

import '../constantes/dimensiones.dart';
import '../modelos/recurso_visual.dart';
import 'pictograma.dart';

/// Mensaje centrado con pictograma o icono, para estados vacíos o de error.
class MensajeInformativo extends StatelessWidget {
  const MensajeInformativo({
    super.key,
    required this.icono,
    required this.texto,
    this.pictograma,
    this.textoAccion,
    this.alPulsarAccion,
  });

  final IconData icono;
  final String texto;
  final RecursoVisual? pictograma;
  final String? textoAccion;
  final VoidCallback? alPulsarAccion;

  @override
  Widget build(BuildContext context) {
    final textoBoton = textoAccion;

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(Dimensiones.espaciado),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Pictograma(
                  recurso: pictograma,
                  tamano: 120,
                  iconoRespaldo: icono,
                  colorRespaldo: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: Dimensiones.espaciado),
                Text(
                  texto,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (textoBoton != null && alPulsarAccion != null) ...[
                  const SizedBox(height: Dimensiones.espaciado),
                  FilledButton(
                    onPressed: alPulsarAccion,
                    child: Text(textoBoton),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
