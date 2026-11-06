import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constantes/dimensiones.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/widgets/pictograma.dart';
import '../dominio/repositorio_autenticacion.dart';
import '../logica/recuperacion_controlador.dart';
import 'widgets/aviso_error.dart';

/// Recuperación de la contraseña de tutores y administradores (HU-17).
class PantallaRecuperarContrasena extends StatefulWidget {
  const PantallaRecuperarContrasena({super.key});

  @override
  State<PantallaRecuperarContrasena> createState() =>
      _PantallaRecuperarContrasenaState();
}

class _PantallaRecuperarContrasenaState
    extends State<PantallaRecuperarContrasena> {
  final _formulario = GlobalKey<FormState>();
  final _email = TextEditingController();
  late final RecuperacionControlador _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = RecuperacionControlador(
      context.read<RepositorioAutenticacion>(),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    await _controlador.enviar(_email.text);
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar la contraseña')),
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
                builder: (context, _) => _controlador.enviado
                    ? Column(
                        children: [
                          const Pictograma(
                            recurso: Pictogramas.correo,
                            tamano: 140,
                            iconoRespaldo: Icons.mark_email_read_rounded,
                          ),
                          const SizedBox(height: Dimensiones.espaciado),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              'Si el correo pertenece a una cuenta, '
                              'recibirás un enlace para crear una contraseña '
                              'nueva.',
                              textAlign: TextAlign.center,
                              style: textos.titleLarge,
                            ),
                          ),
                          const SizedBox(height: Dimensiones.espaciado),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Volver al acceso'),
                          ),
                        ],
                      )
                    : Form(
                        key: _formulario,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Escribe el correo de tu cuenta. Te enviaremos '
                              'un enlace para crear una contraseña nueva.',
                              style: textos.titleMedium,
                            ),
                            const SizedBox(height: Dimensiones.espaciado),
                            TextFormField(
                              controller: _email,
                              autofocus: true,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              textInputAction: TextInputAction.send,
                              onFieldSubmitted: (_) => _enviar(),
                              decoration: const InputDecoration(
                                labelText: 'Correo',
                                prefixIcon: Icon(Icons.mail_outline_rounded),
                              ),
                              validator: _controlador.validarEmail,
                            ),
                            if (_controlador.mensajeError case final m?) ...[
                              const SizedBox(height: Dimensiones.espaciado),
                              AvisoError(mensaje: m),
                            ],
                            const SizedBox(height: Dimensiones.espaciado),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                onPressed: _controlador.enviando
                                    ? null
                                    : _enviar,
                                icon: const Icon(Icons.send_rounded),
                                label: const Text('Enviar enlace'),
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
