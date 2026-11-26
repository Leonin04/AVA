import 'dart:convert';

import 'package:ava/core/servicios/servicio_arasaac.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, Object?> _pictograma(
  int id,
  String palabra, {
  bool sexo = false,
  bool violencia = false,
}) => {
  '_id': id,
  'sex': sexo,
  'violence': violencia,
  'keywords': [
    {'keyword': palabra},
  ],
};

void main() {
  test('la búsqueda no devuelve pictogramas explícitos', () async {
    // Casos reales de buscar «persona» en ARASAAC.
    final respuesta = [
      _pictograma(34560, 'persona'),
      _pictograma(31250, 'desnudo', sexo: true),
      _pictograma(11234, 'desnudo'),
      _pictograma(28873, 'desnuda'),
      _pictograma(1, 'pelea', violencia: true),
      _pictograma(30154, 'hombre en ropa interior'),
    ];
    final arasaac = ServicioArasaac(
      cliente: MockClient(
        (_) async =>
            http.Response.bytes(utf8.encode(jsonEncode(respuesta)), 200),
      ),
    );

    final resultados = await arasaac.buscar('persona');

    expect([for (final r in resultados) r.pictograma.id], [34560, 30154]);
  });
}
