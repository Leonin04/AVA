import 'package:flutter/material.dart';

import '../constantes/dimensiones.dart';

/// Avatar circular de un usuario.
///
/// Si no tiene imagen (hasta que se conecte Firebase Storage) muestra la
/// inicial del nombre.
class AvatarUsuario extends StatelessWidget {
  const AvatarUsuario({
    super.key,
    required this.nombre,
    this.urlImagen,
    this.tamano = Dimensiones.avatarMediano,
  });

  final String nombre;
  final String? urlImagen;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final url = urlImagen;

    return Semantics(
      label: 'Foto de $nombre',
      image: true,
      child: CircleAvatar(
        radius: tamano / 2,
        backgroundColor: esquema.primaryContainer,
        foregroundColor: esquema.onPrimaryContainer,
        backgroundImage: url == null ? null : NetworkImage(url),
        child: url == null
            ? Text(
                _inicial,
                style: TextStyle(
                  fontSize: tamano / 2.4,
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
      ),
    );
  }

  String get _inicial => nombre.isEmpty ? '?' : nombre[0].toUpperCase();
}
