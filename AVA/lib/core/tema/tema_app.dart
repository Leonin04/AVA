import 'package:flutter/material.dart';

import '../constantes/dimensiones.dart';
import '../constantes/paleta.dart';

/// Construye el tema de la aplicación a partir de las opciones de
/// accesibilidad.
///
/// Recibe valores simples (y no el modelo de preferencias) para que `core`
/// no dependa de ninguna feature.
abstract final class TemaApp {
  static const fuenteLecturaClara = 'AtkinsonHyperlegible';

  static ThemeData construir({
    required ColorPastel color,
    bool modoOscuro = false,
    bool altoContraste = false,
    bool letraClara = true,
  }) {
    final esquema = _esquema(color, modoOscuro, altoContraste);
    final bordeRedondeado = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Dimensiones.radioBordePequeno),
    );
    const tamanoMinimo = Size(
      Dimensiones.objetivoTactilMinimo,
      Dimensiones.objetivoTactilMinimo,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      fontFamily: letraClara ? fuenteLecturaClara : null,
      textTheme: _textos(esquema),
      scaffoldBackgroundColor: esquema.surface,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      // Sin animaciones de transición entre pantallas (RNF-11).
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final plataforma in TargetPlatform.values)
            plataforma: const _SinTransicion(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: esquema.surface,
        foregroundColor: esquema.onSurface,
        centerTitle: false,
        toolbarHeight: 80,
        titleTextStyle: TextStyle(
          fontFamily: letraClara ? fuenteLecturaClara : null,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: esquema.onSurface,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: tamanoMinimo,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          shape: bordeRedondeado,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: tamanoMinimo,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          side: BorderSide(color: esquema.outline, width: 2),
          shape: bordeRedondeado,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: tamanoMinimo,
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: tamanoMinimo, iconSize: 32),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: esquema.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        labelStyle: const TextStyle(fontSize: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensiones.radioBordePequeno),
          borderSide: BorderSide(color: esquema.outline, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensiones.radioBordePequeno),
          borderSide: BorderSide(color: esquema.outline, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensiones.radioBordePequeno),
          borderSide: BorderSide(color: esquema.primary, width: 4),
        ),
      ),
      chipTheme: ChipThemeData(
        labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        side: BorderSide(color: esquema.outline, width: 2),
      ),
      cardTheme: CardThemeData(
        shape: bordeRedondeado,
        color: esquema.surfaceContainerLow,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: esquema.outlineVariant,
        thickness: 2,
      ),
    );
  }

  static ColorScheme _esquema(
    ColorPastel color,
    bool modoOscuro,
    bool altoContraste,
  ) {
    final base = ColorScheme.fromSeed(
      seedColor: color.acento,
      brightness: modoOscuro ? Brightness.dark : Brightness.light,
      contrastLevel: altoContraste ? 1.0 : 0.0,
    );

    if (altoContraste) {
      return modoOscuro
          ? base.copyWith(
              primary: Paleta.amarilloContraste,
              onPrimary: Colors.black,
              primaryContainer: Colors.black,
              onPrimaryContainer: Colors.white,
              surface: Colors.black,
              onSurface: Colors.white,
              outline: Paleta.amarilloContraste,
              surfaceContainerLowest: Colors.black,
              surfaceContainerLow: Colors.black,
            )
          : base.copyWith(
              primary: Colors.black,
              onPrimary: Colors.white,
              primaryContainer: Colors.white,
              onPrimaryContainer: Colors.black,
              surface: Colors.white,
              onSurface: Colors.black,
              outline: Colors.black,
              surfaceContainerLowest: Colors.white,
              surfaceContainerLow: Colors.white,
            );
    }

    return modoOscuro
        ? base.copyWith(
            primary: color.fondo,
            onPrimary: Paleta.tinta,
            primaryContainer: color.fondo,
            onPrimaryContainer: Paleta.tinta,
            // El color elegido tiñe el fondo para que el cambio se note.
            surface: Color.lerp(Paleta.fondoOscuro, color.acento, 0.22),
            onSurface: const Color(0xFFF4F4F8),
            surfaceContainerLowest: Paleta.superficieOscura,
            surfaceContainerLow: Paleta.superficieOscura,
          )
        : base.copyWith(
            primary: color.acento,
            onPrimary: Colors.white,
            primaryContainer: color.fondo,
            onPrimaryContainer: Paleta.tinta,
            // El color elegido tiñe el fondo para que el cambio se note en
            // toda la app; el texto sigue contrastando más de 7:1.
            surface: Color.lerp(Paleta.fondoClaro, color.fondo, 0.8),
            onSurface: Paleta.tinta,
            onSurfaceVariant: Paleta.tintaSuave,
            surfaceContainerLowest: Colors.white,
            surfaceContainerLow: Colors.white,
          );
  }

  /// Tamaños generosos e interlineado amplio, siguiendo las pautas de
  /// lectura fácil (UNE 153101 EX): letra grande e interlineado de 1,5.
  static TextTheme _textos(ColorScheme esquema) {
    const interlineado = 1.4;
    return const TextTheme(
      displaySmall: TextStyle(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      headlineSmall: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: interlineado,
      ),
      titleMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: interlineado,
      ),
      titleSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: interlineado,
      ),
      bodyLarge: TextStyle(fontSize: 22, height: 1.5),
      bodyMedium: TextStyle(fontSize: 20, height: 1.5),
      bodySmall: TextStyle(fontSize: 17, height: 1.5),
      labelLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      labelMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    ).apply(bodyColor: esquema.onSurface, displayColor: esquema.onSurface);
  }
}

/// Cambia de pantalla sin animación.
class _SinTransicion extends PageTransitionsBuilder {
  const _SinTransicion();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}
