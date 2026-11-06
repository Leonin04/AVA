import 'package:flutter/material.dart';

import '../../../../core/constantes/dimensiones.dart';
import '../../../../core/utilidades/controlador_carga.dart';
import '../../../../core/widgets/pantalla_gestion.dart';
import '../../../autenticacion/dominio/clave_acceso.dart';
import '../../../autenticacion/presentacion/widgets/editor_clave.dart';
import '../../logica/ficha_estudiante_controlador.dart';

/// Método de acceso del alumno y su clave (HU-08, RF-03).
class PestanaAcceso extends StatefulWidget {
  const PestanaAcceso({super.key, required this.controlador});

  final FichaEstudianteControlador controlador;

  @override
  State<PestanaAcceso> createState() => _PestanaAccesoState();
}

class _PestanaAccesoState extends State<PestanaAcceso> {
  ClaveAcceso? _clave;
  bool _guardando = false;

  Future<void> _guardar() async {
    final clave = _clave;
    final avisos = ScaffoldMessenger.of(context);
    if (clave == null) {
      avisos.showSnackBar(
        const SnackBar(content: Text('La clave todavía no está completa.')),
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      await widget.controlador.guardarAcceso(clave);
      avisos.showSnackBar(const SnackBar(content: Text('Acceso guardado.')));
    } on ErrorConMensaje catch (error) {
      avisos.showSnackBar(SnackBar(content: Text(error.mensaje)));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final estudiante = widget.controlador.datos!;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: Dimensiones.espaciado * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TituloSeccion(
            'Método actual: ${estudiante.metodoAcceso.nombre}',
            descripcion:
                'Elige el método que mejor se adapta al alumno y '
                'escribe o toca su clave nueva.',
          ),
          EditorClave(
            metodoInicial: estudiante.metodoAcceso,
            alCambiar: (clave) => _clave = clave,
          ),
          const SizedBox(height: Dimensiones.espaciado),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Guardar acceso'),
            ),
          ),
        ],
      ),
    );
  }
}
