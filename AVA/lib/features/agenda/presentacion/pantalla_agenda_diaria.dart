import 'package:flutter/material.dart';

import '../../../core/constantes/dimensiones.dart';
import '../../../core/utilidades/formato_fecha.dart';
import '../../../core/widgets/mensaje_informativo.dart';
import '../../../core/widgets/vista_carga.dart';
import '../../perfil/dominio/estudiante.dart';
import '../../tareas/dominio/tarea.dart';
import '../logica/calculos_agenda.dart';
import 'widgets/estado_agenda_mixin.dart';
import 'widgets/tarjeta_tarea.dart';

/// Agenda de un día: las tareas ordenadas por hora, cada una con un botón
/// para ver su detalle (HU-09). Se resaltan la tarea actual y la siguiente.
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
    if (tarea.id == agenda.siguienteTarea?.id) return DestacadoTarea.siguiente;
    return DestacadoTarea.ninguno;
  }

  @override
  Widget build(BuildContext context) {
    final esHoy = CalculosAgenda.esMismoDia(_dia, agenda.ahora);

    return Scaffold(
      appBar: AppBar(title: Text(esHoy ? 'Hoy' : 'Mi día')),
      body: SafeArea(
        child: VistaCarga<List<Tarea>>(
          controlador: agenda,
          constructor: (context, _) {
            final tareas = agenda.tareasDelDia(_dia);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: Dimensiones.anchoMaximoContenido,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(Dimensiones.espaciado),
                      child: _CabeceraDia(texto: FormatoFecha.diaCompleto(_dia)),
                    ),
                    Expanded(
                      child: tareas.isEmpty
                          ? const MensajeInformativo(
                              icono: Icons.event_available,
                              texto: 'No hay tareas para este día',
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                Dimensiones.espaciado,
                                0,
                                Dimensiones.espaciado,
                                Dimensiones.espaciado,
                              ),
                              itemCount: tareas.length,
                              separatorBuilder: (_, __) => const SizedBox(
                                height: Dimensiones.espaciado,
                              ),
                              itemBuilder: (context, indice) => _FilaTarea(
                                tarea: tareas[indice],
                                destacado: _destacado(tareas[indice]),
                                alVer: () => abrirTarea(tareas[indice]),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CabeceraDia extends StatelessWidget {
  const _CabeceraDia({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Semantics(
      header: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Dimensiones.espaciado),
        decoration: BoxDecoration(
          color: esquema.primary,
          borderRadius: BorderRadius.circular(Dimensiones.radioBorde),
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: esquema.onPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _FilaTarea extends StatelessWidget {
  const _FilaTarea({
    required this.tarea,
    required this.destacado,
    required this.alVer,
  });

  final Tarea tarea;
  final DestacadoTarea destacado;
  final VoidCallback alVer;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TarjetaTarea(
            tarea: tarea,
            destacado: destacado,
            alPulsar: alVer,
          ),
        ),
        const SizedBox(width: Dimensiones.espaciadoPequeno),
        IconButton.filledTonal(
          tooltip: 'Ver ${tarea.titulo}',
          onPressed: alVer,
          icon: const Icon(Icons.visibility),
        ),
      ],
    );
  }
}
