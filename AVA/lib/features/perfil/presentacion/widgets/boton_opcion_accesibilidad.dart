import 'package:flutter/material.dart';

import '../../../../core/constantes/dimensiones.dart';

/// Botón con pictograma para activar una opción de accesibilidad. Cuando
/// está seleccionado se resalta con un borde grueso y una marca.
class BotonOpcionAccesibilidad extends StatelessWidget {
  const BotonOpcionAccesibilidad({
    super.key,
    required this.icono,
    required this.texto,
    required this.seleccionada,
    required this.alPulsar,
    this.colorIcono,
  });

  final IconData icono;
  final String texto;
  final bool seleccionada;
  final VoidCallback alPulsar;
  final Color? colorIcono;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final radio = BorderRadius.circular(Dimensiones.radioBorde);

    return Semantics(
      button: true,
      toggled: seleccionada,
      label: texto,
      excludeSemantics: true,
      child: SizedBox(
        width: 180,
        child: Material(
          color: seleccionada
              ? esquema.primaryContainer
              : esquema.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: radio,
            side: BorderSide(
              color: seleccionada ? esquema.primary : Colors.transparent,
              width: 4,
            ),
          ),
          child: InkWell(
            onTap: alPulsar,
            borderRadius: radio,
            child: Padding(
              padding: const EdgeInsets.all(Dimensiones.espaciado),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icono, size: 64, color: colorIcono ?? esquema.primary),
                  const SizedBox(height: Dimensiones.espaciadoPequeno),
                  Text(
                    texto,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    seleccionada ? Icons.check_circle : Icons.circle_outlined,
                    color: esquema.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
