import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constantes/dimensiones.dart';
import '../constantes/paleta.dart';
import '../modelos/recurso_visual.dart';
import '../tema/ajustes_interfaz.dart';
import '../utilidades/medida_texto.dart';
import 'pictograma.dart';

/// Disposición del contenido de un [BotonAccesible].
enum DisposicionBoton {
  /// Pictograma arriba y texto debajo, centrados (tarjetas de cuadrícula).
  vertical,

  /// Pictograma a la izquierda y texto a la derecha (filas de una lista).
  horizontal,
}

/// Botón principal de la interfaz del estudiante.
///
/// Reúne en un solo widget las ayudas de accesibilidad:
/// - Tamaño grande y borde visible; borde más grueso con el foco o
///   seleccionado (WCAG 2.4.7 y 1.4.11).
/// - Pictograma y texto juntos, respetando las preferencias de mostrar uno,
///   otro o ambos (HU-15).
/// - Filtro antitemblor: ignora pulsaciones repetidas (persona Carlos).
/// - Lectura en voz alta del texto al pulsar (persona Álex).
/// - Manejo con teclado o pulsador adaptado: se activa con Intro o Espacio
///   (persona Samuel).
class BotonAccesible extends StatefulWidget {
  const BotonAccesible({
    super.key,
    required this.texto,
    required this.alPulsar,
    this.pictograma,
    this.icono,
    this.imagen,
    this.color = ColorPastel.cielo,
    this.disposicion = DisposicionBoton.vertical,
    this.seleccionado = false,
    this.etiqueta,
    this.textoSecundario,
    this.etiquetaSemantica,
    this.textoVoz,
    this.autofoco = false,
    this.ocultarTexto = false,
    this.textoGrande = false,
    this.tamanoTexto,
  });

  final String texto;
  final VoidCallback? alPulsar;
  final RecursoVisual? pictograma;

  /// Icono que se usa si no hay pictograma o si no se puede cargar.
  final IconData? icono;

  /// Imagen propia en lugar del pictograma (por ejemplo, el avatar de un
  /// alumno). Recibe el lado disponible. Se muestra siempre, porque sirve
  /// para identificar.
  final Widget Function(double lado)? imagen;
  final ColorPastel color;
  final DisposicionBoton disposicion;
  final bool seleccionado;

  /// Texto corto y destacado encima del principal, por ejemplo `AHORA`.
  final String? etiqueta;

  /// Línea adicional debajo del texto, por ejemplo la hora.
  final String? textoSecundario;

  /// Descripción para lectores de pantalla, si debe ser distinta del texto.
  final String? etiquetaSemantica;

  /// Lo que se lee en voz alta al pulsar. Por defecto, [texto].
  final String? textoVoz;
  final bool autofoco;

  /// No pintar [texto] porque la [imagen] ya lo muestra (por ejemplo, un
  /// número del teclado). Se sigue usando para la voz y el lector.
  final bool ocultarTexto;

  /// Texto principal más grande, para botones con pocas palabras y mucho
  /// espacio (clases, menú principal).
  final bool textoGrande;

  /// Tamaño de letra fijo, calculado con [MedidaTexto.tamanoComun] para que
  /// varios botones pequeños tengan la misma letra. El texto no se encoge
  /// y el pictograma ocupa el espacio que quede (o no aparece si no cabe).
  final double? tamanoTexto;

  TextStyle? estiloTexto(TextTheme textos) {
    final base = textoGrande ? textos.displaySmall : textos.titleLarge;
    final tamano = tamanoTexto;
    return tamano == null ? base : base?.copyWith(fontSize: tamano);
  }

  /// Estilo de la línea secundaria (por ejemplo, la hora).
  TextStyle? estiloSecundario(TextTheme textos) {
    final tamano = tamanoTexto;
    final base = textos.titleMedium?.copyWith(fontWeight: FontWeight.w400);
    return tamano == null
        ? base
        : base?.copyWith(fontSize: tamano * MedidaTexto.proporcionSecundario);
  }

  /// Estilo de la etiqueta (`AHORA`, `DESPUÉS`).
  TextStyle? estiloEtiqueta(TextTheme textos) {
    final tamano = tamanoTexto;
    final base = textos.labelLarge?.copyWith(letterSpacing: 1.5);
    return tamano == null
        ? base
        : base?.copyWith(fontSize: tamano * MedidaTexto.proporcionEtiqueta);
  }

  @override
  State<BotonAccesible> createState() => _BotonAccesibleState();
}

class _BotonAccesibleState extends State<BotonAccesible> {
  DateTime? _ultimaPulsacion;
  bool _conFoco = false;

