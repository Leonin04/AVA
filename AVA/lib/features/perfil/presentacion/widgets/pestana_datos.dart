import 'package:flutter/material.dart';

import '../../../../core/constantes/dimensiones.dart';
import '../../../../core/constantes/paleta.dart';
import '../../../../core/modelos/recurso_visual.dart';
import '../../../../core/utilidades/controlador_carga.dart';
import '../../../../core/widgets/pantalla_gestion.dart';
import '../../../../core/widgets/selector_recurso_visual.dart';
import '../../logica/ficha_estudiante_controlador.dart';

/// Datos del perfil del alumno (HU-19, RI01): foto, color, intereses,
/// necesidades, elementos que le calman y notas de progreso.
class PestanaDatos extends StatefulWidget {
  const PestanaDatos({super.key, required this.controlador});

  final FichaEstudianteControlador controlador;

  @override
  State<PestanaDatos> createState() => _PestanaDatosState();
}

class _PestanaDatosState extends State<PestanaDatos> {
  late final _estudiante = widget.controlador.datos!;
  late RecursoVisual? _avatar = _estudiante.avatar;
  late ColorPastel _color = _estudiante.color;
  late final List<String> _intereses = List.of(_estudiante.intereses);
  late final _nuevoInteres = TextEditingController();
  late final _necesidades = TextEditingController(
    text: _estudiante.necesidades,
  );
  late final _autorregulacion = TextEditingController(
    text: _estudiante.autorregulacion,
  );
  late final _observaciones = TextEditingController(
    text: _estudiante.observaciones,
  );
  bool _guardando = false;

  @override
  void dispose() {
    _nuevoInteres.dispose();
    _necesidades.dispose();
    _autorregulacion.dispose();
    _observaciones.dispose();
    super.dispose();
  }

  void _anadirInteres() {
    final interes = _nuevoInteres.text.trim();
    if (interes.isEmpty || _intereses.contains(interes)) return;
    setState(() => _intereses.add(interes));
    _nuevoInteres.clear();
  }

  Future<void> _guardar() async {
    final actual = widget.controlador.datos;
    if (actual == null) return;
    final avisos = ScaffoldMessenger.of(context);

    setState(() => _guardando = true);
    try {
      await widget.controlador.guardarPerfil(
        actual.copyWith(
          avatar: _avatar,
          quitarAvatar: _avatar == null,
          color: _color,
          intereses: List.of(_intereses),
          necesidades: _necesidades.text.trim(),
          autorregulacion: _autorregulacion.text.trim(),
          observaciones: _observaciones.text.trim(),
        ),
      );
      avisos.showSnackBar(const SnackBar(content: Text('Perfil guardado.')));
    } on ErrorConMensaje catch (error) {
      avisos.showSnackBar(SnackBar(content: Text(error.mensaje)));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: Dimensiones.espaciado * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TituloSeccion(
            'Foto o pictograma',
            descripcion: 'Le identifica en la pantalla de su clase.',
          ),
          SelectorRecursoVisual(
            recurso: _avatar,
            textoBusquedaInicial: 'persona',
            alCambiar: (r) => setState(() => _avatar = r),
          ),
          const TituloSeccion('Color de su tarjeta'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final color in ColorPastel.values)
                ChoiceChip(
                  avatar: CircleAvatar(backgroundColor: color.acento),
                  label: Text(color.nombre),
                  selected: _color == color,
                  onSelected: (_) => setState(() => _color = color),
                ),
            ],
          ),
          const TituloSeccion(
            'Intereses',
            descripcion: 'Televisión, cine, música, deporte...',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final interes in _intereses)
                InputChip(
                  label: Text(interes),
                  onDeleted: () => setState(() => _intereses.remove(interes)),
                  deleteButtonTooltipMessage: 'Quitar $interes',
                ),
            ],
          ),
          const SizedBox(height: Dimensiones.espaciadoPequeno),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nuevoInteres,
                  onSubmitted: (_) => _anadirInteres(),
                  decoration: const InputDecoration(labelText: 'Nuevo interés'),
                ),
              ),
              const SizedBox(width: Dimensiones.espaciadoPequeno),
              OutlinedButton.icon(
                onPressed: _anadirInteres,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Añadir'),
              ),
            ],
          ),
          const TituloSeccion('Necesidades y apoyos'),
          TextField(
            controller: _necesidades,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText:
                  'Por ejemplo: necesita botones grandes y tiempo '
                  'para responder.',
            ),
          ),
          const TituloSeccion('Lo que le ayuda a calmarse'),
          TextField(
            controller: _autorregulacion,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Por ejemplo: música tranquila, rincón de la calma.',
            ),
          ),
          const TituloSeccion('Progreso y observaciones'),
          TextField(controller: _observaciones, minLines: 2, maxLines: 6),
          const SizedBox(height: Dimensiones.espaciado),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Guardar perfil'),
            ),
          ),
        ],
      ),
    );
  }
}
