import 'package:ava/core/constantes/paleta.dart';
import 'package:ava/core/utilidades/paginacion.dart';
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

  group('Paginación sin desplazamiento', () {
    test('reparte los elementos en páginas', () {
      const p = Paginacion(total: 10, porPagina: 4);
      expect(p.numeroPaginas, 3);
      expect([p.inicio(2), p.fin(2)], [8, 10]);
    });

    test('calcula cuántos elementos caben', () {
      expect(
        Paginacion.cuantosCaben(
          disponible: 500,
          tamanoMinimo: 100,
          espaciado: 20,
        ),
        4,
      );
      expect(
        Paginacion.cuantosCaben(
          disponible: 50,
          tamanoMinimo: 100,
          espaciado: 0,
        ),
        1,
      );
    });
  });
}
