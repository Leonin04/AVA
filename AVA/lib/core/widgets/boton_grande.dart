import 'package:flutter/material.dart';

import '../constantes/dimensiones.dart';

/// Botón de gran tamaño, fácil de pulsar, usado en los menús principales.
class BotonGrande extends StatelessWidget {
  const BotonGrande({
    super.key,
    required this.texto,
    required this.alPulsar,
    this.icono,
    this.alto = Dimensiones.altoBotonGrande,
  });

  final String texto;
  final IconData? icono;
  final VoidCallback? alPulsar;
  final double? alto;

  @override
  Widget build(BuildContext context) {
    final contenido = Text(texto, textAlign: TextAlign.center);

    return SizedBox(
      width: double.infinity,
      height: alto,
      child: icono == null
          ? FilledButton(onPressed: alPulsar, child: contenido)
          : FilledButton.icon(
              onPressed: alPulsar,
              icon: Icon(icono, size: 36),
              label: contenido,
            ),
    );
  }
}
