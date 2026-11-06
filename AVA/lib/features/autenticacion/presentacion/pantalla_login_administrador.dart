import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/dimensiones.dart';
import '../dominio/repositorio_autenticacion.dart';
import '../logica/login_administrador_controlador.dart';
import '../logica/sesion_controlador.dart';

/// Inicio de sesión del profesorado y la administración (HU-17).
class PantallaLoginAdministrador extends StatefulWidget {
  const PantallaLoginAdministrador({super.key});

  @override
  State<PantallaLoginAdministrador> createState() =>
      _PantallaLoginAdministradorState();
}

class _PantallaLoginAdministradorState
    extends State<PantallaLoginAdministrador> {
  final _formulario = GlobalKey<FormState>();
  final _usuario = TextEditingController();
  final _contrasena = TextEditingController();
  late final LoginAdministradorControlador _controlador;
  bool _mostrarContrasena = false;

  @override
  void initState() {
    super.initState();
    _controlador =
        LoginAdministradorControlador(context.read<RepositorioAutenticacion>());
  }

  @override
  void dispose() {
    _usuario.dispose();
    _contrasena.dispose();
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!(_formulario.currentState?.validate() ?? false)) return;

    final correcto = await _controlador.iniciarSesion(
      usuario: _usuario.text,
      contrasena: _contrasena.text,
    );
    if (!correcto || !mounted) return;

    context
        .read<SesionControlador>()
        .iniciarComoAdministrador(_usuario.text.trim());
    unawaited(
      Navigator.pushNamedAndRemoveUntil(
        context,
        Rutas.panelAdministrador,
        (_) => false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Acceso profesorado')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensiones.espaciado),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Dimensiones.anchoMaximoFormulario,
              ),
              child: ListenableBuilder(
                listenable: _controlador,
                builder: (context, _) => Form(
                  key: _formulario,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CircleAvatar(
                        radius: Dimensiones.avatarGrande / 2,
                        backgroundColor: esquema.primaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 72,
                          color: esquema.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: Dimensiones.espaciado * 1.5),
                      TextFormField(
                        controller: _usuario,
                        enabled: !_controlador.comprobando,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                        decoration: const InputDecoration(
                          labelText: 'Usuario',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: _controlador.validarUsuario,
                      ),
                      const SizedBox(height: Dimensiones.espaciado),
                      TextFormField(
                        controller: _contrasena,
                        enabled: !_controlador.comprobando,
                        obscureText: !_mostrarContrasena,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => _enviar(),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _mostrarContrasena
                                ? 'Ocultar contraseña'
                                : 'Mostrar contraseña',
                            onPressed: () => setState(
                              () => _mostrarContrasena = !_mostrarContrasena,
                            ),
                            icon: Icon(
                              _mostrarContrasena
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        validator: _controlador.validarContrasena,
                      ),
                      if (_controlador.mensajeError case final mensaje?) ...[
                        const SizedBox(height: Dimensiones.espaciadoPequeno),
                        Text(
                          mensaje,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: esquema.error),
                        ),
                      ],
                      const SizedBox(height: Dimensiones.espaciado),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: _controlador.comprobando ? null : _enviar,
                          icon: _controlador.comprobando
                              ? const SizedBox.square(
                                  dimension: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Icon(Icons.arrow_forward),
                          label: const Text('Entrar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
