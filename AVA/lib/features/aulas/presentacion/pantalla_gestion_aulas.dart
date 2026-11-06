import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constantes/dimensiones.dart';
import '../../../core/constantes/paleta.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/modelos/recurso_visual.dart';
import '../../../core/widgets/pantalla_gestion.dart';
import '../../../core/widgets/pictograma.dart';
import '../../../core/widgets/selector_recurso_visual.dart';
import '../../../core/widgets/vista_carga.dart';
import '../../autenticacion/dominio/repositorio_cuentas.dart';
import '../../perfil/dominio/repositorio_estudiantes.dart';
import '../dominio/aula.dart';
import '../dominio/repositorio_aulas.dart';
import '../logica/gestion_aulas_controlador.dart';

/// Gestión de aulas: crearlas, asignarles alumnos y un tutor responsable
/// (HU-15). Solo para la administración.
class PantallaGestionAulas extends StatefulWidget {
  const PantallaGestionAulas({super.key});

  @override
  State<PantallaGestionAulas> createState() => _PantallaGestionAulasState();
}

class _PantallaGestionAulasState extends State<PantallaGestionAulas> {
  late final GestionAulasControlador _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = GestionAulasControlador(
      aulas: context.read<RepositorioAulas>(),
      cuentas: context.read<RepositorioCuentas>(),
      estudiantes: context.read<RepositorioEstudiantes>(),
    );
    unawaited(_controlador.cargar());
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _abrir([Aula? aula]) async {
    final guardada = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: _FormularioAula(controlador: _controlador, aula: aula),
      ),
    );
    if (guardada == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Aula guardada.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PantallaGestion(
      titulo: 'Aulas',
      desplazable: false,
      botonFlotante: FloatingActionButton.extended(
        onPressed: _abrir,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva aula'),
      ),
      cuerpo: VistaCarga<DatosAulas>(
        controlador: _controlador,
        constructor: (context, datos) => ListView.separated(
          padding: const EdgeInsets.only(bottom: 96),
          itemCount: datos.aulas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final aula = datos.aulas[i];
            final tutor = datos.tutores
                .where((t) => t.id == aula.idTutor)
                .map((t) => t.nombre)
                .firstOrNull;
            final alumnos = datos.estudiantes
                .where((e) => e.idAula == aula.id)
                .length;

            return Card(
              color: aula.color.fondo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  Dimensiones.radioBordePequeno,
                ),
                side: BorderSide(color: aula.color.acento, width: 3),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Pictograma(
                  recurso: aula.pictograma ?? Pictogramas.aula,
                  tamano: 56,
                ),
                title: Text(
                  aula.nombre,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Paleta.tinta),
                ),
                subtitle: Text(
                  'Tutor: ${tutor ?? 'sin asignar'} · $alumnos alumnos',
                  style: const TextStyle(color: Paleta.tinta),
                ),
                trailing: IconButton(
                  tooltip: 'Editar ${aula.nombre}',
                  color: Paleta.tinta,
                  onPressed: () => _abrir(aula),
                  icon: const Icon(Icons.edit_rounded),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FormularioAula extends StatefulWidget {
  const _FormularioAula({required this.controlador, required this.aula});

  final GestionAulasControlador controlador;
  final Aula? aula;

  @override
  State<_FormularioAula> createState() => _FormularioAulaState();
}

class _FormularioAulaState extends State<_FormularioAula> {
  final _formulario = GlobalKey<FormState>();
  late final String _id = widget.aula?.id ?? widget.controlador.nuevoId();
  late final _nombre = TextEditingController(text: widget.aula?.nombre);
  late ColorPastel _color = widget.aula?.color ?? ColorPastel.cielo;
  late RecursoVisual? _pictograma = widget.aula?.pictograma;
  late String? _idTutor = widget.aula?.idTutor;
  late final Set<String> _alumnos = {
    for (final e in widget.controlador.datos?.estudiantes ?? const [])
      if (e.idAula == _id) e.id,
  };
  bool _guardando = false;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);
    await widget.controlador.guardar(
      Aula(
        id: _id,
        nombre: _nombre.text.trim(),
        color: _color,
        pictograma: _pictograma,
        idTutor: _idTutor,
      ),
      _alumnos,
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final datos = widget.controlador.datos!;
    final nombresAulas = {for (final a in datos.aulas) a.id: a.nombre};

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.aula == null ? 'Nueva aula' : 'Editar aula'),
        leading: IconButton(
          tooltip: 'Cerrar sin guardar',
          onPressed: () => Navigator.of(context).pop(false),
          icon: const Icon(Icons.close_rounded),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Guardar'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensiones.espaciado),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Form(
              key: _formulario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nombre,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del aula',
                      hintText: 'Por ejemplo: 1ºA',
                    ),
                    validator: (v) =>
                        widget.controlador.validarNombre(v, idAula: _id),
                  ),
                  const TituloSeccion(
                    'Color y pictograma',
                    descripcion: 'Ayudan a los alumnos a reconocer su clase.',
                  ),
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
                  const SizedBox(height: Dimensiones.espaciado),
                  SelectorRecursoVisual(
                    recurso: _pictograma,
                    alCambiar: (r) => setState(() => _pictograma = r),
                  ),
                  const TituloSeccion('Tutor responsable'),
                  DropdownButtonFormField<String?>(
                    initialValue: _idTutor,
                    decoration: const InputDecoration(labelText: 'Tutor'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Sin tutor'),
                      ),
                      for (final tutor in datos.tutores)
                        DropdownMenuItem(
                          value: tutor.id,
                          child: Text(tutor.nombre),
                        ),
                    ],
                    onChanged: (id) => setState(() => _idTutor = id),
                  ),
                  const TituloSeccion(
                    'Alumnos',
                    descripcion:
                        'Un alumno solo puede estar en un aula. Si '
                        'eliges uno de otra aula, se cambiará a esta.',
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final e in datos.estudiantes)
                        FilterChip(
                          label: Text(
                            e.idAula == null || e.idAula == _id
                                ? e.nombre
                                : '${e.nombre} (${nombresAulas[e.idAula] ?? 'otra'})',
                          ),
                          selected: _alumnos.contains(e.id),
                          onSelected: (elegido) => setState(
                            () => elegido
                                ? _alumnos.add(e.id)
                                : _alumnos.remove(e.id),
                          ),
                        ),
                    ],
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
