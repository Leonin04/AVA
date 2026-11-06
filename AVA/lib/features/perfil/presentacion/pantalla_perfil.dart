import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constantes/dimensiones.dart';
import '../../../core/widgets/avatar_usuario.dart';
import '../dominio/estudiante.dart';
import '../dominio/preferencias_accesibilidad.dart';
import '../logica/preferencias_controlador.dart';
import 'widgets/boton_opcion_accesibilidad.dart';

/// Perfil del estudiante: avatar, nombre y opciones de accesibilidad que
/// cambian el aspecto de toda la aplicación (HU-14).
class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key, required this.estudiante});

  final Estudiante estudiante;

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<PreferenciasControlador>();
    final preferencias = controlador.preferencias;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensiones.espaciado),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Dimensiones.anchoMaximoContenido,
              ),
              child: Column(
                children: [
                  AvatarUsuario(
                    nombre: estudiante.nombre,
                    urlImagen: estudiante.urlAvatar,
                    tamano: Dimensiones.avatarGrande,
                  ),
                  const SizedBox(height: Dimensiones.espaciadoPequeno),
                  Text(
                    estudiante.nombre,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: Dimensiones.espaciado * 1.5),
                  Text(
                    'Elige cómo quieres ver la aplicación',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: Dimensiones.espaciado),
                  Wrap(
                    spacing: Dimensiones.espaciado,
                    runSpacing: Dimensiones.espaciado,
                    alignment: WrapAlignment.center,
                    children: [
                      BotonOpcionAccesibilidad(
                        icono: Icons.text_increase,
                        texto: 'Letra grande',
                        seleccionada: preferencias.textoGrande,
                        alPulsar: controlador.alternarTextoGrande,
                      ),
                      BotonOpcionAccesibilidad(
                        icono: Icons.contrast,
                        texto: 'Alto contraste',
                        seleccionada: preferencias.altoContraste,
                        alPulsar: controlador.alternarAltoContraste,
                      ),
                      BotonOpcionAccesibilidad(
                        icono: Icons.dark_mode,
                        texto: 'Modo oscuro',
                        seleccionada: preferencias.modoOscuro,
                        alPulsar: controlador.alternarModoOscuro,
                      ),
                      for (final color in ColorTema.values)
                        BotonOpcionAccesibilidad(
                          icono: Icons.palette,
                          colorIcono: Color(color.valorArgb),
                          texto: 'Color ${color.nombre.toLowerCase()}',
                          seleccionada: preferencias.color == color,
                          alPulsar: () => controlador.elegirColor(color),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
