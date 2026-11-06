import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/rutas.dart';
import '../../../perfil/logica/preferencias_controlador.dart';
import '../../logica/sesion_controlador.dart';

/// Cierra la sesión, devuelve el aspecto por defecto y vuelve al inicio.
void cerrarSesion(BuildContext context) {
  context.read<SesionControlador>().cerrarSesion();
  context.read<PreferenciasControlador>().restablecer();
  unawaited(
    Navigator.pushNamedAndRemoveUntil(context, Rutas.inicio, (_) => false),
  );
}

/// Botón para la barra superior de las pantallas de gestión.
class BotonCerrarSesion extends StatelessWidget {
  const BotonCerrarSesion({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: OutlinedButton.icon(
        onPressed: () => cerrarSesion(context),
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Salir'),
      ),
    );
  }
}
