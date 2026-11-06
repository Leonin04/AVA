import 'package:flutter/material.dart';

import '../../../core/constantes/dimensiones.dart';
import '../../../core/widgets/boton_grande.dart';
import '../../../core/widgets/mensaje_informativo.dart';
import '../../../core/widgets/vista_carga.dart';
import '../../perfil/dominio/estudiante.dart';
import '../../tareas/dominio/tarea.dart';
import 'widgets/estado_agenda_mixin.dart';
import 'widgets/tarjeta_tarea.dart';

/// Anticipación de la siguiente tarea (HU-10): muestra lo que el estudiante
/// está haciendo ahora y, destacada, la próxima actividad.
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

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Siguiente tarea')),
      body: SafeArea(
        child: VistaCarga<List<Tarea>>(
          controlador: agenda,
          constructor: (context, _) {
            final actual = agenda.tareaActual;
            final siguiente = agenda.siguienteTarea;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensiones.espaciado),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: Dimensiones.anchoMaximoContenido,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (actual != null) ...[
                        Text('Ahora estás en', style: textos.titleLarge),
                        const SizedBox(height: Dimensiones.espaciadoPequeno),
                        TarjetaTarea(
                          tarea: actual,
                          destacado: DestacadoTarea.ahora,
                          alPulsar: () => abrirTarea(actual),
                        ),
                        const SizedBox(height: Dimensiones.espaciado * 1.5),
                      ],
                      Text('Lo siguiente es', style: textos.headlineSmall),
                      const SizedBox(height: Dimensiones.espaciadoPequeno),
                      if (siguiente == null)
                        const MensajeInformativo(
                          icono: Icons.event_available,
                          texto: 'No hay más tareas programadas',
                        )
                      else ...[
                        TarjetaTarea(
                          tarea: siguiente,
                          destacado: DestacadoTarea.siguiente,
                          alPulsar: () => abrirTarea(siguiente),
                        ),
                        const SizedBox(height: Dimensiones.espaciado),
                        BotonGrande(
                          texto: 'Ver tarea',
                          icono: Icons.visibility,
                          alPulsar: () => abrirTarea(siguiente),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
