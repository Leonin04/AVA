import 'package:flutter_tts/flutter_tts.dart';

/// Lectura en voz alta de textos (RF-08, persona Álex).
abstract interface class ServicioVoz {
  Future<void> decir(String texto);

  Future<void> parar();
}

/// Implementación con la síntesis de voz del dispositivo.
class ServicioVozDispositivo implements ServicioVoz {
  final FlutterTts _tts = FlutterTts();
  bool _configurado = false;

  @override
  Future<void> decir(String texto) async {
    if (texto.trim().isEmpty) return;
    try {
      if (!_configurado) {
        await _tts.setLanguage('es-ES');
        // Ritmo pausado para facilitar la comprensión (persona Samuel).
        await _tts.setSpeechRate(0.45);
        _configurado = true;
      }
      await _tts.stop();
      await _tts.speak(texto);
    } on Exception {
      // Si el dispositivo no tiene voz, la app sigue funcionando sin ella.
    }
  }

  @override
  Future<void> parar() async {
    try {
      await _tts.stop();
    } on Exception {
      // Sin voz disponible no hay nada que parar.
    }
  }
}

/// Implementación muda, para pruebas.
class ServicioVozSilencioso implements ServicioVoz {
  final List<String> dichos = [];

  @override
  Future<void> decir(String texto) async => dichos.add(texto);

  @override
  Future<void> parar() async {}
}
