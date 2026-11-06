import 'package:flutter/material.dart';

import '../../../../core/constantes/dimensiones.dart';
import '../../../../core/utilidades/formato_fecha.dart';
import '../../../tareas/dominio/tarea.dart';
import '../../../tareas/presentacion/widgets/etiqueta_estado_tarea.dart';

/// Marca visual para distinguir la tarea actual y la siguiente (HU-10).
enum DestacadoTarea { ninguno, ahora, siguiente }

/// Tarjeta pulsable con el horario y el título de una tarea.
class TarjetaTarea extends StatelessWidget {
  const TarjetaTarea({
    super.key,
    required this.tarea,
    required this.alPulsar,
    this.destacado = DestacadoTarea.ninguno,
    this.compacta = false,
  });

  final Tarea tarea;
  final VoidCallback alPulsar;
  final DestacadoTarea destacado;

  /// Versión reducida para la vista semanal.
  final bool compacta;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final completada = tarea.estado == EstadoTarea.completada;

    final (colorFondo, etiqueta) = switch (destacado) {
      DestacadoTarea.ahora => (esquema.primaryContainer, 'AHORA'),
      DestacadoTarea.siguiente => (esquema.tertiaryContainer, 'SIGUIENTE'),
      DestacadoTarea.ninguno => (esquema.surfaceContainerHigh, null),
    };

    return Card(
      margin: EdgeInsets.zero,
      color: colorFondo,
      child: InkWell(
        onTap: alPulsar,
        borderRadius: BorderRadius.circular(Dimensiones.radioBorde),
        child: Padding(
          padding: EdgeInsets.all(
            compacta ? Dimensiones.espaciadoPequeno : Dimensiones.espaciado,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (etiqueta != null)
                Text(
                  etiqueta,
                  style: textos.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              Text(
                FormatoFecha.intervalo(tarea.inicio, tarea.fin),
                style: compacta ? textos.bodyMedium : textos.titleMedium,
              ),
              Text(
                tarea.titulo,
                style: (compacta ? textos.titleSmall : textos.titleLarge)
                    ?.copyWith(
                  fontWeight: FontWeight.w700,
                  decoration: completada ? TextDecoration.lineThrough : null,
                ),
              ),
              if (!compacta) ...[
                if (tarea.tipo == TipoTarea.encargoCentro)
                  Text('Encargo del centro', style: textos.bodyLarge),
                const SizedBox(height: 8),
                EtiquetaEstadoTarea(estado: tarea.estado),
              ] else if (completada)
                Icon(Icons.check_circle, size: 20, color: esquema.primary),
            ],
          ),
        ),
      ),
    );
  }
}
