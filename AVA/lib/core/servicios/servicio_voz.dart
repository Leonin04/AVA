import 'voz_plataforma_nativa.dart'
    if (dart.library.js_interop) 'voz_plataforma_web.dart'
    as plataforma;

/// Lectura en voz alta de textos (RF-08, personas Álex y Samuel).
abstract interface class ServicioVoz {
  /// Lee [texto] en voz alta. Devuelve `false` si el dispositivo no tiene
  /// ninguna voz disponible, para poder avisar en pantalla.
  Future<bool> decir(String texto);

  Future<void> parar();
}

/// Implementación con la síntesis de voz del dispositivo: la del navegador
/// en la web y la del sistema en Android e iOS.
class ServicioVozDispositivo implements ServicioVoz {
  @override
  Future<bool> decir(String texto) async {
    if (texto.trim().isEmpty) return true;
    try {
      return await plataforma.hablar(texto);
    } on Object {
      // Si el dispositivo falla al hablar, la app sigue funcionando.
      return false;
    }
  }

  @override
  Future<void> parar() async {
    try {
      await plataforma.callar();
    } on Object {
      // Sin voz disponible no hay nada que parar.
    }
  }
}

/// Implementación muda, para pruebas.
class ServicioVozSilencioso implements ServicioVoz {
  final List<String> dichos = [];

  @override
  Future<bool> decir(String texto) async {
    dichos.add(texto);
    return true;
  }

  @override
  Future<void> parar() async {}
}
