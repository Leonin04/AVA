import 'package:flutter/material.dart';

import '../constantes/dimensiones.dart';

/// Estructura de las pantallas de tutores y administración.
///
/// Son pantallas de trabajo para adultos: pueden desplazarse si el
/// formulario es largo, pero mantienen el mismo estilo, tamaños grandes y
/// un ancho máximo cómodo de leer.
class PantallaGestion extends StatelessWidget {
  const PantallaGestion({
    super.key,
    required this.titulo,
    required this.cuerpo,
    this.acciones = const [],
    this.botonFlotante,
    this.inferior,
    this.desplazable = true,
  });

  final String titulo;
  final Widget cuerpo;
  final List<Widget> acciones;
  final Widget? botonFlotante;

  /// Pestañas u otro contenido bajo la barra superior.
  final PreferredSizeWidget? inferior;

  /// Si es `false`, [cuerpo] ocupa el alto disponible (por ejemplo, una
  /// lista que ya se desplaza sola).
  final bool desplazable;

  @override
  Widget build(BuildContext context) {
    final contenido = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: const EdgeInsets.all(Dimensiones.espaciado),
          child: cuerpo,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(titulo), actions: acciones, bottom: inferior),
      floatingActionButton: botonFlotante,
      body: SafeArea(
        child: desplazable
            ? SingleChildScrollView(child: contenido)
            : contenido,
      ),
    );
  }
}

/// Título de una sección dentro de un formulario de gestión.
class TituloSeccion extends StatelessWidget {
  const TituloSeccion(this.texto, {super.key, this.descripcion});

  final String texto;
  final String? descripcion;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(
        top: Dimensiones.espaciado,
        bottom: Dimensiones.espaciadoPequeno,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text(texto, style: textos.titleLarge)),
          if (descripcion != null)
            Text(
              descripcion!,
              style: textos.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
