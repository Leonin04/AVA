/// Forma en la que un estudiante inicia sesión (HU-09).
///
/// La clave en sí no forma parte del modelo: solo la conoce el repositorio de
/// autenticación, que es quien la comprueba.
sealed class MetodoAcceso {
  const MetodoAcceso();

  String get nombre;

  Map<String, Object?> toMap();

  static MetodoAcceso fromMap(Object? datos) {
    if (datos is! Map) return const AccesoConContrasena();
    return switch (datos['tipo']) {
      'pin' => const AccesoConPin(),
      'pictogramas' => AccesoConPictogramas(
        longitudClave: datos['longitud'] as int?,
      ),
      _ => const AccesoConContrasena(),
    };
  }
}

/// El estudiante escribe una contraseña.
final class AccesoConContrasena extends MetodoAcceso {
  const AccesoConContrasena();

  @override
  String get nombre => 'Contraseña';

  @override
  Map<String, Object?> toMap() => {'tipo': 'contrasena'};
}

/// El estudiante pulsa un número de [longitud] cifras en un teclado grande.
final class AccesoConPin extends MetodoAcceso {
  const AccesoConPin();

  static const int longitud = 4;

  @override
  String get nombre => 'Número (PIN)';

  @override
  Map<String, Object?> toMap() => {'tipo': 'pin'};
}

/// El estudiante pulsa una secuencia de pictogramas.
final class AccesoConPictogramas extends MetodoAcceso {
  const AccesoConPictogramas({this.longitudClave})
    : assert(
        longitudClave == null ||
            (longitudClave >= longitudMinima &&
                longitudClave <= longitudMaxima),
      );

  static const int longitudMinima = 3;
  static const int longitudMaxima = 6;

  /// Número de pictogramas que forman la clave (entre 3 y 6), o `null` si
  /// no se conoce. Si se conoce, la clave se comprueba sola al rellenar el
  /// último hueco; si no, el estudiante pulsa «Entrar».
  final int? longitudClave;

  @override
  String get nombre => 'Pictogramas';

  @override
  Map<String, Object?> toMap() => {
    'tipo': 'pictogramas',
    'longitud': longitudClave,
  };
}
