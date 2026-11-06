import 'package:flutter/material.dart';

/// Pide una confirmación clara antes de una acción (HU-11).
///
/// Devuelve `true` solo si el usuario pulsa el botón de confirmar.
Future<bool> mostrarDialogoConfirmacion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  String textoConfirmar = 'Sí',
  String textoCancelar = 'No',
}) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje, style: Theme.of(contexto).textTheme.titleLarge),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        OutlinedButton.icon(
          onPressed: () => Navigator.of(contexto).pop(false),
          icon: const Icon(Icons.close),
          label: Text(textoCancelar),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(contexto).pop(true),
          icon: const Icon(Icons.check),
          label: Text(textoConfirmar),
        ),
      ],
    ),
  );
  return confirmado ?? false;
}
