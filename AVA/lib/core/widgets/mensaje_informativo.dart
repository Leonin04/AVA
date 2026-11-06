import 'package:flutter/material.dart';

import '../constantes/dimensiones.dart';

/// Mensaje centrado con icono, para estados vacíos o de error.
class MensajeInformativo extends StatelessWidget {
  const MensajeInformativo({
    super.key,
    required this.icono,
    required this.texto,
    this.textoAccion,
    this.alPulsarAccion,
  });

  final IconData icono;
  final String texto;
  final String? textoAccion;
  final VoidCallback? alPulsarAccion;

  @override
  Widget build(BuildContext context) {
    final textoBoton = textoAccion;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensiones.espaciado),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: Dimensiones.espaciado),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (textoBoton != null && alPulsarAccion != null) ...[
              const SizedBox(height: Dimensiones.espaciado),
              FilledButton(onPressed: alPulsarAccion, child: Text(textoBoton)),
            ],
          ],
        ),
      ),
    );
  }
}