  void _pulsar() {
    final alPulsar = widget.alPulsar;
    if (alPulsar == null) return;

    final ajustes = AjustesInterfaz.of(context);
    final ahora = DateTime.now();
    final espera = ajustes.filtroAntitemblor
        ? Dimensiones.esperaAntitemblor
        : Dimensiones.esperaDobleToque;
    final ultima = _ultimaPulsacion;
    if (ultima != null && ahora.difference(ultima) < espera) return;
    _ultimaPulsacion = ahora;

    if (ajustes.leerEnVoz) {
      ajustes.voz.decir(widget.textoVoz ?? widget.texto);
    }
    alPulsar();
  }

  @override
  Widget build(BuildContext context) {
    final ajustes = AjustesInterfaz.of(context);
    final estilo = ajustes.estiloDe(widget.color);
    final habilitado = widget.alPulsar != null;
    final resaltado = widget.seleccionado || _conFoco;
    final radio = BorderRadius.circular(Dimensiones.radioBorde);

    final descripcion =
        widget.etiquetaSemantica ??
        [
          if (widget.etiqueta != null) widget.etiqueta!,
          widget.texto,
          if (widget.textoSecundario != null) widget.textoSecundario!,
        ].join('. ');

    return Semantics(
      button: true,
      enabled: habilitado,
      selected: widget.seleccionado,
      label: descripcion,
      excludeSemantics: true,
      child: Opacity(
        opacity: habilitado ? 1 : 0.45,
        child: Material(
          color: estilo.fondo,
          shape: RoundedRectangleBorder(
            borderRadius: radio,
            side: BorderSide(
              color: resaltado ? estilo.texto : estilo.borde,
              width: resaltado
                  ? Dimensiones.grosorBordeFoco
                  : Dimensiones.grosorBorde,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: habilitado ? _pulsar : null,
            autofocus: widget.autofoco,
            onFocusChange: (foco) => setState(() => _conFoco = foco),
            borderRadius: radio,
            focusColor: estilo.acento.withValues(alpha: 0.18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: Dimensiones.objetivoTactilMinimo,
                minHeight: Dimensiones.objetivoTactilMinimo,
              ),
              child: Padding(
                padding: EdgeInsets.all(
                  widget.tamanoTexto == null
                      ? Dimensiones.espaciadoPequeno
                      : Dimensiones.rellenoCompacto,
                ),
                child: widget.disposicion == DisposicionBoton.vertical
                    ? _ContenidoVertical(boton: widget, estilo: estilo)
                    : _ContenidoHorizontal(boton: widget, estilo: estilo),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContenidoVertical extends StatelessWidget {
  const _ContenidoVertical({required this.boton, required this.estilo});

  static const _separacionImagen = 8.0;
  static const _imagenMinima = 24.0;

  final BotonAccesible boton;
  final EstiloTarjeta estilo;

  /// Lado del pictograma. Sin [BotonAccesible.tamanoTexto] es una parte fija
  /// del botón. Con él manda el texto: el pictograma usa el alto que sobra
  /// y es 0 si no queda sitio para uno reconocible.
  double _ladoImagen(
    BuildContext context, {
    required double ancho,
    required double alto,
    required bool conTexto,
    required TextStyle? estiloPrincipal,
  }) {
    final tamano = boton.tamanoTexto;
    final double lado;
    if (tamano == null || estiloPrincipal == null || !conTexto) {
      lado = math
          .min(alto * (conTexto ? 0.58 : 0.85), ancho * 0.75)
          .clamp(28.0, 240.0);
    } else {
      final altoTextos = MedidaTexto.altoTarjeta(
        (
          etiqueta: boton.etiqueta,
          texto: boton.texto,
          secundario: boton.textoSecundario,
        ),
        estiloPrincipal,
        tamano,
        MediaQuery.textScalerOf(context),
        ancho,
      );
      final libre = math.min(
        alto - altoTextos - _separacionImagen,
        ancho * 0.75,
      );
      lado = libre >= _imagenMinima ? math.min(libre, 240.0) : 0;
    }
    return lado;
  }

  @override
  Widget build(BuildContext context) {
    final ajustes = AjustesInterfaz.of(context);
    final textos = Theme.of(context).textTheme;
    final imagenPropia = boton.imagen;
    final conImagen =
        imagenPropia != null ||
        (ajustes.mostrarPictogramas &&
            (boton.pictograma != null || boton.icono != null));
    final conTexto =
        !boton.ocultarTexto && (ajustes.mostrarTexto || !conImagen);

    return LayoutBuilder(
      builder: (context, restricciones) {
        final ancho = restricciones.maxWidth.isFinite
            ? restricciones.maxWidth
            : 240.0;
        final alto = restricciones.maxHeight.isFinite
            ? restricciones.maxHeight
            : ancho;
        final estiloPrincipal = boton
            .estiloTexto(textos)
            ?.copyWith(color: estilo.texto);
        final ladoImagen = _ladoImagen(
          context,
          ancho: ancho,
          alto: alto,
          conTexto: conTexto,
          estiloPrincipal: estiloPrincipal,
        );
        final mostrarImagen = conImagen && ladoImagen > 0;

        // FittedBox reduce el contenido si no cabe, en lugar de cortarlo:
        // así nunca hace falta desplazar la pantalla. El ancho nunca es
        // menor que la palabra más larga, para no partir palabras.
        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: math.max(
                ancho,
                conTexto
                    ? anchoPalabraMasLarga(
                        context,
                        boton.texto,
                        estiloPrincipal,
                      )
                    : 0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (boton.etiqueta != null) ...[
                    _Etiqueta(boton: boton, estilo: estilo),
                    const SizedBox(height: 6),
                  ],
                  if (mostrarImagen && imagenPropia != null)
                    imagenPropia(ladoImagen)
                  else if (mostrarImagen)
                    Pictograma(
                      recurso: boton.pictograma,
                      tamano: ladoImagen,
                      iconoRespaldo: boton.icono ?? Icons.image_outlined,
                      colorRespaldo: estilo.acento,
                    ),
                  if (mostrarImagen && conTexto)
                    const SizedBox(height: _separacionImagen),
                  if (conTexto)
                    Text(
                      boton.texto,
                      textAlign: TextAlign.center,
                      style: estiloPrincipal,
                    ),
                  if (boton.textoSecundario != null)
                    Text(
                      boton.textoSecundario!,
                      textAlign: TextAlign.center,
                      style: boton
                          .estiloSecundario(textos)
                          ?.copyWith(color: estilo.texto),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ContenidoHorizontal extends StatelessWidget {
  const _ContenidoHorizontal({required this.boton, required this.estilo});

  final BotonAccesible boton;
  final EstiloTarjeta estilo;

  @override
  Widget build(BuildContext context) {
    final ajustes = AjustesInterfaz.of(context);
    final textos = Theme.of(context).textTheme;
    final conImagen =
        ajustes.mostrarPictogramas &&
        (boton.pictograma != null || boton.icono != null);
    final conTexto = ajustes.mostrarTexto || !conImagen;

    return LayoutBuilder(
      builder: (context, restricciones) {
        final alto = restricciones.maxHeight.isFinite
            ? restricciones.maxHeight
            : 96.0;
        final ancho = restricciones.maxWidth.isFinite
            ? restricciones.maxWidth
            : 400.0;
        // La imagen nunca ocupa más de la mitad del ancho, para que el
        // texto siempre quepa aunque el botón sea estrecho.
        final ladoImagen = math
            .min(alto * 0.9, ancho * 0.45)
            .clamp(24.0, 140.0);
        final separacion = ancho < 240
            ? Dimensiones.espaciadoPequeno
            : Dimensiones.espaciado;
        final anchoTexto = ancho - (conImagen ? ladoImagen + separacion : 0);

        return Row(
          children: [
            if (conImagen)
              Pictograma(
                recurso: boton.pictograma,
                tamano: ladoImagen,
                iconoRespaldo: boton.icono ?? Icons.image_outlined,
                colorRespaldo: estilo.acento,
              ),
            if (conImagen) SizedBox(width: separacion),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: math.max(
                      math.max(48, anchoTexto),
                      conTexto
                          ? anchoPalabraMasLarga(
                              context,
                              boton.texto,
                              boton.estiloTexto(textos),
                            )
                          : 0,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // La etiqueta va junto a la hora, en la misma línea si
                      // cabe, para que el nombre de la tarea no pierda tamaño.
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (boton.etiqueta != null)
                            _Etiqueta(boton: boton, estilo: estilo),
                          if (boton.textoSecundario != null)
                            Text(
                              boton.textoSecundario!,
                              style: boton
                                  .estiloSecundario(textos)
                                  ?.copyWith(color: estilo.texto),
                            ),
                        ],
                      ),
                      if (conTexto)
                        Text(
                          boton.texto,
                          style: boton
                              .estiloTexto(textos)
                              ?.copyWith(color: estilo.texto),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Distintivo como `AHORA` o `DESPUÉS`.
class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.boton, required this.estilo});

  final BotonAccesible boton;
  final EstiloTarjeta estilo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: estilo.texto,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        boton.etiqueta ?? '',
        style: boton
            .estiloEtiqueta(Theme.of(context).textTheme)
            ?.copyWith(color: estilo.fondo),
      ),
    );
  }
}

/// Ancho que ocupa la palabra más larga de [texto] con [estilo], teniendo
/// en cuenta la escala de letra elegida.
double anchoPalabraMasLarga(
  BuildContext context,
  String texto,
  TextStyle? estilo,
) {
  final escala = MediaQuery.textScalerOf(context);
  var maximo = 0.0;
  final palabras = texto.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  for (final palabra in palabras) {
    final medida = TextPainter(
      text: TextSpan(text: palabra, style: estilo),
      textDirection: TextDirection.ltr,
      textScaler: escala,
      maxLines: 1,
    )..layout();
    maximo = math.max(maximo, medida.width);
    medida.dispose();
  }
  return maximo.ceilToDouble();
}
