import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Voz en el navegador con la Web Speech API.
Future<bool> hablar(String texto) async {
  final sintesis = web.window.speechSynthesis;

  // Algunos navegadores cargan las voces poco después de abrir la página.
  var voces = sintesis.getVoices().toDart;
  if (voces.isEmpty) {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    voces = sintesis.getVoices().toDart;
  }
  if (voces.isEmpty) return false;

  final enEspanol = voces.where((v) => v.lang.toLowerCase().startsWith('es'));
  final mensaje = web.SpeechSynthesisUtterance(texto)
    ..lang = 'es-ES'
    // Ritmo pausado para facilitar la comprensión (persona Samuel).
    ..rate = 0.85;
  if (enEspanol.isNotEmpty) mensaje.voice = enEspanol.first;

  sintesis.cancel();
  sintesis.speak(mensaje);
  return true;
}

Future<void> callar() async => web.window.speechSynthesis.cancel();
