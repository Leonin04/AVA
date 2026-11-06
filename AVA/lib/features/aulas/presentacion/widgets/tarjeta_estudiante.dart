import 'package:flutter/material.dart';

import '../../../../core/constantes/dimensiones.dart';
import '../../../../core/widgets/avatar_usuario.dart';
import '../../../perfil/dominio/estudiante.dart';

/// Avatar y nombre de un alumno, pulsable como un único botón.
class TarjetaEstudiante extends StatelessWidget {
  const TarjetaEstudiante({
    super.key,
    required this.estudiante,
    required this.alPulsar,
  });

  final Estudiante estudiante;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Entrar como ${estudiante.nombre}',
      excludeSemantics: true,
      child: SizedBox(
        width: 200,
        child: InkWell(
          onTap: alPulsar,
          borderRadius: BorderRadius.circular(Dimensiones.radioBorde),
          child: Padding(
            padding: const EdgeInsets.all(Dimensiones.espaciadoPequeno),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AvatarUsuario(
                  nombre: estudiante.nombre,
                  urlImagen: estudiante.urlAvatar,
                  tamano: Dimensiones.avatarGrande,
                ),
                const SizedBox(height: Dimensiones.espaciadoPequeno),
                Text(
                  estudiante.nombre,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
