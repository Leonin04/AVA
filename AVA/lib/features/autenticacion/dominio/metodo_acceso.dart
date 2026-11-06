/// Forma en la que un estudiante inicia sesión (HU-08).
///
/// La clave en sí no forma parte del modelo: solo la conoce el repositorio de
/// autenticación, que es quien la comprueba.
sealed class MetodoAcceso {
  const MetodoAcceso();
}

/// El estudiante escribe una contraseña.
final class AccesoConContrasena extends MetodoAcceso {
  const AccesoConContrasena();
}

/// El estudiante pulsa una secuencia de pictogramas.
final class AccesoConPictogramas extends MetodoAcceso {
  const AccesoConPictogramas({required this.longitudClave})
      : assert(
          longitudClave >= longitudMinima && longitudClave <= longitudMaxima,
        );

  static const int longitudMinima = 3;
  static const int longitudMaxima = 6;

  /// Número de pictogramas que forman la clave (entre 3 y 6).
  final int longitudClave;
}
