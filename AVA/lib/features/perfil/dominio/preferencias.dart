/// Preferencias de comunicación del estudiante (HU-15).
class PreferenciasComunicacion {
  final bool pictogramas;
  final bool imagenes;
  final bool texto;
  final bool sonido;
  final bool voz;
  final bool botonesGrandes;

  const PreferenciasComunicacion({
    this.pictogramas = true,
    this.imagenes = true,
    this.texto = true,
    this.sonido = false,
    this.voz = true,
    this.botonesGrandes = true,
  });

  factory PreferenciasComunicacion.fromMap(Map<String, dynamic>? m) {
    m ??= {};
    const def = PreferenciasComunicacion();
    return PreferenciasComunicacion(
      pictogramas: m['pictogramas'] as bool? ?? def.pictogramas,
      imagenes: m['imagenes'] as bool? ?? def.imagenes,
      texto: m['texto'] as bool? ?? def.texto,
      sonido: m['sonido'] as bool? ?? def.sonido,
      voz: m['voz'] as bool? ?? def.voz,
      botonesGrandes: m['botonesGrandes'] as bool? ?? def.botonesGrandes,
    );
  }

  Map<String, dynamic> toMap() => {
        'pictogramas': pictogramas,
        'imagenes': imagenes,
        'texto': texto,
        'sonido': sonido,
        'voz': voz,
        'botonesGrandes': botonesGrandes,
      };

  PreferenciasComunicacion copyWith({
    bool? pictogramas,
    bool? imagenes,
    bool? texto,
    bool? sonido,
    bool? voz,
    bool? botonesGrandes,
  }) =>
      PreferenciasComunicacion(
        pictogramas: pictogramas ?? this.pictogramas,
        imagenes: imagenes ?? this.imagenes,
        texto: texto ?? this.texto,
        sonido: sonido ?? this.sonido,
        voz: voz ?? this.voz,
        botonesGrandes: botonesGrandes ?? this.botonesGrandes,
      );
}

// Los nombres coinciden con los valores guardados en Firestore.
// ignore: constant_identifier_names
enum EsquemaColores { alto_contraste, claro, oscuro }

enum Posicion { arriba, abajo, izquierda, derecha }

/// Preferencias visuales del estudiante (HU-15).
class PreferenciasVisual {
  final EsquemaColores colores;
  final String tipografia;
  final double tamanoLetra;
  final Posicion posicionMenus; // arriba | abajo
  final Posicion posicionBotones; // izquierda | derecha

  const PreferenciasVisual({
    this.colores = EsquemaColores.alto_contraste,
    this.tipografia = 'Atkinson Hyperlegible',
    this.tamanoLetra = 22,
    this.posicionMenus = Posicion.abajo,
    this.posicionBotones = Posicion.derecha,
  });

  factory PreferenciasVisual.fromMap(Map<String, dynamic>? m) {
    m ??= {};
    const def = PreferenciasVisual();
    return PreferenciasVisual(
      colores: m['colores'] == null
          ? def.colores
          : EsquemaColores.values.byName(m['colores'] as String),
      tipografia: m['tipografia'] as String? ?? def.tipografia,
      tamanoLetra: (m['tamanoLetra'] as num?)?.toDouble() ?? def.tamanoLetra,
      posicionMenus: m['posicionMenus'] == null
          ? def.posicionMenus
          : Posicion.values.byName(m['posicionMenus'] as String),
      posicionBotones: m['posicionBotones'] == null
          ? def.posicionBotones
          : Posicion.values.byName(m['posicionBotones'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'colores': colores.name,
        'tipografia': tipografia,
        'tamanoLetra': tamanoLetra,
        'posicionMenus': posicionMenus.name,
        'posicionBotones': posicionBotones.name,
      };

  PreferenciasVisual copyWith({
    EsquemaColores? colores,
    String? tipografia,
    double? tamanoLetra,
    Posicion? posicionMenus,
    Posicion? posicionBotones,
  }) =>
      PreferenciasVisual(
        colores: colores ?? this.colores,
        tipografia: tipografia ?? this.tipografia,
        tamanoLetra: tamanoLetra ?? this.tamanoLetra,
        posicionMenus: posicionMenus ?? this.posicionMenus,
        posicionBotones: posicionBotones ?? this.posicionBotones,
      );
}

/// Map `preferencias` dentro del documento del estudiante (entidad Perfil).
class Preferencias {
  final PreferenciasComunicacion comunicacion;
  final PreferenciasVisual visual;

  const Preferencias({
    this.comunicacion = const PreferenciasComunicacion(),
    this.visual = const PreferenciasVisual(),
  });

  factory Preferencias.fromMap(Map<String, dynamic>? m) => Preferencias(
        comunicacion: PreferenciasComunicacion.fromMap(
            m?['comunicacion'] as Map<String, dynamic>?),
        visual:
            PreferenciasVisual.fromMap(m?['visual'] as Map<String, dynamic>?),
      );

  Map<String, dynamic> toMap() => {
        'comunicacion': comunicacion.toMap(),
        'visual': visual.toMap(),
      };

  Preferencias copyWith({
    PreferenciasComunicacion? comunicacion,
    PreferenciasVisual? visual,
  }) =>
      Preferencias(
        comunicacion: comunicacion ?? this.comunicacion,
        visual: visual ?? this.visual,
      );
}
