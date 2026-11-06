import 'package:flutter/material.dart';

import '../constantes/dimensiones.dart';
import '../constantes/paleta.dart';
import '../modelos/recurso_visual.dart';
import '../tema/ajustes_interfaz.dart';
import 'boton_accesible.dart';
import 'pictograma.dart';

/// Pide una confirmación clara antes de una acción (HU-11).
///
/// Muestra la pregunta con pictograma y dos botones grandes y de colores
/// distintos: «No» a la izquierda y «Sí» a la derecha. Si la voz está
/// activada, lee la pregunta. Devuelve `true` solo si se pulsa «Sí».
Future<bool> mostrarDialogoConfirmacion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  RecursoVisual? pictograma,
  String textoConfirmar = 'Sí',
  String textoCancelar = 'No',
}) async {
  final ajustes = AjustesInterfaz.of(context);
  if (ajustes.leerEnVoz) await ajustes.voz.decir('$titulo $mensaje');
  if (!context.mounted) return false;

  final confirmado = await showDialog<bool>(
    context: context,
    builder: (contexto) => Dialog(
      insetPadding: const EdgeInsets.all(48),
      child: Padding(
        padding: const EdgeInsets.all(Dimensiones.espaciado * 1.5),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pictograma != null) ...[
                Pictograma(recurso: pictograma, tamano: 140),
                const SizedBox(height: Dimensiones.espaciadoPequeno),
              ],
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: Theme.of(contexto).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: Theme.of(contexto).textTheme.titleLarge,
              ),
              const SizedBox(height: Dimensiones.espaciado * 1.5),
              SizedBox(
                height: Dimensiones.altoBotonGrande,
                child: Row(
                  children: [
                    Expanded(
                      child: BotonAccesible(
                        texto: textoCancelar,
                        icono: Icons.close_rounded,
                        color: ColorPastel.rosa,
                        disposicion: DisposicionBoton.horizontal,
                        alPulsar: () => Navigator.of(contexto).pop(false),
                      ),
                    ),
                    const SizedBox(width: Dimensiones.espaciado),
                    Expanded(
                      child: BotonAccesible(
                        texto: textoConfirmar,
                        icono: Icons.check_rounded,
                        color: ColorPastel.menta,
                        disposicion: DisposicionBoton.horizontal,
                        alPulsar: () => Navigator.of(contexto).pop(true),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return confirmado ?? false;
}
