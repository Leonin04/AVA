import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constantes/dimensiones.dart';
import '../../../core/modelos/recurso_visual.dart';
import '../../../core/utilidades/controlador_carga.dart';
import '../../../core/utilidades/formato_fecha.dart';
import '../../../core/widgets/pantalla_gestion.dart';
import '../../../core/widgets/selector_recurso_visual.dart';
import '../../autenticacion/dominio/cuenta.dart';
import '../../autenticacion/presentacion/widgets/aviso_error.dart';
import '../../aulas/dominio/repositorio_aulas.dart';
import '../../perfil/dominio/repositorio_estudiantes.dart';
import '../dominio/repositorio_tareas.dart';
import '../dominio/tarea_agenda.dart';
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

/// Formulario de tarea del tutor (HU-04 a HU-07, HU-14, HU-20, HU-22,
/// HU-28): nombre, tipo, pictograma o foto, descripción breve, horario,
/// días de repetición, pasos con su apoyo, temporizador y aviso previo.
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
  late List<PasoTarea> _pasos = List.of(_existente?.pasos ?? const []);
  late final Set<int> _diasSemana = {...?_existente?.diasSemana};
  late bool _temporizador = _existente?.temporizador ?? false;
  late int? _avisoMinutos = _existente?.avisoMinutos;
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
        diasSemana: _diasSemana.toList(),
        temporizador: _temporizador,
        avisoMinutos: _avisoMinutos,
        existente: _existente,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on ErrorConMensaje catch (error) {
      if (mounted) setState(() => _error = error.mensaje);
    } on Exception {
      if (mounted) {
        setState(
          () => _error = 'No se ha podido guardar la tarea. Prueba otra vez.',
        );
      }
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
              descripcion: 'Ayuda a entender la tarea sin leer (HU-06).',
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
            TituloSeccion(
              'Repetir cada semana',
              descripcion: _diasSemana.isEmpty
                  ? 'Sin días marcados, la tarea es solo del día elegido.'
                  : 'Se repite estos días. Los cambios se aplican a las '
                        'próximas veces; lo ya hecho no cambia (HU-14).',
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var dia = 1; dia <= 7; dia++)
                  FilterChip(
                    label: Text(FormatoFecha.nombreDiaSemana(dia)),
                    selected: _diasSemana.contains(dia),
                    onSelected: (marcado) => setState(
                      () => marcado
                          ? _diasSemana.add(dia)
                          : _diasSemana.remove(dia),
                    ),
                  ),
              ],
            ),
            const TituloSeccion('Mientras la hace'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _temporizador,
              onChanged: (valor) => setState(() => _temporizador = valor),
              title: const Text('Temporizador'),
              subtitle: const Text(
                'El alumno ve cuánto tiempo le queda hasta la hora de fin '
                '(HU-22).',
              ),
            ),
            DropdownButtonFormField<int?>(
              initialValue: _avisoMinutos,
              decoration: const InputDecoration(
                labelText: 'Aviso antes de empezar (HU-28)',
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Sin aviso')),
                for (final minutos in const [5, 10, 15, 30])
                  DropdownMenuItem(
                    value: minutos,
                    child: Text('$minutos minutos antes'),
                  ),
              ],
              onChanged: (valor) => setState(() => _avisoMinutos = valor),
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
