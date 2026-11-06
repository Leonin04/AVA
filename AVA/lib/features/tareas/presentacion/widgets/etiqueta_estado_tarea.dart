import 'package:flutter/material.dart';

import '../../dominio/tarea.dart';

/// Icono y texto del estado de una tarea.
class EtiquetaEstadoTarea extends StatelessWidget {
  const EtiquetaEstadoTarea({super.key, required this.estado});

  final EstadoTarea estado;

  @override
  Widget build(BuildContext context) {
    final icono = switch (estado) {
      EstadoTarea.pendiente => Icons.radio_button_unchecked,
      EstadoTarea.enCurso => Icons.play_circle,
      EstadoTarea.completada => Icons.check_circle,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(estado.nombre, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
