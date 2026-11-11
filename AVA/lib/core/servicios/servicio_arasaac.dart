import 'dart:convert';

import 'package:http/http.dart' as http;

import '../modelos/recurso_visual.dart';

/// Acceso a la API pública de ARASAAC (HU-06).
///
/// Documentación: https://api.arasaac.org/developers
class ServicioArasaac {
  ServicioArasaac({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  static const _api = 'https://api.arasaac.org/api/pictograms/es';
  static const _imagenes = 'https://static.arasaac.org/pictograms';

  final http.Client _cliente;

  /// Dirección de la imagen PNG de un pictograma.
  static String urlImagen(int id, {int resolucion = 300}) =>
      '$_imagenes/$id/${id}_$resolucion.png';

  /// Busca pictogramas por palabra. Devuelve una lista vacía si no hay
  /// resultados y lanza [ErrorArasaac] si no hay conexión.
  Future<List<ResultadoArasaac>> buscar(String texto) async {
    final termino = texto.trim();
    if (termino.isEmpty) return const [];

    final http.Response respuesta;
    try {
      respuesta = await _cliente.get(
        Uri.parse('$_api/search/${Uri.encodeComponent(termino)}'),
      );
    } on Exception {
      throw const ErrorArasaac('No hay conexión con ARASAAC.');
    }

    // ARASAAC responde 404 cuando no encuentra nada.
    if (respuesta.statusCode == 404) return const [];
    if (respuesta.statusCode != 200) {
      throw const ErrorArasaac('ARASAAC no está disponible ahora.');
    }

    final datos = jsonDecode(respuesta.body) as List<Object?>;
    return [
      for (final elemento in datos.whereType<Map<String, Object?>>())
        ResultadoArasaac(
          pictograma: PictogramaArasaac(elemento['_id']! as int),
          palabra: _primeraPalabra(elemento) ?? termino,
        ),
    ];
  }

  static String? _primeraPalabra(Map<String, Object?> elemento) {
    final palabras = elemento['keywords'];
    if (palabras is! List || palabras.isEmpty) return null;
    final primera = palabras.first;
    return primera is Map ? primera['keyword'] as String? : null;
  }
}

/// Pictograma encontrado en una búsqueda, con su palabra principal.
class ResultadoArasaac {
  const ResultadoArasaac({required this.pictograma, required this.palabra});

  final PictogramaArasaac pictograma;
  final String palabra;
}

class ErrorArasaac implements Exception {
  const ErrorArasaac(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}
