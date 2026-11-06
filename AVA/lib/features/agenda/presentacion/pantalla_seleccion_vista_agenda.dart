import 'package:flutter/material.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/dimensiones.dart';
import '../../../core/widgets/boton_grande.dart';
import '../../perfil/dominio/estudiante.dart';
import '../dominio/vista_agenda.dart';

/// Elección de cómo ver la agenda: semana, día o siguiente tarea.
class PantallaSeleccionVistaAgenda extends StatelessWidget {
  const PantallaSeleccionVistaAgenda({super.key, required this.estudiante});

  final Estudiante estudiante;

  static IconData _icono(VistaAgenda vista) => switch (vista) {
        VistaAgenda.semanal => Icons.view_week,
        VistaAgenda.diaria => Icons.today,
        VistaAgenda.siguienteTarea => Icons.skip_next,
      };

  static String _ruta(VistaAgenda vista) => switch (vista) {
        VistaAgenda.semanal => Rutas.agendaSemanal,
        VistaAgenda.diaria => Rutas.agendaDiaria,
        VistaAgenda.siguienteTarea => Rutas.siguienteTarea,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi agenda')),
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
                  for (final vista in VistaAgenda.values) ...[
                    BotonGrande(
                      texto: vista.nombre,
                      icono: _icono(vista),
                      alPulsar: () =>
                          Navigator.pushNamed(context, _ruta(vista)),
                    ),
                    const SizedBox(height: Dimensiones.espaciado * 1.5),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
