import 'package:flutter/material.dart';

import '../constantes/dimensiones.dart';

/// Construye el tema de la aplicación a partir de las opciones de
/// accesibilidad.
///
/// Recibe valores simples (y no el modelo de preferencias) para que `core`
/// no dependa de ninguna feature.
abstract final class TemaApp {
  static ThemeData construir({
    required Color colorBase,
    bool modoOscuro = false,
    bool altoContraste = false,
  }) {
    final esquema = ColorScheme.fromSeed(
      seedColor: colorBase,
      brightness: modoOscuro ? Brightness.dark : Brightness.light,
      contrastLevel: altoContraste ? 1.0 : 0.0,
    );
    final bordeRedondeado = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Dimensiones.radioBorde),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: esquema.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: esquema.surface,
        foregroundColor: esquema.onSurface,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: esquema.onSurface,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            Dimensiones.objetivoTactilMinimo,
            Dimensiones.objetivoTactilMinimo,
          ),
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          shape: bordeRedondeado,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            Dimensiones.objetivoTactilMinimo,
            Dimensiones.objetivoTactilMinimo,
          ),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          shape: bordeRedondeado,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(
            Dimensiones.objetivoTactilMinimo,
            Dimensiones.objetivoTactilMinimo,
          ),
          iconSize: 32,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 22,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensiones.radioBorde),
        ),
      ),
      cardTheme: CardThemeData(shape: bordeRedondeado),
    );
  }
}
