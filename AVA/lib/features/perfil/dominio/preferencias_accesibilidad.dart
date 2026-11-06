import '../../../core/constantes/paleta.dart';
import '../../agenda/dominio/vista_agenda.dart';

/// Tamaño de la letra (RNF-05).
enum TamanoTexto {
  normal('Letra normal', 1.0),
  grande('Letra grande', 1.25),
  muyGrande('Letra muy grande', 1.5);

  const TamanoTexto(this.nombre, this.escala);

  final String nombre;
  final double escala;
}

/// Preferencias visuales y de comunicación del estudiante (HU-14, RF-08,
/// RNF-05). Cambian el aspecto de toda la aplicación.
class PreferenciasAccesibilidad {
  const PreferenciasAccesibilidad({
    this.tamanoTexto = TamanoTexto.normal,
    this.letraClara = true,
    this.color = ColorPastel.cielo,
    this.altoContraste = false,
    this.modoOscuro = false,
    this.menuArriba = false,
    this.mostrarPictogramas = true,
    this.mostrarTexto = true,
    this.leerEnVoz = false,
    this.filtroAntitemblor = false,
    this.vistasAgenda = const {
      VistaAgenda.semanal,
      VistaAgenda.diaria,
      VistaAgenda.siguienteTarea,
    },
  });

  final TamanoTexto tamanoTexto;

  /// Tipografía Atkinson Hyperlegible, diseñada para baja visión.
  final bool letraClara;
  final ColorPastel color;
  final bool altoContraste;
  final bool modoOscuro;

  /// Barra de navegación arriba (posición de los menús).
  final bool menuArriba;

  // Apoyos de comunicación.
  final bool mostrarPictogramas;
  final bool mostrarTexto;
  final bool leerEnVoz;

  /// Ignora pulsaciones repetidas (temblores o espasmos).
  final bool filtroAntitemblor;

  /// Vistas de la agenda habilitadas para el estudiante (HU-09).
  final Set<VistaAgenda> vistasAgenda;

  PreferenciasAccesibilidad copyWith({
    TamanoTexto? tamanoTexto,
    bool? letraClara,
    ColorPastel? color,
    bool? altoContraste,
    bool? modoOscuro,
    bool? menuArriba,
    bool? mostrarPictogramas,
    bool? mostrarTexto,
    bool? leerEnVoz,
    bool? filtroAntitemblor,
    Set<VistaAgenda>? vistasAgenda,
  }) {
    return PreferenciasAccesibilidad(
      tamanoTexto: tamanoTexto ?? this.tamanoTexto,
      letraClara: letraClara ?? this.letraClara,
      color: color ?? this.color,
      altoContraste: altoContraste ?? this.altoContraste,
      modoOscuro: modoOscuro ?? this.modoOscuro,
      menuArriba: menuArriba ?? this.menuArriba,
      mostrarPictogramas: mostrarPictogramas ?? this.mostrarPictogramas,
      mostrarTexto: mostrarTexto ?? this.mostrarTexto,
      leerEnVoz: leerEnVoz ?? this.leerEnVoz,
      filtroAntitemblor: filtroAntitemblor ?? this.filtroAntitemblor,
      vistasAgenda: vistasAgenda ?? this.vistasAgenda,
    );
  }

  Map<String, Object?> toMap() => {
    'tamanoTexto': tamanoTexto.name,
    'letraClara': letraClara,
    'color': color.name,
    'altoContraste': altoContraste,
    'modoOscuro': modoOscuro,
    'menuArriba': menuArriba,
    'mostrarPictogramas': mostrarPictogramas,
    'mostrarTexto': mostrarTexto,
    'leerEnVoz': leerEnVoz,
    'filtroAntitemblor': filtroAntitemblor,
    'vistasAgenda': [for (final vista in vistasAgenda) vista.name],
  };

  factory PreferenciasAccesibilidad.fromMap(Object? datos) {
    const porDefecto = PreferenciasAccesibilidad();
    if (datos is! Map) return porDefecto;

    final vistas = {
      for (final nombre in datos['vistasAgenda'] as List? ?? const [])
        ?VistaAgenda.porNombre(nombre as String),
    };
    return PreferenciasAccesibilidad(
      tamanoTexto: TamanoTexto.values.firstWhere(
        (t) => t.name == datos['tamanoTexto'],
        orElse: () => TamanoTexto.normal,
      ),
      letraClara: datos['letraClara'] as bool? ?? porDefecto.letraClara,
      color: ColorPastel.porNombre(datos['color'] as String?),
      altoContraste: datos['altoContraste'] as bool? ?? false,
      modoOscuro: datos['modoOscuro'] as bool? ?? false,
      menuArriba: datos['menuArriba'] as bool? ?? false,
      mostrarPictogramas: datos['mostrarPictogramas'] as bool? ?? true,
      mostrarTexto: datos['mostrarTexto'] as bool? ?? true,
      leerEnVoz: datos['leerEnVoz'] as bool? ?? false,
      filtroAntitemblor: datos['filtroAntitemblor'] as bool? ?? false,
      vistasAgenda: vistas.isEmpty ? porDefecto.vistasAgenda : vistas,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PreferenciasAccesibilidad &&
      other.tamanoTexto == tamanoTexto &&
      other.letraClara == letraClara &&
      other.color == color &&
      other.altoContraste == altoContraste &&
      other.modoOscuro == modoOscuro &&
      other.menuArriba == menuArriba &&
      other.mostrarPictogramas == mostrarPictogramas &&
      other.mostrarTexto == mostrarTexto &&
      other.leerEnVoz == leerEnVoz &&
      other.filtroAntitemblor == filtroAntitemblor &&
      other.vistasAgenda.length == vistasAgenda.length &&
      other.vistasAgenda.containsAll(vistasAgenda);

  @override
  int get hashCode => Object.hash(
    tamanoTexto,
    letraClara,
    color,
    altoContraste,
    modoOscuro,
    menuArriba,
    mostrarPictogramas,
    mostrarTexto,
    leerEnVoz,
    filtroAntitemblor,
    Object.hashAllUnordered(vistasAgenda),
  );
}
