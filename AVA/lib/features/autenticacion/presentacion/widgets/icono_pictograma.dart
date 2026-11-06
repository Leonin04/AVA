import 'package:flutter/material.dart';

import '../../dominio/pictograma_clave.dart';

/// Representación visual de un pictograma de la clave.
///
/// Provisional: cuando se integre ARASAAC se mostrará su imagen.
class IconoPictograma extends StatelessWidget {
  const IconoPictograma({
    super.key,
    required this.pictograma,
    this.tamano = 48,
  });

  final PictogramaClave pictograma;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final (icono, color) = switch (pictograma) {
      PictogramaClave.sol => (Icons.wb_sunny, const Color(0xFFF9A825)),
      PictogramaClave.luna => (Icons.nightlight_round, const Color(0xFF3949AB)),
      PictogramaClave.estrella => (Icons.star, const Color(0xFFEF6C00)),
      PictogramaClave.corazon => (Icons.favorite, const Color(0xFFD32F2F)),
      PictogramaClave.flor => (Icons.local_florist, const Color(0xFFC2185B)),
      PictogramaClave.coche => (Icons.directions_car, const Color(0xFF1976D2)),
    };
    return Icon(
      icono,
      size: tamano,
      color: color,
      semanticLabel: pictograma.nombre,
    );
  }
}
