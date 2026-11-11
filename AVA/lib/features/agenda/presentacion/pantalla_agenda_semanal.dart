import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/paleta.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/utilidades/formato_fecha.dart';
import '../../../core/widgets/boton_accesible.dart';
import '../../../core/widgets/pantalla_estudiante.dart';
import '../../../core/widgets/vista_carga.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../../tareas/dominio/tarea_agenda.dart';
import '../logica/calculos_agenda.dart';
import 'widgets/boton_tarea.dart';
import 'widgets/estado_agenda_mixin.dart';

/// Agenda de la semana (HU-10): una columna por día, de lunes a domingo,
/// cada día con su color. Se ven todas las tareas de la semana a la vez:
/// cada día reparte su alto entre sus tareas. Nunca hay que desplazarse.
class PantallaAgendaSemanal extends StatefulWidget {
  const PantallaAgendaSemanal({super.key, required this.estudiante});

  final Estudiante estudiante;

  @override
  State<PantallaAgendaSemanal> createState() => _PantallaAgendaSemanalState();
}

class _PantallaAgendaSemanalState extends State<PantallaAgendaSemanal>
    with EstadoAgendaMixin {
  @override
  String get idEstudiante => widget.estudiante.id;

  Future<void> _abrirDia(DateTime dia) async {
    await Navigator.pushNamed(context, Rutas.agendaDiaria, arguments: dia);
    if (mounted) await agenda.cargar();
  }

  @override
  Widget build(BuildContext context) {
    return PantallaEstudiante(
      titulo: 'Mi semana',
      pictograma: Pictogramas.semana,
      icono: Icons.view_week_rounded,
      textoVoz: 'Mi semana. Toca un día para ver sus tareas.',
      cuerpo: VistaCarga<List<Tarea>>(
        controlador: agenda,
        constructor: (context, _) {
          final siguiente = agenda.siguienteTarea;
          final actual = agenda.tareaActual;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (indice, dia) in agenda.diasSemana.indexed) ...[
                if (indice > 0) const SizedBox(width: 8),
                Expanded(
                  child: _ColumnaDia(
                    dia: dia,
                    esHoy: CalculosAgenda.esMismoDia(dia, agenda.ahora),
                    tareas: agenda.tareasDelDia(dia),
                    idActual: actual?.id,
                    idSiguiente: siguiente?.id,
                    alPulsarDia: () => _abrirDia(dia),
                    alPulsarTarea: abrirTarea,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ColumnaDia extends StatelessWidget {
  const _ColumnaDia({
    required this.dia,
    required this.esHoy,
    required this.tareas,
    required this.idActual,
    required this.idSiguiente,
    required this.alPulsarDia,
    required this.alPulsarTarea,
  });

  static const _altoCabecera = 112.0;
  static const _altoMaximoTarea = 150.0;
  static const _separacion = 8.0;

  final DateTime dia;
  final bool esHoy;
  final List<Tarea> tareas;
  final String? idActual;
  final String? idSiguiente;
  final VoidCallback alPulsarDia;
  final void Function(Tarea tarea) alPulsarTarea;

  @override
  Widget build(BuildContext context) {
    final escala = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    final color = ColorPastel.paraIndice(dia.weekday - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _altoCabecera,
          child: BotonAccesible(
            texto: FormatoFecha.nombreDia(dia),
            textoSecundario: esHoy ? 'Hoy' : '${dia.day}',
            etiquetaSemantica:
                'Ver ${esHoy ? 'hoy, ' : ''}${FormatoFecha.diaCompleto(dia)}',
            color: color,
            seleccionado: esHoy,
            alPulsar: alPulsarDia,
          ),
        ),
        const SizedBox(height: _separacion),
        Expanded(
          child: LayoutBuilder(
            builder: (context, restricciones) {
              if (tareas.isEmpty) {
                return Center(
                  child: Text(
                    'Sin tareas',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
              }

              // Todas las tareas del día se reparten el alto disponible, para
              // verlas todas a la vez sin desplazarse.
              final alto = math.min(
                (restricciones.maxHeight - _separacion * (tareas.length - 1)) /
                    tareas.length,
                _altoMaximoTarea * escala,
              );

              return Column(
                children: [
                  for (var i = 0; i < tareas.length; i++) ...[
                    if (i > 0) const SizedBox(height: _separacion),
                    SizedBox(
                      height: alto,
                      child: BotonTarea(
                        tarea: tareas[i],
                        compacta: true,
                        disposicion: DisposicionBoton.vertical,
                        destacado: tareas[i].id == idActual
                            ? DestacadoTarea.ahora
                            : tareas[i].id == idSiguiente
                            ? DestacadoTarea.despues
                            : DestacadoTarea.ninguno,
                        alPulsar: () => alPulsarTarea(tareas[i]),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
