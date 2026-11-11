import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/rutas.dart';
import '../../../../core/constantes/dimensiones.dart';
import '../../../../core/constantes/paleta.dart';
import '../../../../core/utilidades/formato_fecha.dart';
import '../../../../core/widgets/pictograma.dart';
import '../../../../core/widgets/vista_carga.dart';
import '../../../autenticacion/dominio/cuenta.dart';
import '../../../tareas/dominio/repositorio_tareas.dart';
import '../../../tareas/dominio/tarea_agenda.dart';
import '../../../tareas/logica/tareas_dia_controlador.dart';
import '../../../tareas/presentacion/pantalla_editar_tarea.dart';
import '../../dominio/perfil_estudiante.dart';

/// Tareas del alumno día a día, para crearlas, cambiarlas o borrarlas
/// (HU-04 a HU-07).
class PestanaTareas extends StatefulWidget {
  const PestanaTareas({
    super.key,
    required this.cuenta,
    required this.estudiante,
  });

  final Cuenta cuenta;
  final Estudiante estudiante;

  @override
  State<PestanaTareas> createState() => _PestanaTareasState();
}

class _PestanaTareasState extends State<PestanaTareas> {
  late final TareasDiaControlador _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = TareasDiaControlador(
      repositorio: context.read<RepositorioTareas>(),
      idEstudiante: widget.estudiante.id,
      dia: DateTime.now(),
    );
    unawaited(_controlador.cargar());
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _elegirDia() async {
    final dia = await showDatePicker(
      context: context,
      initialDate: _controlador.dia,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (dia != null) await _controlador.cambiarDia(dia);
  }

  Future<void> _abrirFormulario([Tarea? tarea]) async {
    await Navigator.pushNamed(
      context,
      Rutas.formularioTarea,
      arguments: ArgumentosFormularioTarea(
        idEstudiante: widget.estudiante.id,
        dia: _controlador.dia,
        tarea: tarea,
      ),
    );
    if (mounted) await _controlador.cargar();
  }

  Future<void> _borrar(Tarea tarea) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('¿Borrar la tarea?'),
        content: Text('Se borrará «${tarea.titulo}» de la agenda.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmado == true) await _controlador.eliminar(tarea);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controlador,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Dimensiones.espaciadoPequeno,
            ),
            child: Row(
              children: [
                IconButton.outlined(
                  tooltip: 'Día anterior',
                  onPressed: _controlador.diaAnterior,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: _elegirDia,
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: Text(FormatoFecha.diaCompleto(_controlador.dia)),
                  ),
                ),
                IconButton.outlined(
                  tooltip: 'Día siguiente',
                  onPressed: _controlador.diaSiguiente,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
                const SizedBox(width: Dimensiones.espaciado),
                FilledButton.icon(
                  onPressed: _abrirFormulario,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Nueva tarea'),
                ),
              ],
            ),
          ),
          Expanded(
            child: VistaCarga<List<Tarea>>(
              controlador: _controlador,
              constructor: (context, tareas) => tareas.isEmpty
                  ? Center(
                      child: Text(
                        'No hay tareas este día.',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    )
                  : ListView.separated(
                      itemCount: tareas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final tarea = tareas[i];
                        return Card(
                          color: tarea.tipo.color.fondo,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: Pictograma(
                              recurso: tarea.pictograma,
                              tamano: 56,
                              iconoRespaldo: Icons.event_rounded,
                            ),
                            title: Text(
                              tarea.titulo,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Paleta.tinta),
                            ),
                            subtitle: Text(
                              '${FormatoFecha.intervalo(tarea.inicio, tarea.fin)}'
                              ' · ${tarea.tipo.nombre} · ${tarea.estado.nombre}'
                              '${tarea.pasos.isEmpty ? '' : ' · ${tarea.pasos.length} pasos'}',
                              style: const TextStyle(color: Paleta.tintaSuave),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Editar ${tarea.titulo}',
                                  color: Paleta.tinta,
                                  onPressed: () => _abrirFormulario(tarea),
                                  icon: const Icon(Icons.edit_rounded),
                                ),
                                IconButton(
                                  tooltip: 'Borrar ${tarea.titulo}',
                                  color: Paleta.tinta,
                                  onPressed: () => _borrar(tarea),
                                  icon: const Icon(Icons.delete_rounded),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
