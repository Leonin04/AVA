import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constantes/dimensiones.dart';
import '../../../core/modelos/recurso_visual.dart';
import '../../../core/utilidades/controlador_carga.dart';
import '../../../core/widgets/pantalla_gestion.dart';
import '../../../core/widgets/selector_recurso_visual.dart';
import '../../autenticacion/dominio/cuenta.dart';
import '../../autenticacion/presentacion/widgets/aviso_error.dart';
import '../../aulas/dominio/repositorio_aulas.dart';
import '../../perfil/dominio/repositorio_estudiantes.dart';
import '../dominio/repositorio_tareas.dart';
import '../dominio/tarea.dart';
import '../logica/formulario_tarea_controlador.dart';
import '../logica/validacion_tareas.dart';
import 'widgets/editor_pasos.dart';
import 'widgets/selector_horario.dart';

/// Datos que recibe el formulario de tarea.
class ArgumentosFormularioTarea {
  const ArgumentosFormularioTarea({
    required this.idEstudiante,
    required this.dia,
    this.tarea,
  });

  final String idEstudiante;
  final DateTime dia;

  /// Tarea a editar, o `null` para crear una nueva.
  final Tarea? tarea;
}

/// Formulario de tarea del tutor (HU-03 a HU-06): nombre, tipo, pictograma
/// o foto, descripción breve, horario y pasos.
class PantallaFormularioTarea extends StatefulWidget {
  const PantallaFormularioTarea({
    super.key,
    required this.cuenta,
    required this.argumentos,
  });

  final Cuenta cuenta;
  final ArgumentosFormularioTarea argumentos;

  @override
  State<PantallaFormularioTarea> createState() =>
      _PantallaFormularioTareaState();
}

class _PantallaFormularioTareaState extends State<PantallaFormularioTarea> {
  final _formulario = GlobalKey<FormState>();
  late final FormularioTareaControlador _controlador;

  late final Tarea? _existente = widget.argumentos.tarea;
  late final _titulo = TextEditingController(text: _existente?.titulo);
  late final _descripcion = TextEditingController(
    text: _existente?.descripcion,
  );
  late TipoTarea _tipo = _existente?.tipo ?? TipoTarea.escolar;
  late RecursoVisual? _pictograma = _existente?.pictograma;
  late List<String> _pasos = List.of(_existente?.pasos ?? const []);
  late DateTime _dia = _existente?.inicio ?? widget.argumentos.dia;
  late TimeOfDay _inicio = _existente == null
      ? const TimeOfDay(hour: 10, minute: 0)
      : TimeOfDay.fromDateTime(_existente.inicio);
  late TimeOfDay _fin = _existente == null
      ? const TimeOfDay(hour: 10, minute: 30)
      : TimeOfDay.fromDateTime(_existente.fin);
  String? _errorHorario;
  String? _error;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _controlador = FormularioTareaControlador(
      tareas: context.read<RepositorioTareas>(),
      estudiantes: context.read<RepositorioEstudiantes>(),
      aulas: context.read<RepositorioAulas>(),
      cuenta: widget.cuenta,
    );
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  DateTime _combinar(TimeOfDay hora) =>
      DateTime(_dia.year, _dia.month, _dia.day, hora.hour, hora.minute);

  void _actualizarHorario() => setState(
    () => _errorHorario = ValidacionTareas.horario(
      _combinar(_inicio),
      _combinar(_fin),
    ),
  );

  Future<void> _guardar() async {
    _actualizarHorario();
    if (!(_formulario.currentState?.validate() ?? false) ||
        _errorHorario != null) {
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await _controlador.guardar(
        idEstudiante: widget.argumentos.idEstudiante,
        titulo: _titulo.text,
        tipo: _tipo,
        inicio: _combinar(_inicio),
        fin: _combinar(_fin),
        descripcion: _descripcion.text,
        pasos: _pasos,
        pictograma: _pictograma,
        existente: _existente,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on ErrorConMensaje catch (error) {
      if (mounted) setState(() => _error = error.mensaje);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PantallaGestion(
      titulo: _existente == null ? 'Nueva tarea' : 'Editar tarea',
      acciones: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FilledButton.icon(
            onPressed: _guardando ? null : _guardar,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Guardar'),
          ),
        ),
      ],
      cuerpo: Form(
        key: _formulario,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titulo,
              maxLength: ValidacionTareas.longitudMaximaTitulo,
              decoration: const InputDecoration(
                labelText: 'Nombre de la tarea',
                hintText: 'Corto y claro. Por ejemplo: Regar las plantas.',
              ),
              validator: ValidacionTareas.titulo,
            ),
            const TituloSeccion('Tipo'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tipo in TipoTarea.values)
                  ChoiceChip(
                    avatar: CircleAvatar(backgroundColor: tipo.color.acento),
                    label: Text(tipo.nombre),
                    selected: _tipo == tipo,
                    onSelected: (_) => setState(() => _tipo = tipo),
                  ),
              ],
            ),
            const TituloSeccion(
              'Pictograma o foto',
              descripcion: 'Ayuda a entender la tarea sin leer (HU-05).',
            ),
            SelectorRecursoVisual(
              recurso: _pictograma,
              textoBusquedaInicial: _titulo.text,
              alCambiar: (r) => setState(() => _pictograma = r),
            ),
            const TituloSeccion('Horario'),
            SelectorHorario(
              dia: _dia,
              inicio: _inicio,
              fin: _fin,
              error: _errorHorario,
              alCambiarDia: (d) {
                _dia = d;
                _actualizarHorario();
              },
              alCambiarInicio: (h) {
                _inicio = h;
                _actualizarHorario();
              },
              alCambiarFin: (h) {
                _fin = h;
                _actualizarHorario();
              },
            ),
            const TituloSeccion(
              'Qué hay que hacer',
              descripcion: 'Frases cortas y sencillas (lectura fácil).',
            ),
            TextFormField(
              controller: _descripcion,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Por ejemplo: Regamos las macetas del pasillo.',
              ),
            ),
            const TituloSeccion(
              'Pasos',
              descripcion: 'El alumno los verá de uno en uno, en este orden.',
            ),
            EditorPasos(
              pasosIniciales: _pasos,
              alCambiar: (pasos) => _pasos = pasos,
            ),
            if (_error case final mensaje?) ...[
              const SizedBox(height: Dimensiones.espaciado),
              AvisoError(mensaje: mensaje),
            ],
          ],
        ),
      ),
    );
  }
}
