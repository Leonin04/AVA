import 'package:flutter/material.dart';

import '../../../core/servicios/base_datos.dart';
import '../dominio/aula.dart';

/// Pantalla de inicio de la tableta (wireframe 1).
///
/// Muestra el botón AVA, un botón por cada aula (leídas de Firestore con
/// `BaseDatos.aulas()`) y el acceso de administración arriba a la derecha.
///
/// No navega por sí sola: recibe callbacks, así el que la use decide
/// a qué pantalla va cada botón.
class PantallaSeleccionAula extends StatefulWidget {
  const PantallaSeleccionAula({
    super.key,
    required this.alAbrirAva,
    required this.alElegirAula,
    required this.alAbrirAdmin,
    this.baseDatos,
  });

  final VoidCallback alAbrirAva;
  final ValueChanged<Aula> alElegirAula;
  final VoidCallback alAbrirAdmin;

  /// Solo para pruebas; por defecto usa `BaseDatos()`.
  final BaseDatos? baseDatos;

  @override
  State<PantallaSeleccionAula> createState() => _PantallaSeleccionAulaState();
}

class _PantallaSeleccionAulaState extends State<PantallaSeleccionAula> {
  // Se crea una sola vez para no abrir un stream nuevo en cada rebuild.
  late final Stream<List<Aula>> _aulas =
      (widget.baseDatos ?? BaseDatos()).aulas();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _BotonAva(onPressed: widget.alAbrirAva),
                      const SizedBox(height: 32),
                      Expanded(
                        child: StreamBuilder<List<Aula>>(
                          stream: _aulas,
                          builder: _construirAulas,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: _BotonAdmin(onPressed: widget.alAbrirAdmin),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirAulas(
      BuildContext context, AsyncSnapshot<List<Aula>> snapshot) {
    if (snapshot.hasError) {
      return const _Mensaje(
        icono: Icons.error_outline,
        texto: 'No se pudieron cargar las aulas.\n'
            'Comprueba la conexión e inténtalo de nuevo.',
      );
    }
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    final aulas = snapshot.data!;
    if (aulas.isEmpty) {
      return const _Mensaje(
        icono: Icons.meeting_room_outlined,
        texto: 'Todavía no hay aulas.\nUn administrador puede crearlas.',
      );
    }
    return GridView.builder(
      itemCount: aulas.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 48,
        childAspectRatio: 1.8,
      ),
      itemBuilder: (context, i) => _BotonAula(
        aula: aulas[i],
        onPressed: () => widget.alElegirAula(aulas[i]),
      ),
    );
  }
}

class _BotonAva extends StatelessWidget {
  const _BotonAva({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      height: 110,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
        ),
        child: const Text('AVA'),
      ),
    );
  }
}

class _BotonAula extends StatelessWidget {
  const _BotonAula({required this.aula, required this.onPressed});

  final Aula aula;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: const TextStyle(fontSize: 40, fontWeight: FontWeight.w600),
      ),
      child: Text(aula.nombre),
    );
  }
}

class _BotonAdmin extends StatelessWidget {
  const _BotonAdmin({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.admin_panel_settings_outlined),
      label: const Text('Admin'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(56, 56),
        textStyle: const TextStyle(fontSize: 18),
      ),
    );
  }
}

class _Mensaje extends StatelessWidget {
  const _Mensaje({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 64),
          const SizedBox(height: 16),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22),
          ),
        ],
      ),
    );
  }
}