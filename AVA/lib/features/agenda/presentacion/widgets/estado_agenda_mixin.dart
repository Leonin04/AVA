import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/rutas.dart';
import '../../../tareas/dominio/repositorio_tareas.dart';
import '../../../tareas/dominio/tarea_agenda.dart';
import '../../logica/agenda_controlador.dart';

/// Comportamiento común a las vistas de la agenda: crear y liberar el
/// [AgendaControlador] y abrir el detalle de una tarea, recargando la agenda
/// al volver por si el estudiante la ha empezado o terminado.
///
/// La pantalla se vuelve a construir cuando cambian las tareas, para que lo
/// que se calcula con ellas fuera de la lista (como el texto de «Escuchar»)
/// no se quede con la agenda vacía de antes de cargar (T-81).
mixin EstadoAgendaMixin<T extends StatefulWidget> on State<T> {
  late final AgendaControlador agenda;

  String get idEstudiante;

  /// Día cuya semana se carga. Por defecto, la semana actual.
  DateTime? get diaReferencia => null;

  @override
  void initState() {
    super.initState();
    agenda = AgendaControlador(
      repositorio: context.read<RepositorioTareas>(),
      idEstudiante: idEstudiante,
      diaReferencia: diaReferencia,
    )..addListener(_alCambiarAgenda);
    unawaited(agenda.cargar());
  }

  void _alCambiarAgenda() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    agenda
      ..removeListener(_alCambiarAgenda)
      ..dispose();
    super.dispose();
  }

  Future<void> abrirTarea(Tarea tarea) async {
    await Navigator.pushNamed(context, Rutas.detalleTarea, arguments: tarea);
    if (mounted) await agenda.cargar();
  }
}
