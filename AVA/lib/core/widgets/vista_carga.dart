import 'package:flutter/material.dart';

import '../utilidades/controlador_carga.dart';
import 'mensaje_informativo.dart';

/// Muestra el estado de un [ControladorCarga]: indicador de progreso,
/// mensaje de error con opción de reintentar o el contenido ya cargado.
class VistaCarga<T> extends StatelessWidget {
  const VistaCarga({
    super.key,
    required this.controlador,
    required this.constructor,
  });

  final ControladorCarga<T> controlador;
  final Widget Function(BuildContext context, T datos) constructor;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controlador,
      builder: (context, _) {
        final error = controlador.mensajeError;
        if (error != null) {
          return MensajeInformativo(
            icono: Icons.error_outline,
            texto: error,
            textoAccion: 'Reintentar',
            alPulsarAccion: controlador.cargar,
          );
        }

        final datos = controlador.datos;
        if (datos == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return constructor(context, datos);
      },
    );
  }
}
