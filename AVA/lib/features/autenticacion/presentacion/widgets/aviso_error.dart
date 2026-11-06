import 'package:flutter/material.dart';

import '../../../../core/constantes/dimensiones.dart';
import '../../../../core/constantes/paleta.dart';
import '../../../../core/tema/ajustes_interfaz.dart';

/// Aviso claro y tranquilo cuando algo no es correcto (HU-08): sin rojo
/// intenso ni sonidos de error (persona Álex), con icono y texto.
/// Los lectores de pantalla lo anuncian al aparecer.
class AvisoError extends StatelessWidget {
  const AvisoError({super.key, required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final estilo = AjustesInterfaz.of(context).estiloDe(ColorPastel.rosa);

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: estilo.fondo,
          borderRadius: BorderRadius.circular(Dimensiones.radioBordePequeno),
          border: Border.all(
            color: estilo.borde,
            width: Dimensiones.grosorBorde,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.info_rounded, color: estilo.acento, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mensaje,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: estilo.texto),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
