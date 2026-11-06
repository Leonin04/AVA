import 'package:flutter/material.dart';

import '../../../core/servicios/base_datos.dart';
import '../../perfil/dominio/estudiante.dart';
import '../../tareas/dominio/tarea.dart';
import '../logica/agenda_dia.dart';
import 'pantalla_detalle_tarea.dart';

/// T-84: agenda del día del estudiante, con sus tareas en orden.
/// Al pulsar una tarea se abre su detalle (T-85).
class PantallaAgendaDia extends StatelessWidget {
  const PantallaAgendaDia({super.key, required this.estudiante, this.dia});

  final Estudiante estudiante;

  /// Día a mostrar (por defecto, hoy).
  final DateTime? dia;

  @override
  Widget build(BuildContext context) {
    final hoy = dia ?? DateTime.now();
    return Scaffold(
      appBar: AppBar(title: Text(fechaLarga(hoy))),
      body: StreamBuilder<List<Tarea>>(
        stream: BaseDatos().tareasDeEstudiante(estudiante.id),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final tareas = tareasDelDia(snap.data!, hoy); // T-81 y T-82
          if (tareas.isEmpty) {
            return const Center(
              child: Text('Hoy no tienes tareas', style: TextStyle(fontSize: 24)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tareas.length,
            separatorBuilder: (context, i) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _FilaTarea(
              tarea: tareas[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PantallaDetalleTarea(tareaId: tareas[i].id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Fila provisional de la lista. La tarjeta definitiva (T-83) la
/// hace otro miembro: cuando esté, se sustituye este widget por ella.
class _FilaTarea extends StatelessWidget {
  const _FilaTarea({required this.tarea, required this.onTap});

  final Tarea tarea;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${tarea.nombre}, de ${tarea.horaInicio} a ${tarea.horaFin}',
      excludeSemantics: true,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: tarea.pictogramaUrl.isEmpty
                      ? const Icon(Icons.task_alt, size: 56)
                      : Image.network(tarea.pictogramaUrl,
                          errorBuilder: (context, error, stack) =>
                              const Icon(Icons.broken_image, size: 56)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(tarea.nombre,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                ),
                Text(tarea.horaInicio, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
