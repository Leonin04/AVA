import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/servicios/base_datos.dart';
import '../features/agenda/presentacion/pantalla_agenda_dia.dart';
import '../features/autenticacion/dominio/usuario.dart';
import '../features/perfil/dominio/estudiante.dart';
import '../features/tareas/presentacion/pantalla_tareas_estudiante.dart';

/// PANTALLA SOLO PARA DESARROLLO.
/// Permite probar Tareas y Agenda mientras no exista el login real:
/// entra como admin o tutor, elige un estudiante y abre sus tareas o su agenda.
class PantallaDesarrollo extends StatefulWidget {
  const PantallaDesarrollo({super.key});

  @override
  State<PantallaDesarrollo> createState() => _PantallaDesarrolloState();
}

class _PantallaDesarrolloState extends State<PantallaDesarrollo> {
  final _bd = BaseDatos();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  Usuario? _usuario;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    setState(() => _error = null);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text,
      );
      final u = await _bd.obtenerUsuario(cred.user!.uid);
      if (u == null) {
        setState(() => _error = 'Esa cuenta no está en la colección usuarios.');
        return;
      }
      setState(() => _usuario = u);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = 'Login: ${e.code}');
    }
  }

  /// Crea un estudiante sin cuenta de acceso, solo para tener datos.
  Future<void> _crearEstudiantePrueba() async {
    final id = FirebaseFirestore.instance.collection('estudiantes').doc().id;
    final n = DateTime.now().millisecondsSinceEpoch % 1000;
    await _bd.crearEstudiante(Estudiante(
      id: id,
      nombre: 'Estudiante prueba $n',
      usuario: 'prueba$n',
      tutores: [_usuario!.id],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final u = _usuario;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desarrollo: Tareas y Agenda'),
        actions: [
          if (u != null)
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                setState(() => _usuario = null);
              },
              child: const Text('Salir'),
            ),
        ],
      ),
      body: u == null ? _login() : _estudiantes(u),
      floatingActionButton: u != null && u.esAdmin
          ? FloatingActionButton.extended(
              onPressed: _crearEstudiantePrueba,
              icon: const Icon(Icons.person_add),
              label: const Text('Estudiante de prueba'),
            )
          : null,
    );
  }

  Widget _login() => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Correo (admin o tutor)'),
                ),
                TextField(
                  controller: _pass,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  onSubmitted: (_) => _entrar(),
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: _entrar, child: const Text('Entrar')),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
        ),
      );

  Widget _estudiantes(Usuario u) => StreamBuilder<List<Estudiante>>(
        stream: u.esAdmin ? _bd.todosLosEstudiantes() : _bd.estudiantesDeTutor(u.id),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final lista = snap.data!;
          if (lista.isEmpty) {
            return const Center(
              child: Text('No hay estudiantes. Pulsa «Estudiante de prueba».'),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Conectado como ${u.nombre} (${u.rol.name})'),
              const SizedBox(height: 12),
              for (final e in lista)
                Card(
                  child: ListTile(
                    title: Text(e.nombre),
                    subtitle: Text(e.id),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PantallaTareasEstudiante(usuario: u, estudiante: e),
                            ),
                          ),
                          child: const Text('Tareas'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PantallaAgendaDia(estudiante: e),
                            ),
                          ),
                          child: const Text('Agenda de hoy'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      );
}
