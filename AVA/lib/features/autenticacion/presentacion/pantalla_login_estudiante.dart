import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/dimensiones.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/widgets/avatar_usuario.dart';
import '../../../core/widgets/pantalla_estudiante.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../../perfil/logica/preferencias_controlador.dart';
import '../dominio/metodo_acceso.dart';
import '../dominio/repositorio_autenticacion.dart';
import '../logica/login_estudiante_controlador.dart';
import '../logica/sesion_controlador.dart';
import 'widgets/aviso_error.dart';
import 'widgets/formulario_contrasena_estudiante.dart';
import 'widgets/huecos_clave.dart';
import 'widgets/teclado_numerico.dart';
import 'widgets/teclado_pictogramas.dart';

/// Login accesible del estudiante (HU-09). A la izquierda su foto, la
/// instrucción y los huecos de la clave; a la derecha el teclado del método
/// que tiene configurado: pictogramas, número o contraseña.
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

    // Perfil completo (con sus preferencias), que solo se puede leer una
    // vez iniciada la sesión.
    final perfil = _controlador.perfil ?? widget.estudiante;
    context.read<SesionControlador>().iniciarComoEstudiante(perfil);
    context.read<PreferenciasControlador>().aplicarDeEstudiante(perfil);
    unawaited(
      Navigator.pushNamedAndRemoveUntil(
        context,
        Rutas.menuEstudiante,
        (_) => false,
      ),
    );
  }

  String get _instruccion => switch (widget.estudiante.metodoAcceso) {
    AccesoConPictogramas() => 'Toca tus dibujos en orden.',
    AccesoConPin() => 'Toca tus números en orden.',
    AccesoConContrasena() => 'Escribe tu contraseña.',
  };

  @override
  Widget build(BuildContext context) {
    final estudiante = widget.estudiante;

    return PantallaEstudiante(
      titulo: 'Hola, ${estudiante.nombre}',
      pictograma: Pictogramas.hola,
      icono: Icons.waving_hand_rounded,
      color: estudiante.color,
      textoVoz: 'Hola, ${estudiante.nombre}. $_instruccion',
      cuerpo: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: ListenableBuilder(
              listenable: _controlador,
              builder: (context, _) => _PanelEstudiante(
                estudiante: estudiante,
                instruccion: _instruccion,
                controlador: _controlador,
              ),
            ),
          ),
          const SizedBox(width: Dimensiones.espaciado * 1.5),
          Expanded(
            flex: 3,
            child: switch (estudiante.metodoAcceso) {
              AccesoConPictogramas() => TecladoPictogramas(
                controlador: _controlador,
                alAcceder: _acceder,
              ),
              AccesoConPin() => TecladoNumerico(
                controlador: _controlador,
                alAcceder: _acceder,
              ),
              AccesoConContrasena() => FormularioContrasenaEstudiante(
                controlador: _controlador,
                alAcceder: _acceder,
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _PanelEstudiante extends StatelessWidget {
  const _PanelEstudiante({
    required this.estudiante,
    required this.instruccion,
    required this.controlador,
  });

  final Estudiante estudiante;
  final String instruccion;
  final LoginEstudianteControlador controlador;

  @override
  Widget build(BuildContext context) {
    final error = controlador.mensajeError;

    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AvatarUsuario(
                nombre: estudiante.nombre,
                imagen: estudiante.avatar,
                color: estudiante.color,
                tamano: Dimensiones.avatarGrande,
              ),
              const SizedBox(height: Dimensiones.espaciado),
              Text(
                instruccion,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (controlador.longitudClave > 0) ...[
                const SizedBox(height: Dimensiones.espaciado),
                HuecosClave(controlador: controlador),
              ],
              const SizedBox(height: Dimensiones.espaciado),
              // Se reserva el hueco del aviso para que nada salte de sitio.
              SizedBox(
                height: 96,
                child: error == null ? null : AvisoError(mensaje: error),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
