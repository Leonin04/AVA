import 'package:flutter/material.dart';

import '../constantes/paleta.dart';
import '../servicios/servicio_voz.dart';

/// Ajustes de accesibilidad que necesitan los widgets comunes de `core`.
///
/// La app los rellena a partir de las preferencias del estudiante; así los
/// widgets de `core` no dependen de ninguna feature.
class AjustesInterfaz extends InheritedWidget {
  const AjustesInterfaz({
    super.key,
    required this.voz,
    required super.child,
    this.leerEnVoz = false,
    this.filtroAntitemblor = false,
    this.mostrarPictogramas = true,
    this.mostrarTexto = true,
    this.altoContraste = false,
    this.modoOscuro = false,
    this.menuArriba = false,
  });

  final ServicioVoz voz;

  /// Leer en voz alta el texto de cada botón al pulsarlo.
  final bool leerEnVoz;

  /// Ignorar pulsaciones repetidas durante un tiempo (temblores, espasmos).
  final bool filtroAntitemblor;

  final bool mostrarPictogramas;
  final bool mostrarTexto;
  final bool altoContraste;
  final bool modoOscuro;

  /// Barra de navegación arriba en lugar de abajo (RNF-05: posición).
  final bool menuArriba;

  static final _porDefecto = AjustesInterfaz(
    voz: ServicioVozSilencioso(),
    child: const SizedBox.shrink(),
  );

  static AjustesInterfaz of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AjustesInterfaz>() ??
      _porDefecto;

  /// Colores con los que pintar una tarjeta de la familia [color], teniendo
  /// en cuenta el alto contraste.
  EstiloTarjeta estiloDe(ColorPastel color) {
    if (altoContraste) {
      return modoOscuro
          ? const EstiloTarjeta(
              fondo: Colors.black,
              borde: Paleta.amarilloContraste,
              texto: Colors.white,
              acento: Paleta.amarilloContraste,
            )
          : const EstiloTarjeta(
              fondo: Colors.white,
              borde: Colors.black,
              texto: Colors.black,
              acento: Colors.black,
            );
    }
    return EstiloTarjeta(
      fondo: color.fondo,
      borde: color.acento,
      texto: Paleta.tinta,
      acento: color.acento,
    );
  }

  @override
  bool updateShouldNotify(AjustesInterfaz oldWidget) =>
      voz != oldWidget.voz ||
      leerEnVoz != oldWidget.leerEnVoz ||
      filtroAntitemblor != oldWidget.filtroAntitemblor ||
      mostrarPictogramas != oldWidget.mostrarPictogramas ||
      mostrarTexto != oldWidget.mostrarTexto ||
      altoContraste != oldWidget.altoContraste ||
      modoOscuro != oldWidget.modoOscuro ||
      menuArriba != oldWidget.menuArriba;
}

/// Colores resueltos de una tarjeta.
class EstiloTarjeta {
  const EstiloTarjeta({
    required this.fondo,
    required this.borde,
    required this.texto,
    required this.acento,
  });

  final Color fondo;
  final Color borde;
  final Color texto;
  final Color acento;
}
