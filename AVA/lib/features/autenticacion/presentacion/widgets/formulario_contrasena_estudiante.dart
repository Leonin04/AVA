import 'package:flutter/material.dart';

import '../../../../core/constantes/dimensiones.dart';
import '../../../../core/constantes/paleta.dart';
import '../../../../core/constantes/pictogramas.dart';
import '../../../../core/widgets/boton_accesible.dart';
import '../../logica/login_estudiante_controlador.dart';

/// Login con contraseña: un único campo grande y el botón «Entrar». También
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
  bool _visible = false;

  @override
  void dispose() {
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final correcto = await widget.controlador.comprobarContrasena(
      _contrasena.text,
    );
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

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: Dimensiones.anchoMaximoFormulario,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _contrasena,
                  autofocus: true,
                  obscureText: !_visible,
                  enabled: !comprobando,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _enviar(),
                  style: Theme.of(context).textTheme.headlineSmall,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_rounded, size: 32),
                    suffixIcon: IconButton(
                      tooltip: _visible
                          ? 'Ocultar contraseña'
                          : 'Ver contraseña',
                      onPressed: () => setState(() => _visible = !_visible),
                      icon: Icon(
                        _visible
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Dimensiones.espaciado * 1.5),
                SizedBox(
                  height: Dimensiones.altoBotonGrande,
                  child: BotonAccesible(
                    texto: 'Entrar',
                    pictograma: Pictogramas.entrar,
                    icono: Icons.login_rounded,
                    color: ColorPastel.menta,
                    disposicion: DisposicionBoton.horizontal,
                    alPulsar: comprobando ? null : _enviar,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
