import 'package:flutter/material.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/dimensiones.dart';
import '../../../core/widgets/boton_grande.dart';
import '../../autenticacion/presentacion/widgets/boton_cerrar_sesion.dart';
import '../dominio/estudiante.dart';

/// Pantalla principal del estudiante tras iniciar sesión: Perfil y Agenda.
class PantallaMenuEstudiante extends StatelessWidget {
  const PantallaMenuEstudiante({super.key, required this.estudiante});

  final Estudiante estudiante;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${estudiante.nombre}'),
        actions: const [BotonCerrarSesion()],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensiones.espaciado),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Dimensiones.anchoMaximoFormulario,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BotonGrande(
                    texto: 'Perfil',
                    icono: Icons.person,
                    alPulsar: () => Navigator.pushNamed(context, Rutas.perfil),
                  ),
                  const SizedBox(height: Dimensiones.espaciado * 2),
                  BotonGrande(
                    texto: 'Agenda',
                    icono: Icons.calendar_month,
                    alPulsar: () => Navigator.pushNamed(
                      context,
                      Rutas.seleccionVistaAgenda,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
