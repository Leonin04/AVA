import 'package:flutter/material.dart';

import '../../../core/servicios/base_datos.dart';
import '../../tareas/dominio/paso.dart';
import '../../tareas/dominio/tarea.dart';

/// T-85: detalle de una tarea. T-86: sus pasos en orden.
class PantallaDetalleTarea extends StatelessWidget {
  const PantallaDetalleTarea({super.key, required this.tareaId});

  final String tareaId;

  @override
  Widget build(BuildContext context) {
    final bd = BaseDatos();
    return StreamBuilder<Tarea?>(
      stream: bd.tarea(tareaId),
      builder: (context, snap) {
        final t = snap.data;
        return Scaffold(
          appBar: AppBar(title: Text(t?.nombre ?? 'Tarea')),
          body: snap.hasError
              ? Center(child: Text('Error: ${snap.error}'))
              : !snap.hasData
                  ? const Center(child: CircularProgressIndicator())
                  : t == null
                      ? const Center(child: Text('Esta tarea ya no existe.'))
                      : ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            if (t.pictogramaUrl.isNotEmpty)
                              Center(
                                child: Image.network(
                                  t.pictogramaUrl,
                                  height: 180,
                                  semanticLabel: t.nombre,
                                  errorBuilder: (context, error, stack) =>
                                      const Icon(Icons.broken_image, size: 120),
                                ),
                              ),
                            const SizedBox(height: 16),
                            Text(t.nombre,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 8),
                            Text('De ${t.horaInicio} a ${t.horaFin}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 22)),
                            if (t.descripcion.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(t.descripcion, style: const TextStyle(fontSize: 20)),
                            ],
                            const SizedBox(height: 24),
                            Text('Pasos', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            // T-86
                            FutureBuilder<List<Paso>>(
                              future: bd.pasosDe(t.id),
                              builder: (context, p) {
                                if (p.hasError) return Text('Error: ${p.error}');
                                if (!p.hasData) return const LinearProgressIndicator();
                                final pasos = p.data!;
                                if (pasos.isEmpty) {
                                  return const Text('Esta tarea no tiene pasos.',
                                      style: TextStyle(fontSize: 20));
                                }
                                return Column(
                                  children: [
                                    for (final paso in pasos)
                                      Card(
                                        child: ListTile(
                                          minVerticalPadding: 16,
                                          leading: CircleAvatar(
                                            radius: 22,
                                            child: Text('${paso.orden}',
                                                style: const TextStyle(fontSize: 20)),
                                          ),
                                          title: Text(paso.texto,
                                              style: const TextStyle(fontSize: 22)),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
        );
      },
    );
  }
}
