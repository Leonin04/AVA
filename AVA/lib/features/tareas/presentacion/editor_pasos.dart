import 'package:flutter/material.dart';

import '../logica/formulario_tarea.dart';

/// Lista de pasos de una tarea: añadir (T-74), editar (T-75),
/// eliminar (T-76) y reordenar arrastrando (T-77).
class EditorPasos extends StatelessWidget {
  const EditorPasos({super.key, required this.formulario});

  final FormularioTarea formulario;

  @override
  Widget build(BuildContext context) {
    final pasos = formulario.pasos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pasos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Esta tarea todavía no tiene pasos.'),
          ),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorder: formulario.reordenarPaso,
          children: [
            for (var i = 0; i < pasos.length; i++)
              Padding(
                key: ValueKey(pasos[i].clave),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: i,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.drag_indicator, semanticLabel: 'Mover paso'),
                      ),
                    ),
                    CircleAvatar(radius: 14, child: Text('${i + 1}')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: pasos[i].texto,
                        decoration: InputDecoration(labelText: 'Paso ${i + 1}'),
                        onChanged: (t) => formulario.editarPaso(i, t),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Eliminar paso',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => formulario.eliminarPaso(i),
                    ),
                  ],
                ),
              ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: formulario.anadirPaso,
            icon: const Icon(Icons.add),
            label: const Text('Añadir paso'),
          ),
        ),
      ],
    );
  }
}
