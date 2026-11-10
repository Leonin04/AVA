import 'package:flutter/material.dart';

import '../../../core/constantes/paleta.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/modelos/recurso_visual.dart';
import '../dominio/preferencias_accesibilidad.dart';

/// Una opción de accesibilidad que se puede activar con un botón.
///
/// La misma lista sirve para el perfil del estudiante y para la ficha que
/// rellena el tutor, de modo que ambos ven las mismas opciones.
class OpcionPreferencia {
  const OpcionPreferencia({
    required this.texto,
    required this.icono,
    required this.color,
    required this.activa,
    required this.aplicar,
    this.pictograma,
    this.esInterruptor = true,
  });

  final String texto;
  final IconData icono;
  final RecursoVisual? pictograma;
  final ColorPastel color;

  /// Si está activa con las preferencias dadas.
  final bool Function(PreferenciasAccesibilidad p) activa;

  /// Preferencias resultantes de pulsar la opción.
  final PreferenciasAccesibilidad Function(PreferenciasAccesibilidad p) aplicar;

  /// `true` si se activa y desactiva; `false` si es una elección entre
  /// varias (tamaño, color).
  final bool esInterruptor;

  /// Texto del estado, para no depender solo del borde o del color.
  String estado(PreferenciasAccesibilidad p) =>
      esInterruptor ? (activa(p) ? 'Sí' : 'No') : (activa(p) ? 'Elegido' : '');

  static List<OpcionPreferencia> todas() => [
    for (final tamano in TamanoTexto.values)
      OpcionPreferencia(
        texto: tamano.nombre,
        icono: Icons.format_size_rounded,
        pictograma: tamano == TamanoTexto.normal
            ? Pictogramas.pequeno
            : Pictogramas.grande,
        color: ColorPastel.amarillo,
        esInterruptor: false,
        activa: (p) => p.tamanoTexto == tamano,
        aplicar: (p) => p.copyWith(tamanoTexto: tamano),
      ),
    OpcionPreferencia(
      texto: 'Letra clara',
      icono: Icons.font_download_rounded,
      pictograma: Pictogramas.letra,
      color: ColorPastel.melocoton,
      activa: (p) => p.letraClara,
      aplicar: (p) => p.copyWith(letraClara: !p.letraClara),
    ),
    OpcionPreferencia(
      texto: 'Alto contraste',
      icono: Icons.contrast_rounded,
      pictograma: Pictogramas.contraste,
      color: ColorPastel.lima,
      activa: (p) => p.altoContraste,
      aplicar: (p) => p.copyWith(altoContraste: !p.altoContraste),
    ),
    OpcionPreferencia(
      texto: 'Modo oscuro',
      icono: Icons.dark_mode_rounded,
      pictograma: Pictogramas.noche,
      color: ColorPastel.lavanda,
      activa: (p) => p.modoOscuro,
      aplicar: (p) => p.copyWith(modoOscuro: !p.modoOscuro),
    ),
    for (final color in ColorPastel.values)
      OpcionPreferencia(
        texto: 'Color ${color.nombre.toLowerCase()}',
        icono: Icons.palette_rounded,
        pictograma: Pictogramas.colores,
        color: color,
        esInterruptor: false,
        activa: (p) => p.color == color,
        aplicar: (p) => p.copyWith(color: color),
      ),
    OpcionPreferencia(
      texto: 'Ver dibujos',
      icono: Icons.image_rounded,
      pictograma: Pictogramas.ojo,
      color: ColorPastel.cielo,
      activa: (p) => p.mostrarPictogramas,
      aplicar: (p) => p.copyWith(mostrarPictogramas: !p.mostrarPictogramas),
    ),
    OpcionPreferencia(
      texto: 'Ver palabras',
      icono: Icons.text_fields_rounded,
      pictograma: Pictogramas.leer,
      color: ColorPastel.turquesa,
      activa: (p) => p.mostrarTexto,
      aplicar: (p) => p.copyWith(mostrarTexto: !p.mostrarTexto),
    ),
    OpcionPreferencia(
      texto: 'Leer en voz alta',
      icono: Icons.volume_up_rounded,
      pictograma: Pictogramas.escuchar,
      color: ColorPastel.rosa,
      activa: (p) => p.leerEnVoz,
      aplicar: (p) => p.copyWith(leerEnVoz: !p.leerEnVoz),
    ),
    OpcionPreferencia(
      texto: 'Botón Escuchar',
      icono: Icons.record_voice_over_rounded,
      pictograma: Pictogramas.escuchar,
      color: ColorPastel.amarillo,
      activa: (p) => p.botonEscuchar,
      aplicar: (p) => p.copyWith(botonEscuchar: !p.botonEscuchar),
    ),
    OpcionPreferencia(
      texto: 'Evitar toques dobles',
      icono: Icons.touch_app_rounded,
      pictograma: Pictogramas.pulsar,
      color: ColorPastel.menta,
      activa: (p) => p.filtroAntitemblor,
      aplicar: (p) => p.copyWith(filtroAntitemblor: !p.filtroAntitemblor),
    ),
    OpcionPreferencia(
      texto: 'Botones arriba',
      icono: Icons.vertical_align_top_rounded,
      pictograma: Pictogramas.configuracion,
      color: ColorPastel.cielo,
      activa: (p) => p.menuArriba,
      aplicar: (p) => p.copyWith(menuArriba: !p.menuArriba),
    ),
  ];
}
