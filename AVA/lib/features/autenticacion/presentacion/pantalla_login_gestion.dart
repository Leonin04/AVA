import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/dimensiones.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/widgets/pictograma.dart';
import '../dominio/repositorio_autenticacion.dart';
import '../logica/login_gestion_controlador.dart';
import '../logica/sesion_controlador.dart';
import 'widgets/aviso_error.dart';

/// Inicio de sesión de tutores y administración (HU-18): usuario,
/// contraseña, una flecha para entrar y el enlace para recuperar la
/// contraseña.
class PantallaLoginGestion extends StatefulWidget {
  const PantallaLoginGestion({super.key});

  @override
  State<PantallaLoginGestion> createState() => _PantallaLoginGestionState();
}

class _PantallaLoginGestionState extends State<PantallaLoginGestion> {
  final _formulario = GlobalKey<FormState>();
  final _usuario = TextEditingController();
  final _contrasena = TextEditingController();
  late final LoginGestionControlador _controlador;
  bool _mostrarContrasena = false;

  @override
  void initState() {
    super.initState();
    _controlador = LoginGestionControlador(
      context.read<RepositorioAutenticacion>(),
    );
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

    final cuenta = await _controlador.iniciarSesion(
      usuario: _usuario.text,
      contrasena: _contrasena.text,
    );
    if (cuenta == null || !mounted) return;

    context.read<SesionControlador>().iniciarGestion(cuenta);
    unawaited(
      Navigator.pushNamedAndRemoveUntil(
        context,
        Rutas.panelGestion,
        (_) => false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acceso del profesorado')),
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
                builder: (context, _) => AutofillGroup(
                  child: Form(
                    key: _formulario,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Pictograma(
                          recurso: Pictogramas.maestro,
                          tamano: 140,
                          iconoRespaldo: Icons.person_rounded,
                        ),
                        const SizedBox(height: Dimensiones.espaciado),
                        TextFormField(
                          controller: _usuario,
                          enabled: !_controlador.comprobando,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Correo',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
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
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              tooltip: _mostrarContrasena
                                  ? 'Ocultar contraseña'
                                  : 'Mostrar contraseña',
                              onPressed: () => setState(
                                () => _mostrarContrasena = !_mostrarContrasena,
                              ),
                              icon: Icon(
                                _mostrarContrasena
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                              ),
                            ),
                          ),
                          validator: _controlador.validarContrasena,
                        ),
                        if (_controlador.mensajeError case final mensaje?) ...[
                          const SizedBox(height: Dimensiones.espaciado),
                          AvisoError(mensaje: mensaje),
                        ],
                        const SizedBox(height: Dimensiones.espaciado),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  Rutas.recuperarContrasena,
                                ),
                                child: const Text(
                                  '¿Has olvidado la contraseña?',
                                ),
                              ),
                            ),
                            const SizedBox(width: Dimensiones.espaciadoPequeno),
                            FilledButton.icon(
                              onPressed: _controlador.comprobando
                                  ? null
                                  : _enviar,
                              icon: _controlador.comprobando
                                  ? const SizedBox.square(
                                      dimension: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Icon(Icons.arrow_forward_rounded),
                              label: const Text('Entrar'),
                            ),
                          ],
                        ),
                      ],
                    ),
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
