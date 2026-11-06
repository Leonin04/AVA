import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/dimensiones.dart';
import '../../../core/widgets/avatar_usuario.dart';
import '../../perfil/dominio/estudiante.dart';
import '../../perfil/logica/preferencias_controlador.dart';
import '../dominio/metodo_acceso.dart';
import '../dominio/repositorio_autenticacion.dart';
import '../logica/login_estudiante_controlador.dart';
import '../logica/sesion_controlador.dart';
import 'widgets/formulario_contrasena_estudiante.dart';
import 'widgets/teclado_pictogramas.dart';

/// Login accesible del estudiante (HU-08). Muestra su avatar y el método de
/// acceso que tiene configurado: contraseña o pictogramas.
class PantallaLoginEstudiante extends StatefulWidget {
  const PantallaLoginEstudiante({super.key, required this.estudiante});

  final Estudiante estudiante;

  @override
  State<PantallaLoginEstudiante> createState() =>
      _PantallaLoginEstudianteState();
}

class _PantallaLoginEstudianteState extends State<PantallaLoginEstudiante> {
  late final LoginEstudianteControlador _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = LoginEstudianteControlador(
      repositorio: context.read<RepositorioAutenticacion>(),
      estudiante: widget.estudiante,
    );
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _acceder() {
    if (!mounted) return;

    context.read<SesionControlador>().iniciarComoEstudiante(widget.estudiante);
    context
        .read<PreferenciasControlador>()
        .aplicarDeEstudiante(widget.estudiante);
    unawaited(
      Navigator.pushNamedAndRemoveUntil(
        context,
        Rutas.menuEstudiante,
        (_) => false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estudiante = widget.estudiante;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensiones.espaciado),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Dimensiones.anchoMaximoContenido,
              ),
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
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: Dimensiones.espaciado * 1.5),
                  switch (estudiante.metodoAcceso) {
                    AccesoConContrasena() => FormularioContrasenaEstudiante(
                        controlador: _controlador,
                        alAcceder: _acceder,
                      ),
                    AccesoConPictogramas() => TecladoPictogramas(
                        controlador: _controlador,
                        alAcceder: _acceder,
                      ),
                  },
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
