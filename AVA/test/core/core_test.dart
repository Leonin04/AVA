import 'package:ava/core/constantes/paleta.dart';
import 'package:ava/core/tema/tema_app.dart';
import 'package:ava/core/utilidades/distribucion_cuadricula.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Relación de contraste según WCAG 2.x.
double contraste(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (claro, oscuro) = la > lb ? (la, lb) : (lb, la);
  return (claro + 0.05) / (oscuro + 0.05);
}

void main() {
  group('Paleta pastel (RNF-02, WCAG)', () {
    for (final color in ColorPastel.values) {
      test('${color.nombre}: el texto contrasta al menos 7:1 (AAA)', () {
        expect(contraste(Paleta.tinta, color.fondo), greaterThanOrEqualTo(7));
      });

      test('${color.nombre}: el borde contrasta al menos 3:1 (1.4.11)', () {
        expect(contraste(color.acento, color.fondo), greaterThanOrEqualTo(3));
      });
    }

    test('el texto sobre el fondo general contrasta al menos 7:1', () {
      expect(
        contraste(Paleta.tinta, Paleta.fondoClaro),
        greaterThanOrEqualTo(7),
      );
      expect(
        contraste(Paleta.tintaSuave, Paleta.fondoClaro),
        greaterThanOrEqualTo(7),
      );
    });

    test('los fondos pastel se distinguen entre sí por el tono', () {
      final tonos = [
        for (final c in ColorPastel.values) HSLColor.fromColor(c.fondo).hue,
      ]..sort();
      for (var i = 1; i < tonos.length; i++) {
        expect(tonos[i] - tonos[i - 1], greaterThan(15));
      }
    });
  });

  group('Color principal elegido', () {
    for (final color in ColorPastel.values) {
      test('${color.nombre}: tiñe el fondo y el texto sigue a 7:1', () {
        final tema = TemaApp.construir(color: color);
        final fondo = tema.scaffoldBackgroundColor;

        expect(fondo, isNot(Paleta.fondoClaro));
        expect(contraste(Paleta.tinta, fondo), greaterThanOrEqualTo(7));
      });
    }

    test('cada color da un fondo distinto', () {
      final fondos = {
        for (final c in ColorPastel.values)
          TemaApp.construir(color: c).scaffoldBackgroundColor,
      };
      expect(fondos, hasLength(ColorPastel.values.length));
    });
  });

  group('Cuadrícula en la que cabe todo', () {
    test('cuatro elementos anchos se reparten en 2 × 2', () {
      final reparto = DistribucionCuadricula.calcular(
        total: 4,
        ancho: 1000,
        alto: 600,
        espaciado: 20,
        maxColumnas: 2,
        proporcion: 2,
      );
      expect([reparto.columnas, reparto.filas], [2, 2]);
    });

    test('caben todos los elementos aunque sean muchos', () {
      for (final total in [1, 6, 15, 20, 40]) {
        final reparto = DistribucionCuadricula.calcular(
          total: total,
          ancho: 1000,
          alto: 600,
          espaciado: 12,
          maxColumnas: 5,
        );
        expect(reparto.columnas * reparto.filas, greaterThanOrEqualTo(total));
        final altoTotal =
            reparto.altoCelda * reparto.filas + 12 * (reparto.filas - 1);
        expect(altoTotal, lessThanOrEqualTo(600.001));
      }
    });

    test('no pasa del alto máximo con pocos elementos', () {
      final reparto = DistribucionCuadricula.calcular(
        total: 2,
        ancho: 1000,
        alto: 800,
        espaciado: 20,
        altoMaximo: 300,
      );
      expect(reparto.altoCelda, lessThanOrEqualTo(300));
    });
  });
}
