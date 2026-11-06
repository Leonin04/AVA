import 'dart:convert';

import 'package:flutter/material.dart';

import '../modelos/recurso_visual.dart';
import '../servicios/servicio_arasaac.dart';

/// Muestra un [RecursoVisual]: pictograma de ARASAAC o fotografía propia.
///
/// Si la imagen no se puede cargar (por ejemplo, sin conexión) se muestra
/// [iconoRespaldo], de modo que la pantalla nunca queda vacía.
class Pictograma extends StatelessWidget {
  const Pictograma({
    super.key,
    required this.recurso,
    required this.tamano,
    this.etiqueta,
    this.iconoRespaldo = Icons.image_outlined,
    this.colorRespaldo,
  });

  final RecursoVisual? recurso;
  final double tamano;

  /// Descripción para lectores de pantalla. Si es `null`, la imagen se
  /// considera decorativa (el texto ya está al lado).
  final String? etiqueta;
  final IconData iconoRespaldo;
  final Color? colorRespaldo;

  @override
  Widget build(BuildContext context) {
    final respaldo = Icon(
      iconoRespaldo,
      size: tamano * 0.8,
      color: colorRespaldo ?? Theme.of(context).colorScheme.onSurface,
    );

    final imagen = switch (recurso) {
      null => respaldo,
      PictogramaArasaac(:final id) => Image.network(
        ServicioArasaac.urlImagen(id),
        width: tamano,
        height: tamano,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
        errorBuilder: (_, __, ___) => respaldo,
        loadingBuilder: (context, hijo, progreso) =>
            progreso == null ? hijo : SizedBox.square(dimension: tamano),
      ),
      FotoPropia(:final url) => ClipRRect(
        borderRadius: BorderRadius.circular(tamano / 8),
        child: url.startsWith('data:')
            ? Image.memory(
                base64Decode(url.substring(url.indexOf(',') + 1)),
                width: tamano,
                height: tamano,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                errorBuilder: (_, __, ___) => respaldo,
              )
            : Image.network(
                url,
                width: tamano,
                height: tamano,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                errorBuilder: (_, __, ___) => respaldo,
              ),
      ),
    };

    final contenido = SizedBox.square(
      dimension: tamano,
      child: Center(child: imagen),
    );
    final texto = etiqueta;
    return texto == null
        ? ExcludeSemantics(child: contenido)
        : Semantics(image: true, label: texto, child: contenido);
  }
}
