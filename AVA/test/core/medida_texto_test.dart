import 'package:ava/core/utilidades/medida_texto.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const estilo = TextStyle(fontSize: 22, height: 1.3);
  const escala = TextScaler.noScaling;

  test('una sola letra para todas: la de la tarjeta más exigente', () {
    final corta = MedidaTexto.tamanoComun(
      tarjetas: [(etiqueta: null, texto: 'Recreo', secundario: '11:00')],
      estilo: estilo,
      escala: escala,
      ancho: 140,
      alto: 60,
    );
    final conLarga = MedidaTexto.tamanoComun(
      tarjetas: [
        (etiqueta: null, texto: 'Recreo', secundario: '11:00'),
        (etiqueta: null, texto: 'Llevar fotocopias', secundario: '11:30'),
      ],
      estilo: estilo,
      escala: escala,
      ancho: 140,
      alto: 60,
    );

    expect(conLarga, lessThan(corta));
    expect(
      MedidaTexto.altoTarjeta(
        (etiqueta: null, texto: 'Llevar fotocopias', secundario: '11:30'),
        estilo,
        conLarga,
        escala,
        140,
      ),
      lessThanOrEqualTo(60),
    );
  });

  test('nunca baja del mínimo legible', () {
    final tamano = MedidaTexto.tamanoComun(
      tarjetas: [
        (etiqueta: 'AHORA', texto: 'Muchas palabras', secundario: '9'),
      ],
      estilo: estilo,
      escala: escala,
      ancho: 20,
      alto: 10,
    );
    expect(tamano, 12);
  });
}
