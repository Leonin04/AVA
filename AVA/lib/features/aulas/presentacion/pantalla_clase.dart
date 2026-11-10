import 'package:flutter/material.dart';

import '../../../core/servicios/base_datos.dart';
import '../../../core/widgets/avatar_alumno.dart';
import '../../autenticacion/dominio/acceso.dart';
import '../../autenticacion/presentacion/pantalla_login_alumno.dart';
import '../dominio/aula.dart';

/// Pantalla de una clase (wireframe 2): avatares con el nombre de cada alumno.
/// Al tocar uno se abre su pantalla de acceso.
class PantallaClase extends StatefulWidget {
  const PantallaClase({super.key, required this.aula, this.baseDatos});

  final Aula aula;

  /// Solo para pruebas; por defecto usa `BaseDatos()`.
  final BaseDatos? baseDatos;

  @override
  State<PantallaClase> createState() => _PantallaClaseState();
}

class _PantallaClaseState extends State<PantallaClase> {
  late final Stream<List<Acceso>> _alumnos =
      (widget.baseDatos ?? BaseDatos()).alumnosParaAcceso(widget.aula.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Etiqueta del aula arriba a la izquierda; también vuelve atrás.
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: Text(widget.aula.nombre),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(56, 56),
                  textStyle: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: StreamBuilder<List<Acceso>>(
                  stream: _alumnos,
                  builder: _construirAlumnos,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirAlumnos(
      BuildContext context, AsyncSnapshot<List<Acceso>> snapshot) {
    if (snapshot.hasError) {
      return const _Mensaje(
        icono: Icons.error_outline,
        texto: 'No se pudieron cargar los alumnos.\n'
            'Comprueba la conexión e inténtalo de nuevo.',
      );
    }
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    final alumnos = snapshot.data!;
    if (alumnos.isEmpty) {
      return const _Mensaje(
        icono: Icons.group_outlined,
        texto: 'Esta clase todavía no tiene alumnos.',
      );
    }
    return GridView.builder(
      itemCount: alumnos.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, i) => _TarjetaAlumno(
        alumno: alumnos[i],
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PantallaLoginAlumno(alumno: alumnos[i]),
          ),
        ),
      ),
    );
  }
}

class _TarjetaAlumno extends StatelessWidget {
  const _TarjetaAlumno({required this.alumno, required this.onTap});

  final Acceso alumno;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AvatarAlumno(fotoUrl: alumno.fotoUrl, radio: 64),
            const SizedBox(height: 12),
            Text(
              alumno.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ],
        ),
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