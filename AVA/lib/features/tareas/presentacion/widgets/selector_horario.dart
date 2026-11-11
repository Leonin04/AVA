import 'package:flutter/material.dart';

import '../../../../core/constantes/dimensiones.dart';
import '../../../../core/utilidades/formato_fecha.dart';

/// Fecha, hora de inicio y hora de fin de una tarea (HU-05).
class SelectorHorario extends StatelessWidget {
  const SelectorHorario({
    super.key,
    required this.dia,
    required this.inicio,
    required this.fin,
    required this.alCambiarDia,
    required this.alCambiarInicio,
    required this.alCambiarFin,
    this.error,
  });

  final DateTime dia;
  final TimeOfDay inicio;
  final TimeOfDay fin;
  final ValueChanged<DateTime> alCambiarDia;
  final ValueChanged<TimeOfDay> alCambiarInicio;
  final ValueChanged<TimeOfDay> alCambiarFin;
  final String? error;

  static String _hora(TimeOfDay hora) =>
      '${hora.hour.toString().padLeft(2, '0')}:'
      '${hora.minute.toString().padLeft(2, '0')}';

  Future<void> _elegirDia(BuildContext context) async {
    final elegido = await showDatePicker(
      context: context,
      initialDate: dia,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (elegido != null) alCambiarDia(elegido);
  }

  Future<void> _elegirHora(
    BuildContext context,
    TimeOfDay actual,
    ValueChanged<TimeOfDay> alElegir,
  ) async {
    final elegida = await showTimePicker(
      context: context,
      initialTime: actual,
      builder: (context, hijo) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: hijo!,
      ),
    );
    if (elegida != null) alElegir(elegida);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Dimensiones.espaciadoPequeno,
          runSpacing: Dimensiones.espaciadoPequeno,
          children: [
            OutlinedButton.icon(
              onPressed: () => _elegirDia(context),
              icon: const Icon(Icons.calendar_month_rounded),
              label: Text(FormatoFecha.diaCompleto(dia)),
            ),
            OutlinedButton.icon(
              onPressed: () => _elegirHora(context, inicio, alCambiarInicio),
              icon: const Icon(Icons.schedule_rounded),
              label: Text('Empieza: ${_hora(inicio)}'),
            ),
            OutlinedButton.icon(
              onPressed: () => _elegirHora(context, fin, alCambiarFin),
              icon: const Icon(Icons.schedule_rounded),
              label: Text('Termina: ${_hora(fin)}'),
            ),
          ],
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 18,
              ),
            ),
          ),
      ],
    );
  }
}
