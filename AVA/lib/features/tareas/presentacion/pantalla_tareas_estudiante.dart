import 'package:flutter/material.dart';

import '../../../core/servicios/base_datos.dart';
import '../../autenticacion/dominio/usuario.dart';
import '../../perfil/dominio/estudiante.dart';
import '../dominio/tarea.dart';
import 'pantalla_formulario_tarea.dart';

/// Lista de las tareas de un estudiante (T-65) con
/// crear (T-66), editar (T-79) y eliminar (T-80).
class PantallaTareasEstudiante extends StatelessWidget {
  const PantallaTareasEstudiante({
    super.key,
    required this.usuario,
    required this.estudiante,
  });

  final Usuario usuario;
  final Estudiante estudiante;

  static const _dias = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  String _cuando(Tarea t) {
    if (t.seRepite) return t.diasSemana.map((d) => _dias[d - 1]).join(' ');
    return t.fecha ?? '';
  }

  void _abrirFormulario(BuildContext context, {Tarea? tarea}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaFormularioTarea(
          usuario: usuario,
          estudianteInicial: estudiante.id,
          tareaEditar: tarea,
        ),
      ),
    );
  }

  Future<void> _eliminar(BuildContext context, Tarea t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Seguro que quieres eliminar «${t.nombre}»? '
            'Desaparecerá de la agenda de todos sus estudiantes.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;
    await BaseDatos().eliminarTarea(t.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('«${t.nombre}» eliminada')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tareas de ${estudiante.nombre}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
      body: StreamBuilder<List<Tarea>>(
        stream: BaseDatos().tareasDeEstudiante(estudiante.id),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final tareas = snap.data!;
          if (tareas.isEmpty) {
            return const Center(child: Text('Este estudiante no tiene tareas.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: tareas.length,
            separatorBuilder: (context, i) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final t = tareas[i];
              final puedeEditar = usuario.esAdmin || t.creadaPor == usuario.id;
              return Card(
                child: ListTile(
                  minVerticalPadding: 12,
                  leading: SizedBox(
                    width: 56,
                    height: 56,
                    child: t.pictogramaUrl.isEmpty
                        ? const Icon(Icons.task_alt, size: 40)
                        : Image.network(t.pictogramaUrl,
                            errorBuilder: (context, error, stack) =>
                                const Icon(Icons.broken_image)),
                  ),
                  title: Text(t.nombre, style: const TextStyle(fontSize: 18)),
                  subtitle: Text('${t.horaInicio}–${t.horaFin} · ${_cuando(t)} · ${t.tipo.texto}'),
                  onTap: puedeEditar ? () => _abrirFormulario(context, tarea: t) : null,
                  trailing: puedeEditar
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Editar',
                              icon: const Icon(Icons.edit),
                              onPressed: () => _abrirFormulario(context, tarea: t),
                            ),
                            IconButton(
                              tooltip: 'Eliminar',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _eliminar(context, t),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
