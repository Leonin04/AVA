import 'package:flutter/material.dart';

import '../../../../core/constantes/dimensiones.dart';
import '../../../../core/modelos/recurso_visual.dart';
import '../../../../core/widgets/pictograma.dart';
import '../../../../core/widgets/selector_recurso_visual.dart';
import '../../dominio/tarea_agenda.dart';

/// Lista editable de pasos de una tarea (HU-07, HU-20): añadir, quitar,
/// cambiar el orden con botones (sin arrastrar, WCAG 2.5.7) y poner a cada
/// paso un pictograma o una foto de apoyo.
class EditorPasos extends StatefulWidget {
  const EditorPasos({
    super.key,
    required this.pasosIniciales,
    required this.alCambiar,
  });

  final List<PasoTarea> pasosIniciales;
  final ValueChanged<List<PasoTarea>> alCambiar;

  @override
  State<EditorPasos> createState() => _EditorPasosState();
}

class _EditorPasosState extends State<EditorPasos> {
  late final List<TextEditingController> _textos = [
    for (final paso in widget.pasosIniciales)
      TextEditingController(text: paso.texto),
  ];
  late final List<RecursoVisual?> _imagenes = [
    for (final paso in widget.pasosIniciales) paso.imagen,
  ];

  @override
  void dispose() {
    for (final texto in _textos) {
      texto.dispose();
    }
    super.dispose();
  }

  void _notificar() => widget.alCambiar([
    for (var i = 0; i < _textos.length; i++)
      PasoTarea(_textos[i].text, imagen: _imagenes[i]),
  ]);

  void _anadir() {
    setState(() {
      _textos.add(TextEditingController());
      _imagenes.add(null);
    });
    _notificar();
  }

  void _quitar(int i) {
    setState(() {
      _textos.removeAt(i).dispose();
      _imagenes.removeAt(i);
    });
    _notificar();
  }

  void _mover(int i, int destino) {
    if (destino >= 0 && destino < _textos.length) {
      setState(() {
        _textos.insert(destino, _textos.removeAt(i));
        _imagenes.insert(destino, _imagenes.removeAt(i));
      });
      _notificar();
    }
  }

  Future<void> _elegirImagen(int i) async {
    var elegida = _imagenes[i];
    final aceptada = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: Text('Apoyo del paso ${i + 1}'),
        content: SizedBox(
          width: 560,
          child: StatefulBuilder(
            builder: (contexto, actualizar) => SelectorRecursoVisual(
              recurso: elegida,
              textoBusquedaInicial: _textos[i].text,
              alCambiar: (recurso) => actualizar(() => elegida = recurso),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    if (aceptada == true) {
      setState(() => _imagenes[i] = elegida);
      _notificar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _textos.length; i++)
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
                    controller: _textos[i],
                    onChanged: (_) => _notificar(),
                    decoration: InputDecoration(
                      labelText: 'Paso ${i + 1}',
                      hintText:
                          'Una frase corta. Por ejemplo: Coge los guantes.',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: _imagenes[i] == null
                      ? 'Añadir pictograma o foto al paso ${i + 1}'
                      : 'Cambiar el apoyo del paso ${i + 1}',
                  child: InkWell(
                    onTap: () => _elegirImagen(i),
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox.square(
                      dimension: 56,
                      child: _imagenes[i] == null
                          ? const Icon(Icons.add_photo_alternate_rounded)
                          : Pictograma(recurso: _imagenes[i], tamano: 52),
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
                  onPressed: i < _textos.length - 1
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
