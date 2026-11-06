import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/paleta.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/utilidades/formato_fecha.dart';
import '../../../core/utilidades/paginacion.dart';
import '../../../core/widgets/boton_accesible.dart';
import '../../../core/widgets/pantalla_estudiante.dart';
import '../../../core/widgets/vista_carga.dart';
import '../../perfil/dominio/estudiante.dart';
import '../../tareas/dominio/tarea.dart';
import '../logica/calculos_agenda.dart';
import 'widgets/boton_tarea.dart';
import 'widgets/estado_agenda_mixin.dart';

/// Agenda de la semana (HU-09): una columna por día, de lunes a domingo,
/// cada día con su color y su pictograma. Si las tareas de un día no caben,
/// se muestra «Ver N más», que abre ese día. Nunca hay que desplazarse.
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
  static const _altoMinimoTarea = 92.0;
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

              final caben = Paginacion.cuantosCaben(
                disponible: restricciones.maxHeight,
                tamanoMinimo: _altoMinimoTarea * escala,
                espaciado: _separacion,
              );
              final hayMas = tareas.length > caben;
              final visibles = hayMas ? math.max(0, caben - 1) : tareas.length;
              final filas = hayMas ? caben : tareas.length;
              final alto = math.min(
                (restricciones.maxHeight - _separacion * (filas - 1)) / filas,
                150 * escala,
              );

              return Column(
                children: [
                  for (var i = 0; i < visibles; i++) ...[
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
                  if (hayMas) ...[
                    if (visibles > 0) const SizedBox(height: _separacion),
                    SizedBox(
                      height: alto,
                      child: BotonAccesible(
                        texto: 'Ver ${tareas.length - visibles} más',
                        icono: Icons.more_horiz_rounded,
                        color: color,
                        alPulsar: alPulsarDia,
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
