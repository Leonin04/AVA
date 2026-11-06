import 'package:flutter/material.dart';

import '../../../core/widgets/mensaje_informativo.dart';
import 'widgets/boton_cerrar_sesion.dart';

/// Pantalla provisional tras el login del profesorado. La gestión de cuentas,
/// aulas y tareas se construirá sobre ella.
class PantallaPanelAdministrador extends StatelessWidget {
  const PantallaPanelAdministrador({super.key, required this.usuario});

  final String usuario;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración'),
        actions: const [BotonCerrarSesion()],
      ),
      body: MensajeInformativo(
        icono: Icons.construction_outlined,
        texto: 'Hola, $usuario.\n'
            'El panel de administración estará disponible próximamente.',
      ),
    );
  }
}
