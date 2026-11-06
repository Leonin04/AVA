import 'metodo_acceso.dart';
import 'pictograma_clave.dart';

/// Clave que introduce un usuario para iniciar sesión.
///
/// Solo la manejan el login y el repositorio de autenticación. Con Firebase
/// Authentication la clave no se guardará en claro.
sealed class ClaveAcceso {
  const ClaveAcceso();

  /// Método de acceso al que corresponde esta clave.
  MetodoAcceso get metodo;

  Map<String, Object?> toMap();

  static ClaveAcceso? fromMap(Object? datos) {
    if (datos is! Map) return null;
    return switch (datos['tipo']) {
      'contrasena' => ClaveContrasena(datos['valor']! as String),
      'pin' => ClavePin(datos['valor']! as String),
      'pictogramas' => ClavePictogramas([
        for (final nombre in datos['valor']! as List)
          PictogramaClave.porNombre(nombre as String),
      ]),
      _ => null,
    };
  }
}

final class ClaveContrasena extends ClaveAcceso {
  const ClaveContrasena(this.texto);

  final String texto;

  @override
  MetodoAcceso get metodo => const AccesoConContrasena();

  @override
  Map<String, Object?> toMap() => {'tipo': 'contrasena', 'valor': texto};

  @override
  bool operator ==(Object other) =>
      other is ClaveContrasena && other.texto == texto;

  @override
  int get hashCode => texto.hashCode;
}

final class ClavePin extends ClaveAcceso {
  const ClavePin(this.digitos);

  final String digitos;

  @override
  MetodoAcceso get metodo => const AccesoConPin();

  @override
  Map<String, Object?> toMap() => {'tipo': 'pin', 'valor': digitos};

  @override
  bool operator ==(Object other) =>
      other is ClavePin && other.digitos == digitos;

  @override
  int get hashCode => digitos.hashCode;
}

final class ClavePictogramas extends ClaveAcceso {
  const ClavePictogramas(this.secuencia);

  final List<PictogramaClave> secuencia;

  @override
  MetodoAcceso get metodo =>
      AccesoConPictogramas(longitudClave: secuencia.length);

  @override
  Map<String, Object?> toMap() => {
    'tipo': 'pictogramas',
    'valor': [for (final p in secuencia) p.name],
  };

  @override
  bool operator ==(Object other) =>
      other is ClavePictogramas &&
      other.secuencia.length == secuencia.length &&
      Iterable.generate(
        secuencia.length,
      ).every((i) => other.secuencia[i] == secuencia[i]);

  @override
  int get hashCode => Object.hashAll(secuencia);
}
