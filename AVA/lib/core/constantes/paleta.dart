import 'package:flutter/material.dart';

/// Familias de color pastel de la aplicación.
///
/// Cada familia tiene un fondo pastel (para tarjetas) y un acento más
/// intenso (para bordes e iconos). El texto siempre va en [Paleta.tinta],
/// que contrasta más de 10:1 con cualquier fondo pastel (WCAG 1.4.6, AAA).
/// Los acentos contrastan al menos 3:1 con su fondo (WCAG 1.4.11).
///
/// Los tonos están repartidos por el círculo cromático para que se
/// distingan entre sí, pero el color nunca es la única pista: siempre va
/// acompañado de pictograma y texto (WCAG 1.4.1).
enum ColorPastel {
  rosa('Rosa', Color(0xFFFFD6E5), Color(0xFFB0305F)),
  melocoton('Melocotón', Color(0xFFFFDCC2), Color(0xFFA84B12)),
  amarillo('Amarillo', Color(0xFFFFF0A8), Color(0xFF7D6200)),
  lima('Lima', Color(0xFFE4F5B5), Color(0xFF557311)),
  menta('Menta', Color(0xFFC8F0D8), Color(0xFF1D7348)),
  turquesa('Turquesa', Color(0xFFC5EEF0), Color(0xFF0D6B76)),
  cielo('Cielo', Color(0xFFCCE6FF), Color(0xFF1E5EA8)),
  lavanda('Lavanda', Color(0xFFE0D6FF), Color(0xFF5A3EB0));

  const ColorPastel(this.nombre, this.fondo, this.acento);

  final String nombre;
  final Color fondo;
  final Color acento;

  /// Color para un índice cualquiera, recorriendo la paleta en orden.
  static ColorPastel paraIndice(int indice) => values[indice % values.length];

  static ColorPastel porNombre(String? nombre) => values.firstWhere(
    (color) => color.name == nombre,
    orElse: () => ColorPastel.cielo,
  );
}

/// Colores neutros de la aplicación.
abstract final class Paleta {
  /// Texto principal sobre fondos claros.
  static const tinta = Color(0xFF1B1E2B);

  /// Texto secundario: contrasta más de 7:1 con [fondoClaro].
  static const tintaSuave = Color(0xFF3E4357);

  /// Fondo general en modo claro: crema cálido, menos deslumbrante que el
  /// blanco puro.
  static const fondoClaro = Color(0xFFFFFBF4);

  /// Fondo general en modo oscuro.
  static const fondoOscuro = Color(0xFF1B1E2B);

  /// Superficie de tarjetas en modo oscuro.
  static const superficieOscura = Color(0xFF2A2E3F);

  /// Amarillo del modo de alto contraste (sobre negro, más de 15:1).
  static const amarilloContraste = Color(0xFFFFE600);
}
