import 'package:flutter_tts/flutter_tts.dart';

/// Voz en Android e iOS con el motor de síntesis del sistema.
final FlutterTts _tts = FlutterTts();
bool _configurado = false;

Future<bool> hablar(String texto) async {
  if (!_configurado) {
    await _tts.setLanguage('es-ES');
    // Ritmo pausado para facilitar la comprensión (persona Samuel).
    await _tts.setSpeechRate(0.45);
    _configurado = true;
  }
  await _tts.stop();
  final resultado = await _tts.speak(texto);
  return resultado == 1;
}

Future<void> callar() => _tts.stop();
