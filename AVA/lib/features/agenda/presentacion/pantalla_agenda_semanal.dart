import 'package:flutter/material.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/dimensiones.dart';
import '../../../core/utilidades/formato_fecha.dart';
import '../../../core/widgets/vista_carga.dart';
import '../../perfil/dominio/estudiante.dart';
import '../../tareas/dominio/tarea.dart';
import '../logica/calculos_agenda.dart';
import 'widgets/estado_agenda_mixin.dart';
import 'widgets/tarjeta_tarea.dart';

/// Agenda de la semana: una columna por día, de lunes a domingo (HU-09).
/// Al pulsar un día se abre su agenda diaria; al pulsar una tarea, su
/// detalle.
class PantallaAgendaSemanal extends StatefulWidget {
  const PantallaAgendaSemanal({super.key, required this.estudiante});

  final Estudiante estudiante;

  @override
  State<PantallaAgendaSemanal> createState() => _PantallaAgendaSemanalState();
}

class _PantallaAgendaSemanalState extends State<PantallaAgendaSemanal>
    with EstadoAgendaMixin {
  /// Por debajo de este ancho por día, la semana se desplaza en horizontal.
  static const double _anchoMinimoDia = 150;

  @override
  String get idEstudiante => widget.estudiante.id;

  Future<void> _abrirDia(DateTime dia) async {
    await Navigator.pushNamed(context, Rutas.agendaDiaria, arguments: dia);
    if (mounted) await agenda.cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi semana')),
      body: SafeArea(
        child: VistaCarga<List<Tarea>>(
          controlador: agenda,
          constructor: (context, _) => LayoutBuilder(
            builder: (context, restricciones) {
              final siguiente = agenda.siguienteTarea;
              final columnas = [
                for (final dia in agenda.diasSemana)
                  _ColumnaDia(
                    dia: dia,
                    esHoy: CalculosAgenda.esMismoDia(dia, agenda.ahora),
                    tareas: agenda.tareasDelDia(dia),
                    idSiguiente: siguiente?.id,
                    alPulsarDia: () => _abrirDia(dia),
                    alPulsarTarea: abrirTarea,
                  ),
              ];

              final caben = restricciones.maxWidth / CalculosAgenda.diasPorSemana >=
                  _anchoMinimoDia;
              if (caben) {
                return Padding(
                  padding: const EdgeInsets.all(Dimensiones.espaciadoPequeno),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final columna in columnas) Expanded(child: columna),
                    ],
                  ),
                );
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(Dimensiones.espaciadoPequeno),
                child: SizedBox(
                  height: restricciones.maxHeight -
                      Dimensiones.espaciadoPequeno * 2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final columna in columnas)
                        SizedBox(width: _anchoMinimoDia + 20, child: columna),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ColumnaDia extends StatelessWidget {
  const _ColumnaDia({
    required this.dia,
    required this.esHoy,
    required this.tareas,
    required this.idSiguiente,
    required this.alPulsarDia,
    required this.alPulsarTarea,
  });

  final DateTime dia;
  final bool esHoy;
  final List<Tarea> tareas;
  final String? idSiguiente;
  final VoidCallback alPulsarDia;
  final void Function(Tarea tarea) alPulsarTarea;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final colorTexto = esHoy ? esquema.onPrimary : esquema.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            label: 'Ver el ${FormatoFecha.diaCompleto(dia)}',
            excludeSemantics: true,
            child: Material(
              color: esHoy ? esquema.primary : esquema.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(Dimensiones.radioBorde),
              child: InkWell(
                onTap: alPulsarDia,
                borderRadius: BorderRadius.circular(Dimensiones.radioBorde),
                child: Padding(
                  padding: const EdgeInsets.all(Dimensiones.espaciadoPequeno),
                  child: Column(
                    children: [
                      Text(
                        FormatoFecha.nombreDia(dia),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: colorTexto,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        '${dia.day}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: colorTexto),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Dimensiones.espaciadoPequeno),
          Expanded(
            child: tareas.isEmpty
                ? Center(
                    child: Text(
                      'Sin tareas',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : ListView.separated(
                    itemCount: tareas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, indice) {
                      final tarea = tareas[indice];
                      return TarjetaTarea(
                        tarea: tarea,
                        compacta: true,
                        destacado: tarea.id == idSiguiente
                            ? DestacadoTarea.siguiente
                            : DestacadoTarea.ninguno,
                        alPulsar: () => alPulsarTarea(tarea),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
