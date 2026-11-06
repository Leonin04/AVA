import 'dart:convert';

import 'package:http/http.dart' as http;

/// Búsqueda de pictogramas en la API pública de ARASAAC (T-70).
/// Licencia CC BY-NC-SA (ARASAAC, Gobierno de Aragón).
class Arasaac {
  Arasaac({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  final http.Client _cliente;

  /// URL de la imagen PNG de un pictograma.
  static String urlPictograma(int id, {int resolucion = 300}) =>
      'https://static.arasaac.org/pictograms/$id/${id}_$resolucion.png';

  /// Devuelve las URL de los pictogramas que coinciden con [texto]
  /// (como mucho [maximo]). Lista vacía si no hay resultados.
  Future<List<String>> buscar(String texto, {int maximo = 30}) async {
    final consulta = texto.trim();
    if (consulta.isEmpty) return [];
    final uri = Uri.parse(
      'https://api.arasaac.org/v1/pictograms/es/search/'
      '${Uri.encodeComponent(consulta)}',
    );
    final resp = await _cliente.get(uri);
    if (resp.statusCode == 404) return []; // ARASAAC responde 404 si no hay nada
    if (resp.statusCode != 200) {
      throw Exception('ARASAAC respondió ${resp.statusCode}');
    }
    final lista = jsonDecode(resp.body) as List<dynamic>;
    return lista
        .take(maximo)
        .map((e) => urlPictograma((e as Map<String, dynamic>)['_id'] as int))
        .toList();
  }
}
