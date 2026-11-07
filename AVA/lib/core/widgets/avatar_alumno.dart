import 'package:flutter/material.dart';

/// Avatar redondo de un alumno. Si no tiene foto, o no carga, enseña un icono.
class AvatarAlumno extends StatelessWidget {
  const AvatarAlumno({super.key, required this.fotoUrl, this.radio = 56});

  final String fotoUrl;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final icono = Icon(
      Icons.person,
      size: radio,
      color: colores.onSecondaryContainer,
    );
    return CircleAvatar(
      radius: radio,
      backgroundColor: colores.secondaryContainer,
      child: fotoUrl.isEmpty
          ? icono
          : ClipOval(
              child: Image.network(
                fotoUrl,
                width: radio * 2,
                height: radio * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => icono,
              ),
            ),
    );
  }
}