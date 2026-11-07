import 'package:flutter/material.dart';

import '../../../core/servicios/base_datos.dart';
import '../../aulas/dominio/aula.dart';
import '../../autenticacion/dominio/usuario.dart';
import '../../perfil/dominio/estudiante.dart';
import '../dominio/tarea.dart';
import '../logica/formulario_tarea.dart';
import 'editor_pasos.dart';
import 'selector_pictograma.dart';

/// Crear (T-66 a T-78) o editar (T-79) una tarea.
class PantallaFormularioTarea extends StatefulWidget {
  const PantallaFormularioTarea({
    super.key,
    required this.usuario,
    this.estudianteInicial,
    this.tareaEditar,
  });

  /// Quien crea o edita (admin o tutor).
  final Usuario usuario;

  /// Estudiante desde el que se abrió la pantalla (queda marcado).
  final String? estudianteInicial;

  /// Si no es null, se edita esta tarea.
  final Tarea? tareaEditar;

  @override
  State<PantallaFormularioTarea> createState() => _PantallaFormularioTareaState();
}

class _PantallaFormularioTareaState extends State<PantallaFormularioTarea> {
  final _bd = BaseDatos();
  FormularioTarea? _form;
  bool _guardando = false;
  List<String> _errores = [];

  static const _dias = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final t = widget.tareaEditar;
    if (t == null) {
      setState(() => _form = FormularioTarea(
            creadaPor: widget.usuario.id,
            estudianteInicial: widget.estudianteInicial,
          ));
    } else {
      final pasos = await _bd.pasosDe(t.id);
      if (!mounted) return;
      setState(() => _form = FormularioTarea.editar(t, pasos));
    }
  }

  @override
  void dispose() {
    _form?.dispose();
    super.dispose();
  }

  Stream<List<Estudiante>> get _estudiantesDisponibles => widget.usuario.esAdmin
      ? _bd.todosLosEstudiantes()
      : _bd.estudiantesDeTutor(widget.usuario.id);

  Future<void> _guardar() async {
    final f = _form!;
    final errores = f.validar();
    setState(() => _errores = errores);
    if (errores.isNotEmpty) return;

    setState(() => _guardando = true);
    try {
      if (f.esNueva) {
        await _bd.crearTarea(f.aTarea(), f.aPasos());
      } else {
        await _bd.actualizarTarea(f.aTarea(), f.aPasos());
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.esNueva ? 'Tarea creada' : 'Tarea guardada')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _errores = ['No se pudo guardar: $e']);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _elegirHora(bool inicio) async {
    final f = _form!;
    final h = await showTimePicker(
      context: context,
      initialTime: (inicio ? f.horaInicio : f.horaFin) ??
          const TimeOfDay(hour: 9, minute: 0),
    );
    if (h == null) return;
    inicio ? f.cambiarHoraInicio(h) : f.cambiarHoraFin(h);
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _form!.fecha ?? hoy,
      firstDate: DateTime(hoy.year - 1),
      lastDate: DateTime(hoy.year + 2),
    );
    if (d != null) _form!.cambiarFecha(d);
  }

  @override
  Widget build(BuildContext context) {
    final f = _form;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tareaEditar == null ? 'Nueva tarea' : 'Editar tarea'),
      ),
      body: f == null
          ? const Center(child: CircularProgressIndicator())
          : ListenableBuilder(
              listenable: f,
              builder: (context, _) => _contenido(f),
            ),
      bottomNavigationBar: f == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: const Icon(Icons.save),
                  label: Text(_guardando ? 'Guardando…' : 'Guardar tarea'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                ),
              ),
            ),
    );
  }

  Widget _contenido(FormularioTarea f) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // ---------- Errores de validación (T-78) ----------
        if (_errores.isNotEmpty)
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [for (final e in _errores) Text('• $e')],
              ),
            ),
          ),

        // ---------- Nombre (T-66) y pictograma (T-70) ----------
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Pictograma(
              url: f.pictogramaUrl,
              onTap: () async {
                final url = await elegirPictograma(context, textoInicial: f.nombre);
                if (url != null) f.cambiarPictograma(url);
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: f.nombre,
                    decoration: const InputDecoration(labelText: 'Nombre de la tarea *'),
                    onChanged: (t) => f.nombre = t,
                  ),
                  const SizedBox(height: 12),
                  // ---------- Descripción (T-68) ----------
                  TextFormField(
                    initialValue: f.descripcion,
                    decoration: const InputDecoration(labelText: 'Descripción breve'),
                    maxLines: 3,
                    onChanged: (t) => f.descripcion = t,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ---------- Tipo (T-69) ----------
        const _Titulo('Tipo de tarea'),
        SegmentedButton<TipoTarea>(
          segments: [
            for (final t in TipoTarea.values)
              ButtonSegment(value: t, label: Text(t.texto)),
          ],
          selected: {f.tipo},
          onSelectionChanged: (s) => f.cambiarTipo(s.first),
        ),
        const SizedBox(height: 24),

        // ---------- Horario (T-71, T-72) ----------
        const _Titulo('Horario'),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _elegirHora(true),
                icon: const Icon(Icons.schedule),
                label: Text(f.horaInicio == null
                    ? 'Hora de inicio *'
                    : 'Empieza: ${FormularioTarea.formatear(f.horaInicio!)}'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _elegirHora(false),
                icon: const Icon(Icons.schedule),
                label: Text(f.horaFin == null
                    ? 'Hora de fin *'
                    : 'Termina: ${FormularioTarea.formatear(f.horaFin!)}'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ---------- Días que se repite (T-73) o fecha ----------
        const _Titulo('¿Qué días? *'),
        Wrap(
          spacing: 8,
          children: [
            for (var d = 1; d <= 7; d++)
              FilterChip(
                label: Text(_dias[d - 1]),
                selected: f.diasSemana.contains(d),
                onSelected: (_) => f.alternarDia(d),
              ),
          ],
        ),
        if (f.diasSemana.isEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('o un día concreto: '),
              TextButton.icon(
                onPressed: _elegirFecha,
                icon: const Icon(Icons.event),
                label: Text(f.fecha == null
                    ? 'Elegir fecha'
                    : '${f.fecha!.day}/${f.fecha!.month}/${f.fecha!.year}'),
              ),
              if (f.fecha != null)
                IconButton(
                  tooltip: 'Quitar fecha',
                  icon: const Icon(Icons.close),
                  onPressed: () => f.cambiarFecha(null),
                ),
            ],
          ),
        ],
        const SizedBox(height: 24),

        // ---------- Estudiantes (T-67) ----------
        const _Titulo('Para qué estudiantes'),
        StreamBuilder<List<Estudiante>>(
          stream: _estudiantesDisponibles,
          builder: (context, snap) {
            if (snap.hasError) return Text('Error: ${snap.error}');
            if (!snap.hasData) return const LinearProgressIndicator();
            final lista = snap.data!;
            if (lista.isEmpty) return const Text('No tienes estudiantes asignados.');
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in lista)
                  FilterChip(
                    label: Text(e.nombre),
                    selected: f.estudiantes.contains(e.id),
                    onSelected: (_) => f.alternarEstudiante(e.id),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        // ---------- O para toda un aula (encargo del centro, HU-08) ----------
        const _Titulo('O para toda un aula (encargo del centro)'),
        StreamBuilder<List<Aula>>(
          stream: _bd.aulas(),
          builder: (context, snap) {
            final aulas = snap.data ?? const <Aula>[];
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Ninguna'),
                  selected: f.aulaId == null,
                  onSelected: (_) => f.cambiarAula(null),
                ),
                for (final a in aulas)
                  ChoiceChip(
                    label: Text(a.nombre),
                    selected: f.aulaId == a.id,
                    onSelected: (_) => f.cambiarAula(a.id),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        // ---------- Pasos (T-74 a T-77) ----------
        const _Titulo('Pasos'),
        EditorPasos(formulario: f),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(texto, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _Pictograma extends StatelessWidget {
  const _Pictograma({required this.url, required this.onTap});
  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: url.isEmpty ? 'Elegir pictograma' : 'Cambiar pictograma',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: url.isEmpty
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_search, size: 40),
                    SizedBox(height: 4),
                    Text('Pictograma'),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.network(url,
                      errorBuilder: (context, error, stack) =>
                          const Icon(Icons.broken_image)),
                ),
        ),
      ),
    );
  }
}
