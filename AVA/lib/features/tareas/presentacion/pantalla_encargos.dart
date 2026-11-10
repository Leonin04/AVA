import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constantes/dimensiones.dart';
import '../../../core/modelos/recurso_visual.dart';
import '../../../core/widgets/pantalla_gestion.dart';
import '../../../core/widgets/selector_recurso_visual.dart';
import '../../../core/widgets/vista_carga.dart';
import '../../autenticacion/dominio/cuenta.dart';
import '../../autenticacion/presentacion/widgets/aviso_error.dart';
import '../../aulas/dominio/ficha_aula.dart';
import '../../aulas/dominio/repositorio_aulas.dart';
import '../../perfil/dominio/repositorio_estudiantes.dart';
import '../../perfil/logica/lista_alumnos_controlador.dart';
import '../dominio/repositorio_tareas.dart';
import '../logica/encargos_controlador.dart';
import '../logica/validacion_tareas.dart';
import 'widgets/editor_pasos.dart';
import 'widgets/selector_horario.dart';

enum _Destino { aula, alumnos }

/// Creación de un encargo del centro (reprografía, comedor, recados...) y
/// su asignación a un aula o a varios alumnos para una fecha (HU-07).
class PantallaEncargos extends StatefulWidget {
  const PantallaEncargos({super.key, required this.cuenta});

  final Cuenta cuenta;

  @override
  State<PantallaEncargos> createState() => _PantallaEncargosState();
}

class _PantallaEncargosState extends State<PantallaEncargos> {
  final _formulario = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _descripcion = TextEditingController();
  late final ListaAlumnosControlador _alumnos;
  late final EncargosControlador _encargos;

  RecursoVisual? _pictograma;
  List<String> _pasos = const [];
  DateTime _dia = DateTime.now();
  TimeOfDay _inicio = const TimeOfDay(hour: 11, minute: 30);
  TimeOfDay _fin = const TimeOfDay(hour: 12, minute: 0);
  _Destino _destino = _Destino.aula;
  String? _idAula;
  final Set<String> _elegidos = {};
  String? _error;
  bool _guardando = false;
  int _version = 0;

  @override
  void initState() {
    super.initState();
    _alumnos = ListaAlumnosControlador(
      estudiantes: context.read<RepositorioEstudiantes>(),
      aulas: context.read<RepositorioAulas>(),
      cuenta: widget.cuenta,
    );
    _encargos = EncargosControlador(context.read<RepositorioTareas>());
    unawaited(_alumnos.cargar());
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    _alumnos.dispose();
    super.dispose();
  }

  DateTime _combinar(TimeOfDay hora) =>
      DateTime(_dia.year, _dia.month, _dia.day, hora.hour, hora.minute);

  Set<String> _destinatarios(List<AlumnoConAula> alumnos) => switch (_destino) {
    _Destino.aula => {
      for (final a in alumnos)
        if (a.aula?.id == _idAula) a.estudiante.id,
    },
    _Destino.alumnos => _elegidos,
  };

  Future<void> _crear(List<AlumnoConAula> alumnos) async {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    final avisos = ScaffoldMessenger.of(context);

    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      final creados = await _encargos.crear(
        titulo: _titulo.text,
        descripcion: _descripcion.text,
        pasos: _pasos,
        pictograma: _pictograma,
        inicio: _combinar(_inicio),
        fin: _combinar(_fin),
        idsEstudiantes: _destinatarios(alumnos),
        idAula: _destino == _Destino.aula ? _idAula : null,
        creadaPor: widget.cuenta.id,
      );
      avisos.showSnackBar(
        SnackBar(
          content: Text('Encargo añadido a la agenda de $creados alumnos.'),
        ),
      );
      setState(() {
        _titulo.clear();
        _descripcion.clear();
        _pictograma = null;
        _pasos = const [];
        _elegidos.clear();
        _version++;
      });
    } on ArgumentError catch (error) {
      setState(() => _error = '${error.message}');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PantallaGestion(
      titulo: 'Encargos del colegio',
      cuerpo: VistaCarga<List<AlumnoConAula>>(
        controlador: _alumnos,
        constructor: (context, alumnos) {
          final aulas = <String, Aula>{
            for (final a in alumnos)
              if (a.aula != null) a.aula!.id: a.aula!,
          }.values.toList()..sort((a, b) => a.nombre.compareTo(b.nombre));

          return Form(
            key: _formulario,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titulo,
                  maxLength: ValidacionTareas.longitudMaximaTitulo,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del encargo',
                    hintText: 'Por ejemplo: Llevar fotocopias.',
                  ),
                  validator: ValidacionTareas.titulo,
                ),
                const TituloSeccion('Pictograma o foto'),
                SelectorRecursoVisual(
                  recurso: _pictograma,
                  textoBusquedaInicial: _titulo.text,
                  alCambiar: (r) => setState(() => _pictograma = r),
                ),
                const TituloSeccion('Fecha y hora'),
                SelectorHorario(
                  dia: _dia,
                  inicio: _inicio,
                  fin: _fin,
                  error: ValidacionTareas.horario(
                    _combinar(_inicio),
                    _combinar(_fin),
                  ),
                  alCambiarDia: (d) => setState(() => _dia = d),
                  alCambiarInicio: (h) => setState(() => _inicio = h),
                  alCambiarFin: (h) => setState(() => _fin = h),
                ),
                const TituloSeccion('Para quién'),
                SegmentedButton<_Destino>(
                  segments: const [
                    ButtonSegment(
                      value: _Destino.aula,
                      icon: Icon(Icons.meeting_room_rounded),
                      label: Text('Un aula'),
                    ),
                    ButtonSegment(
                      value: _Destino.alumnos,
                      icon: Icon(Icons.groups_rounded),
                      label: Text('Algunos alumnos'),
                    ),
                  ],
                  selected: {_destino},
                  onSelectionChanged: (s) => setState(() => _destino = s.first),
                ),
                const SizedBox(height: Dimensiones.espaciado),
                if (_destino == _Destino.aula)
                  DropdownButtonFormField<String>(
                    initialValue: _idAula,
                    decoration: const InputDecoration(labelText: 'Aula'),
                    items: [
                      for (final aula in aulas)
                        DropdownMenuItem(
                          value: aula.id,
                          child: Text(aula.nombre),
                        ),
                    ],
                    onChanged: (id) => setState(() => _idAula = id),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final a in alumnos)
                        FilterChip(
                          label: Text(
                            '${a.estudiante.nombre} (${a.aula?.nombre ?? 'sin aula'})',
                          ),
                          selected: _elegidos.contains(a.estudiante.id),
                          onSelected: (elegido) => setState(
                            () => elegido
                                ? _elegidos.add(a.estudiante.id)
                                : _elegidos.remove(a.estudiante.id),
                          ),
                        ),
                    ],
                  ),
                const TituloSeccion('Qué hay que hacer'),
                TextFormField(
                  controller: _descripcion,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Frases cortas y sencillas.',
                  ),
                ),
                const TituloSeccion('Pasos'),
                EditorPasos(
                  key: ValueKey(_version),
                  pasosIniciales: _pasos,
                  alCambiar: (pasos) => _pasos = pasos,
                ),
                if (_error case final mensaje?) ...[
                  const SizedBox(height: Dimensiones.espaciado),
                  AvisoError(mensaje: mensaje),
                ],
                const SizedBox(height: Dimensiones.espaciado),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _guardando ? null : () => _crear(alumnos),
                    icon: const Icon(Icons.assignment_turned_in_rounded),
                    label: const Text('Crear encargo'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
