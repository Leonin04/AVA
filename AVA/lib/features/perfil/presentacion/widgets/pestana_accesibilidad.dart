import 'package:flutter/material.dart';

import '../../../../core/constantes/dimensiones.dart';
import '../../../../core/widgets/pantalla_gestion.dart';
import '../../../agenda/dominio/vista_agenda.dart';
import '../../dominio/preferencias_accesibilidad.dart';
import '../../logica/ficha_estudiante_controlador.dart';
import '../opciones_preferencias.dart';

/// Preferencias de accesibilidad y permisos del alumno (HU-15, HU-10).
///
/// Usa las mismas opciones que ve el alumno en su perfil.
class PestanaAccesibilidad extends StatefulWidget {
  const PestanaAccesibilidad({super.key, required this.controlador});

  final FichaEstudianteControlador controlador;

  @override
  State<PestanaAccesibilidad> createState() => _PestanaAccesibilidadState();
}

class _PestanaAccesibilidadState extends State<PestanaAccesibilidad> {
  late final _estudiante = widget.controlador.datos!;
  late PreferenciasAccesibilidad _preferencias = _estudiante.preferencias;
  late bool _puedeModificar = _estudiante.puedeModificarPreferencias;
  late bool _puedeGestionarTareas = _estudiante.puedeGestionarTareas;
  bool _guardando = false;

  Future<void> _guardar() async {
    final avisos = ScaffoldMessenger.of(context);
    setState(() => _guardando = true);
    final error = await widget.controlador.guardarPreferencias(
      _preferencias,
      puedeModificarPreferencias: _puedeModificar,
      puedeGestionarTareas: _puedeGestionarTareas,
    );
    if (!mounted) return;
    setState(() => _guardando = false);
    avisos.showSnackBar(
      SnackBar(content: Text(error ?? 'Preferencias guardadas.')),
    );
  }

  Widget _chips(Iterable<OpcionPreferencia> opciones) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final opcion in opciones)
        FilterChip(
          avatar: Icon(opcion.icono),
          label: Text(opcion.texto),
          selected: opcion.activa(_preferencias),
          showCheckmark: false,
          onSelected: (_) =>
              setState(() => _preferencias = opcion.aplicar(_preferencias)),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final opciones = OpcionPreferencia.todas();
    bool es(OpcionPreferencia o, String palabra) => o.texto.contains(palabra);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: Dimensiones.espaciado * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TituloSeccion('Letra'),
          _chips(opciones.where((o) => es(o, 'Letra'))),
          const TituloSeccion('Colores y contraste'),
          _chips(
            opciones.where(
              (o) => es(o, 'Color') || es(o, 'contraste') || es(o, 'oscuro'),
            ),
          ),
          const TituloSeccion(
            'Comunicación',
            descripcion: 'Pictogramas, palabras y voz (HU-15).',
          ),
          _chips(opciones.where((o) => es(o, 'Ver ') || es(o, 'voz'))),
          const TituloSeccion('Manejo'),
          _chips(opciones.where((o) => es(o, 'toques') || es(o, 'Botones'))),
          const TituloSeccion(
            'Vistas de la agenda',
            descripcion: 'Las que podrá elegir el alumno.',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final vista in VistaAgenda.values)
                FilterChip(
                  label: Text(vista.nombre),
                  selected: _preferencias.vistasAgenda.contains(vista),
                  onSelected: (elegida) => setState(() {
                    final vistas = {..._preferencias.vistasAgenda};
                    elegida ? vistas.add(vista) : vistas.remove(vista);
                    _preferencias = _preferencias.copyWith(
                      vistasAgenda: vistas,
                    );
                  }),
                ),
            ],
          ),
          const TituloSeccion('Permisos del alumno'),
          SwitchListTile(
            value: _puedeModificar,
            onChanged: (v) => setState(() => _puedeModificar = v),
            title: const Text('Puede cambiar sus preferencias'),
            subtitle: const Text('Desde «Mi perfil».'),
          ),
          SwitchListTile(
            value: _puedeGestionarTareas,
            onChanged: (v) => setState(() => _puedeGestionarTareas = v),
            title: const Text('Puede crear, cambiar y borrar sus tareas'),
            subtitle: const Text('Solo las tareas personales que cree él.'),
          ),
          const SizedBox(height: Dimensiones.espaciado),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Guardar preferencias'),
            ),
          ),
        ],
      ),
    );
  }
}
