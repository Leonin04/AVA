import 'package:flutter/material.dart';

import '../../../core/constantes/dimensiones.dart';
import '../../../core/constantes/paleta.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/modelos/recurso_visual.dart';
import '../../../core/tema/ajustes_interfaz.dart';
import '../../../core/utilidades/formato_fecha.dart';
import '../../../core/widgets/boton_accesible.dart';
import '../../../core/widgets/pantalla_estudiante.dart';
import '../../../core/widgets/pictograma.dart';
import '../../../core/widgets/vista_carga.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../../tareas/dominio/tarea_agenda.dart';
import 'widgets/boton_tarea.dart';
import 'widgets/estado_agenda_mixin.dart';

/// Anticipación (HU-11) con el formato «ahora / después», muy usado en
/// agendas visuales: a la izquierda lo que toca ahora y a la derecha lo
/// siguiente, grande y destacado (personas Álex y Diego).
class PantallaSiguienteTarea extends StatefulWidget {
  const PantallaSiguienteTarea({super.key, required this.estudiante});

  final Estudiante estudiante;

  @override
  State<PantallaSiguienteTarea> createState() => _PantallaSiguienteTareaState();
}

class _PantallaSiguienteTareaState extends State<PantallaSiguienteTarea>
    with EstadoAgendaMixin {
  @override
  String get idEstudiante => widget.estudiante.id;

  String _textoVoz() {
    final actual = agenda.tareaActual;
    final siguiente = agenda.siguienteTarea;
    final ahora = actual == null
        ? 'Ahora no tienes tarea.'
        : 'Ahora: ${actual.titulo}.';
    final despues = siguiente == null
        ? 'Después no hay más tareas.'
        : 'Después: ${siguiente.titulo}, '
              '${FormatoFecha.intervaloHablado(siguiente.inicio, siguiente.fin)}.';
    return '$ahora $despues';
  }

  @override
  Widget build(BuildContext context) {
    return PantallaEstudiante(
      titulo: 'Ahora y después',
      pictograma: Pictogramas.despues,
      icono: Icons.skip_next_rounded,
      color: ColorPastel.melocoton,
      textoVoz: _textoVoz(),
      cuerpo: VistaCarga<List<Tarea>>(
        controlador: agenda,
        constructor: (context, _) {
          final actual = agenda.tareaActual;
          final siguiente = agenda.siguienteTarea;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: actual == null
                    ? const _PanelVacio(
                        etiqueta: 'AHORA',
                        texto: 'Ahora no tienes tarea',
                        pictograma: Pictogramas.descansar,
                        icono: Icons.weekend_rounded,
                      )
                    : BotonTarea(
                        tarea: actual,
                        destacado: DestacadoTarea.ahora,
                        disposicion: DisposicionBoton.vertical,
                        alPulsar: () => abrirTarea(actual),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensiones.espaciado,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.onSurface,
                  semanticLabel: 'y después',
                ),
              ),
              Expanded(
                child: siguiente == null
                    ? const _PanelVacio(
                        etiqueta: 'DESPUÉS',
                        texto: 'No hay más tareas',
                        pictograma: Pictogramas.exito,
                        icono: Icons.celebration_rounded,
                      )
                    : BotonTarea(
                        tarea: siguiente,
                        destacado: DestacadoTarea.despues,
                        disposicion: DisposicionBoton.vertical,
                        alPulsar: () => abrirTarea(siguiente),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Hueco del panel cuando no hay tarea, para que la estructura «ahora /
/// después» se mantenga igual.
class _PanelVacio extends StatelessWidget {
  const _PanelVacio({
    required this.etiqueta,
    required this.texto,
    required this.pictograma,
    required this.icono,
  });

  final String etiqueta;
  final String texto;
  final RecursoVisual pictograma;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final ajustes = AjustesInterfaz.of(context);

    return Semantics(
      label: '$etiqueta. $texto',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: esquema.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(Dimensiones.radioBorde),
          border: Border.all(
            color: esquema.outline,
            width: Dimensiones.grosorBorde,
          ),
        ),
        padding: const EdgeInsets.all(Dimensiones.espaciado),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(etiqueta, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              if (ajustes.mostrarPictogramas)
                Pictograma(
                  recurso: pictograma,
                  tamano: 160,
                  iconoRespaldo: icono,
                ),
              const SizedBox(height: 8),
              Text(texto, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
