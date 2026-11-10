import 'package:flutter/material.dart';

import '../../../../core/constantes/dimensiones.dart';
import '../../../../core/constantes/paleta.dart';
import '../../../../core/constantes/pictogramas.dart';
import '../../../../core/tema/ajustes_interfaz.dart';
import '../../../../core/widgets/boton_accesible.dart';
import '../../../../core/widgets/cuadricula_ajustada.dart';
import '../../logica/login_estudiante_controlador.dart';

/// Teclado numérico grande para el acceso con número (PIN), con un color
/// distinto para cada cifra y el botón «Borrar».
class TecladoNumerico extends StatelessWidget {
  const TecladoNumerico({
    super.key,
    required this.controlador,
    required this.alAcceder,
  });

  static const _cifras = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0];

  final LoginEstudianteControlador controlador;
  final VoidCallback alAcceder;

  Future<void> _pulsar(int cifra) async {
    if (await controlador.anadirDigito(cifra)) alAcceder();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controlador,
      builder: (context, _) {
        final bloqueado = controlador.comprobando;

        return Column(
          children: [
            Expanded(
              child: CuadriculaAjustada<int>(
                elementos: _cifras,
                maxColumnas: 5,
                anchoMinimoCelda: 96,
                altoMinimoCelda: 96,
                espaciado: Dimensiones.espaciadoPequeno,
                constructor: (context, cifra) => BotonAccesible(
                  texto: '$cifra',
                  ocultarTexto: true,
                  color: ColorPastel.paraIndice(cifra),
                  imagen: (lado) => Text(
                    '$cifra',
                    style: TextStyle(
                      fontSize: lado * 0.9,
                      fontWeight: FontWeight.w700,
                      color: AjustesInterfaz.of(
                        context,
                      ).estiloDe(ColorPastel.paraIndice(cifra)).texto,
                    ),
                  ),
                  alPulsar: bloqueado ? null : () => _pulsar(cifra),
                ),
              ),
            ),
            const SizedBox(height: Dimensiones.espaciado),
            SizedBox(
              height: Dimensiones.altoBarraNavegacion,
              child: BotonAccesible(
                texto: 'Borrar el último',
                pictograma: Pictogramas.borrar,
                icono: Icons.backspace_rounded,
                color: ColorPastel.rosa,
                disposicion: DisposicionBoton.horizontal,
                alPulsar: bloqueado || controlador.digitos.isEmpty
                    ? null
                    : controlador.borrarUltimo,
              ),
            ),
          ],
        );
      },
    );
  }
}
