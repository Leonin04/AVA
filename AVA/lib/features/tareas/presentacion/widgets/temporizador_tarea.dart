import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constantes/dimensiones.dart';
import '../../../../core/constantes/paleta.dart';
import '../../../../core/tema/ajustes_interfaz.dart';
import '../../dominio/tarea_agenda.dart';
import '../../logica/tiempo_restante.dart';

/// Temporizador visual de una tarea (HU-22): una barra que se va vaciando
/// y el tiempo que queda en palabras. Se actualiza cada segundo y, al
/// acabar el tiempo, lo dice sin alarmas ni sonidos bruscos (RNF-11).
class TemporizadorTarea extends StatefulWidget {
  const TemporizadorTarea({super.key, required this.tarea, this.reloj});

  final Tarea tarea;

  /// Permite fijar la hora en las pruebas.
  final DateTime Function()? reloj;

  @override
  State<TemporizadorTarea> createState() => _TemporizadorTareaState();
}

class _TemporizadorTareaState extends State<TemporizadorTarea> {
  Timer? _cada1s;

  DateTime _ahora() => (widget.reloj ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _cada1s = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _cada1s?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tiempo = TiempoRestante.en(
      _ahora(),
      widget.tarea.inicio,
      widget.tarea.fin,
    );
    final estilo = AjustesInterfaz.of(context).estiloDe(ColorPastel.amarillo);

    return Semantics(
      label: 'Temporizador. ${tiempo.texto}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(Dimensiones.espaciadoPequeno),
        decoration: BoxDecoration(
          color: estilo.fondo,
          borderRadius: BorderRadius.circular(Dimensiones.radioBordePequeno),
          border: Border.all(
            color: estilo.borde,
            width: Dimensiones.grosorBorde,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.hourglass_bottom_rounded,
              color: estilo.acento,
              size: 36,
            ),
            const SizedBox(width: Dimensiones.espaciadoPequeno),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      tiempo.texto,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: estilo.texto),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: tiempo.fraccion,
                      minHeight: 14,
                      color: estilo.acento,
                      backgroundColor: estilo.fondo,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
