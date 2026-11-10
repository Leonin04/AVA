import 'package:flutter/material.dart';

import '../../../core/constantes/dimensiones.dart';
import '../../../core/constantes/paleta.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/utilidades/formato_fecha.dart';
import '../../../core/widgets/boton_accesible.dart';
import '../../../core/widgets/cuadricula_ajustada.dart';
import '../../../core/widgets/mensaje_informativo.dart';
import '../../../core/widgets/pantalla_estudiante.dart';
import '../../../core/widgets/vista_carga.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../../tareas/dominio/tarea_agenda.dart';
import '../logica/calculos_agenda.dart';
import 'widgets/boton_tarea.dart';
import 'widgets/estado_agenda_mixin.dart';

/// Agenda de un día (HU-09): las tareas ordenadas por hora, cada una con un
/// botón «Ver». Se distinguen la tarea de ahora y la de después (HU-10).
/// Se ven todas a la vez: si hay muchas, se hacen más pequeñas.
class PantallaAgendaDiaria extends StatefulWidget {
  const PantallaAgendaDiaria({super.key, required this.estudiante, this.dia});

  final Estudiante estudiante;

  /// Día a mostrar. Si es `null`, hoy.
  final DateTime? dia;

  @override
  State<PantallaAgendaDiaria> createState() => _PantallaAgendaDiariaState();
}

class _PantallaAgendaDiariaState extends State<PantallaAgendaDiaria>
    with EstadoAgendaMixin {
  @override
  String get idEstudiante => widget.estudiante.id;

  @override
  DateTime? get diaReferencia => widget.dia;

  DateTime get _dia => widget.dia ?? agenda.ahora;

  DestacadoTarea _destacado(Tarea tarea) {
    if (tarea.id == agenda.tareaActual?.id) return DestacadoTarea.ahora;
    if (tarea.id == agenda.siguienteTarea?.id) return DestacadoTarea.despues;
    return DestacadoTarea.ninguno;
  }

  @override
  Widget build(BuildContext context) {
    final esHoy = CalculosAgenda.esMismoDia(_dia, agenda.ahora);
    final nombreDia = FormatoFecha.diaCompleto(_dia);

    return PantallaEstudiante(
      titulo: esHoy ? 'Hoy, $nombreDia' : nombreDia,
      pictograma: Pictogramas.calendario,
      icono: Icons.today_rounded,
      color: ColorPastel.paraIndice(_dia.weekday - 1),
      textoVoz: _textoVoz(esHoy, nombreDia),
      cuerpo: VistaCarga<List<Tarea>>(
        controlador: agenda,
        constructor: (context, _) {
          final tareas = agenda.tareasDelDia(_dia);
          if (tareas.isEmpty) {
            return const MensajeInformativo(
              icono: Icons.event_available_rounded,
              pictograma: Pictogramas.descansar,
              texto: 'Este día no tienes tareas.',
            );
          }
          return CuadriculaAjustada<Tarea>(
            elementos: tareas,
            maxColumnas: tareas.length > 6 ? 2 : 1,
            anchoMinimoCelda: 400,
            altoMinimoCelda: 104,
            altoMaximoCelda: 140,
            espaciado: Dimensiones.espaciadoPequeno,
            constructor: (context, tarea) => Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: BotonTarea(
                    tarea: tarea,
                    destacado: _destacado(tarea),
                    alPulsar: () => abrirTarea(tarea),
                  ),
                ),
                const SizedBox(width: Dimensiones.espaciadoPequeno),
                SizedBox(
                  width: 160,
                  child: BotonAccesible(
                    texto: 'Ver',
                    etiquetaSemantica: 'Ver ${tarea.titulo}',
                    pictograma: Pictogramas.ojo,
                    icono: Icons.visibility_rounded,
                    color: ColorPastel.cielo,
                    disposicion: DisposicionBoton.horizontal,
                    alPulsar: () => abrirTarea(tarea),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _textoVoz(bool esHoy, String nombreDia) {
    final tareas = agenda.tareasDelDia(_dia);
    final inicio = esHoy ? 'Hoy es $nombreDia.' : '$nombreDia.';
    if (tareas.isEmpty) return '$inicio No tienes tareas.';
    final lista = tareas
        .map(
          (t) =>
              '${t.titulo} a las ${t.inicio.hour}:'
              '${t.inicio.minute.toString().padLeft(2, '0')}',
        )
        .join('. ');
    return '$inicio Tus tareas son: $lista.';
  }
}
