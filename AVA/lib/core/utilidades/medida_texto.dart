import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Textos de una tarjeta: etiqueta opcional (`AHORA`), texto principal y
/// línea secundaria opcional (la hora).
typedef TextosTarjeta = ({String? etiqueta, String texto, String? secundario});

/// Medidas de texto para decidir un tamaño de letra antes de pintar.
abstract final class MedidaTexto {
  /// Proporción de la etiqueta y de la línea secundaria respecto al texto
  /// principal.
  static const proporcionEtiqueta = 0.7;
  static const proporcionSecundario = 0.85;

  /// Alto que ocupa la etiqueta además de su texto (relleno y margen).
  static const extraEtiqueta = 14.0;

  /// Tamaño de [texto] con [estilo], partiendo líneas en [anchoMaximo].
  static Size medir(
    String texto,
    TextStyle estilo,
    TextScaler escala, {
    double anchoMaximo = double.infinity,
  }) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: estilo),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      textScaler: escala,
    )..layout(maxWidth: anchoMaximo);
    final tamano = pintor.size;
    pintor.dispose();
    return tamano;
  }

  /// Alto que ocupan los [textos] de una tarjeta con letra de [tamano] en
  /// un ancho de [ancho].
  static double altoTarjeta(
    TextosTarjeta textos,
    TextStyle estilo,
    double tamano,
    TextScaler escala,
    double ancho,
  ) {
    double alto(String? texto, double proporcion) => texto == null
        ? 0
        : medir(
            texto,
            estilo.copyWith(fontSize: tamano * proporcion),
            escala,
            anchoMaximo: ancho,
          ).height;

    final etiqueta = textos.etiqueta == null
        ? 0
        : alto(textos.etiqueta, proporcionEtiqueta) + extraEtiqueta;
    return etiqueta +
        alto(textos.texto, 1) +
        alto(textos.secundario, proporcionSecundario);
  }

  /// Mayor tamaño de letra, entre [minimo] y [maximo], con el que los
  /// textos de todas las [tarjetas] caben en [ancho] × [alto] sin partir
  /// ninguna palabra. Así todas las tarjetas usan la misma letra.
  static double tamanoComun({
    required Iterable<TextosTarjeta> tarjetas,
    required TextStyle estilo,
    required TextScaler escala,
    required double ancho,
    required double alto,
    double minimo = 12,
    double maximo = 22,
  }) {
    bool caben(double tamano) => tarjetas.every((textos) {
      final palabraMasLarga = textos.texto
          .split(RegExp(r'\s+'))
          .map((p) => medir(p, estilo.copyWith(fontSize: tamano), escala).width)
          .fold(0.0, math.max);
      return palabraMasLarga <= ancho &&
          altoTarjeta(textos, estilo, tamano, escala, ancho) <= alto;
    });

    var tamano = maximo;
    while (tamano > minimo && !caben(tamano)) {
      tamano -= 0.5;
    }
    return math.max(tamano, minimo);
  }
}
