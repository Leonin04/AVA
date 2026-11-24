import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constantes/dimensiones.dart';
import '../../../core/utilidades/formato_fecha.dart';
import '../../../core/widgets/pantalla_gestion.dart';
import '../../../core/widgets/vista_carga.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../../tareas/dominio/evento_historial.dart';
import '../../tareas/dominio/repositorio_tareas.dart';
import '../logica/historial_controlador.dart';

/// Historial de tareas completadas de un estudiante por día o por semana
/// (HU-27): cada día con sus tareas, la hora en que se terminaron y quién
/// lo registró.
class PantallaHistorial extends StatefulWidget {
  const PantallaHistorial({super.key, required this.estudiante});

  final Estudiante estudiante;

  @override
  State<PantallaHistorial> createState() => _PantallaHistorialState();
}

class _PantallaHistorialState extends State<PantallaHistorial> {
  late final HistorialControlador _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = HistorialControlador(
      tareas: context.read<RepositorioTareas>(),
      idEstudiante: widget.estudiante.id,
    );
    unawaited(_controlador.cargar());
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  String get _textoPeriodo {
    final desde = _controlador.desde;
    final ultimo = _controlador.hasta.subtract(const Duration(days: 1));
    return _controlador.periodo == PeriodoHistorial.dia
        ? FormatoFecha.diaCompleto(desde)
        : '${FormatoFecha.diaCompleto(desde)} – '
              '${FormatoFecha.diaCompleto(ultimo)}';
  }

  @override
  Widget build(BuildContext context) {
    return PantallaGestion(
      titulo: 'Historial de ${widget.estudiante.nombre}',
      cuerpo: ListenableBuilder(
        listenable: _controlador,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<PeriodoHistorial>(
              segments: [
                for (final periodo in PeriodoHistorial.values)
                  ButtonSegment(value: periodo, label: Text(periodo.nombre)),
              ],
              selected: {_controlador.periodo},
              onSelectionChanged: (s) => _controlador.cambiarPeriodo(s.first),
            ),
            const SizedBox(height: Dimensiones.espaciadoPequeno),
            Row(
              children: [
                IconButton(
                  tooltip: 'Periodo anterior',
                  onPressed: () => _controlador.mover(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Text(
                    _textoPeriodo,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Periodo siguiente',
                  onPressed: () => _controlador.mover(1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            VistaCarga<List<EventoHistorial>>(
              controlador: _controlador,
              constructor: (context, _) {
                final porDia = _controlador.completadasPorDia;
                return porDia.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(Dimensiones.espaciado),
                        child: Text(
                          'No hay tareas terminadas en este periodo.',
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final MapEntry(key: dia, value: eventos)
                              in porDia.entries) ...[
                            TituloSeccion(
                              FormatoFecha.diaCompleto(dia),
                              descripcion:
                                  '${eventos.length} '
                                  '${eventos.length == 1 ? 'tarea terminada' : 'tareas terminadas'}',
                            ),
                            for (final evento in eventos)
                              Card(
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.check_circle_rounded,
                                  ),
                                  title: Text(evento.tituloTarea),
                                  subtitle: Text(
                                    'Terminada a las '
                                    '${FormatoFecha.hora(evento.momento)} · '
                                    '${evento.origen.nombre}',
                                  ),
                                ),
                              ),
                          ],
                        ],
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
