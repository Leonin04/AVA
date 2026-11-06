import 'package:flutter/material.dart';

import '../../../../core/constantes/dimensiones.dart';
import '../../logica/login_estudiante_controlador.dart';

/// Login con contraseña: un único campo y una flecha para entrar. También
/// se puede entrar pulsando Intro.
class FormularioContrasenaEstudiante extends StatefulWidget {
  const FormularioContrasenaEstudiante({
    super.key,
    required this.controlador,
    required this.alAcceder,
  });

  final LoginEstudianteControlador controlador;
  final VoidCallback alAcceder;

  @override
  State<FormularioContrasenaEstudiante> createState() =>
      _FormularioContrasenaEstudianteState();
}

class _FormularioContrasenaEstudianteState
    extends State<FormularioContrasenaEstudiante> {
  final _contrasena = TextEditingController();

  @override
  void dispose() {
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final correcto =
        await widget.controlador.comprobarContrasena(_contrasena.text);
    if (correcto) {
      widget.alAcceder();
    } else {
      _contrasena.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controlador,
      builder: (context, _) {
        final comprobando = widget.controlador.comprobando;

        return ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Dimensiones.anchoMaximoFormulario,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _contrasena,
                  autofocus: true,
                  obscureText: true,
                  enabled: !comprobando,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _enviar(),
                  style: Theme.of(context).textTheme.headlineSmall,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    errorText: widget.controlador.mensajeError,
                  ),
                ),
              ),
              const SizedBox(width: Dimensiones.espaciadoPequeno),
              IconButton.filled(
                tooltip: 'Entrar',
                onPressed: comprobando ? null : _enviar,
                icon: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
        );
      },
    );
  }
}
