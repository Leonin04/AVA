/// Colores principales que puede elegir el estudiante.
///
/// Se guarda el valor ARGB para que el dominio no dependa de Flutter.
enum ColorTema {
  azul('Azul', 0xFF0D47A1),
  verde('Verde', 0xFF1B5E20),
  naranja('Naranja', 0xFFE65100);

  const ColorTema(this.nombre, this.valorArgb);

  final String nombre;
  final int valorArgb;
}

/// Ajustes visuales del estudiante que cambian el aspecto de toda la app
/// (HU-14).
class PreferenciasAccesibilidad {
  const PreferenciasAccesibilidad({
    this.textoGrande = false,
    this.altoContraste = false,
    this.modoOscuro = false,
    this.color = ColorTema.azul,
  });

  static const double escalaTextoGrande = 1.3;

  final bool textoGrande;
  final bool altoContraste;
  final bool modoOscuro;
  final ColorTema color;

  double get escalaTexto => textoGrande ? escalaTextoGrande : 1.0;

  PreferenciasAccesibilidad copyWith({
    bool? textoGrande,
    bool? altoContraste,
    bool? modoOscuro,
    ColorTema? color,
  }) {
    return PreferenciasAccesibilidad(
      textoGrande: textoGrande ?? this.textoGrande,
      altoContraste: altoContraste ?? this.altoContraste,
      modoOscuro: modoOscuro ?? this.modoOscuro,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PreferenciasAccesibilidad &&
      other.textoGrande == textoGrande &&
      other.altoContraste == altoContraste &&
      other.modoOscuro == modoOscuro &&
      other.color == color;

  @override
  int get hashCode => Object.hash(textoGrande, altoContraste, modoOscuro, color);
}
