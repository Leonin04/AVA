import 'package:flutter/material.dart';

import '../../../../core/constantes/dimensiones.dart';

/// Lista editable de pasos de una tarea (HU-06): añadir, quitar y
/// cambiar el orden con botones (sin arrastrar, WCAG 2.5.7).
class EditorPasos extends StatefulWidget {
  const EditorPasos({
    super.key,
    required this.pasosIniciales,
    required this.alCambiar,
  });

  final List<String> pasosIniciales;
  final ValueChanged<List<String>> alCambiar;

  @override
  State<EditorPasos> createState() => _EditorPasosState();
}

class _EditorPasosState extends State<EditorPasos> {
  late final List<TextEditingController> _pasos = [
    for (final paso in widget.pasosIniciales) TextEditingController(text: paso),
  ];

  @override
  void dispose() {
    for (final paso in _pasos) {
      paso.dispose();
    }
    super.dispose();
  }

  void _notificar() => widget.alCambiar([for (final p in _pasos) p.text]);

  void _anadir() {
    setState(() => _pasos.add(TextEditingController()));
    _notificar();
  }

  void _quitar(int i) {
    setState(() => _pasos.removeAt(i).dispose());
    _notificar();
  }

  void _mover(int i, int destino) {
    if (destino < 0 || destino >= _pasos.length) return;
    setState(() {
      final paso = _pasos.removeAt(i);
      _pasos.insert(destino, paso);
    });
    _notificar();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _pasos.length; i++)
          Padding(
            padding: const EdgeInsets.only(
              bottom: Dimensiones.espaciadoPequeno,
            ),
            child: Row(
              children: [
                CircleAvatar(radius: 22, child: Text('${i + 1}')),
                const SizedBox(width: Dimensiones.espaciadoPequeno),
                Expanded(
                  child: TextField(
                    controller: _pasos[i],
                    onChanged: (_) => _notificar(),
                    decoration: InputDecoration(
                      labelText: 'Paso ${i + 1}',
                      hintText:
                          'Una frase corta. Por ejemplo: Coge los guantes.',
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Subir el paso ${i + 1}',
                  onPressed: i > 0 ? () => _mover(i, i - 1) : null,
                  icon: const Icon(Icons.arrow_upward_rounded),
                ),
                IconButton(
                  tooltip: 'Bajar el paso ${i + 1}',
                  onPressed: i < _pasos.length - 1
                      ? () => _mover(i, i + 1)
                      : null,
                  icon: const Icon(Icons.arrow_downward_rounded),
                ),
                IconButton(
                  tooltip: 'Quitar el paso ${i + 1}',
                  onPressed: () => _quitar(i),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _anadir,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Añadir paso'),
          ),
        ),
      ],
    );
  }
}
