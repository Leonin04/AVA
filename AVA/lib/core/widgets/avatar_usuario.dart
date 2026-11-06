import 'package:flutter/material.dart';

import '../constantes/dimensiones.dart';
import '../constantes/paleta.dart';
import '../modelos/recurso_visual.dart';
import '../tema/ajustes_interfaz.dart';
import 'pictograma.dart';

/// Avatar circular de un usuario: su foto o pictograma, o la inicial del
/// nombre si no tiene imagen.
class AvatarUsuario extends StatelessWidget {
  const AvatarUsuario({
    super.key,
    required this.nombre,
    this.imagen,
    this.color = ColorPastel.cielo,
    this.tamano = Dimensiones.avatarMediano,
  });

  final String nombre;
  final RecursoVisual? imagen;
  final ColorPastel color;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final estilo = AjustesInterfaz.of(context).estiloDe(color);
    final recurso = imagen;

    return Semantics(
      label: 'Foto de $nombre',
      image: true,
      excludeSemantics: true,
      child: Container(
        width: tamano,
        height: tamano,
        decoration: BoxDecoration(
          color: estilo.fondo,
          shape: BoxShape.circle,
          border: Border.all(
            color: estilo.borde,
            width: Dimensiones.grosorBorde,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        child: switch (recurso) {
          FotoPropia() => Pictograma(recurso: recurso, tamano: tamano),
          PictogramaArasaac() => Pictograma(
            recurso: recurso,
            tamano: tamano * 0.7,
          ),
          null => Text(
            nombre.isEmpty ? '?' : nombre[0].toUpperCase(),
            style: TextStyle(
              fontSize: tamano / 2.2,
              fontWeight: FontWeight.w700,
              color: estilo.texto,
            ),
          ),
        },
      ),
    );
  }
}
