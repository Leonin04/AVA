import 'package:flutter/material.dart';

import '../../../../core/constantes/dimensiones.dart';
import '../../../../core/constantes/paleta.dart';
import '../../../../core/constantes/pictogramas.dart';
import '../../../../core/widgets/boton_accesible.dart';
import '../../../../core/widgets/cuadricula_ajustada.dart';
import '../../dominio/pictograma_clave.dart';
import '../../logica/login_estudiante_controlador.dart';

/// Los seis pictogramas de la clave, cada uno con su color, y el botón
/// «Borrar».
class TecladoPictogramas extends StatelessWidget {
  const TecladoPictogramas({
    super.key,
    required this.controlador,
    required this.alAcceder,
  });

  final LoginEstudianteControlador controlador;
  final VoidCallback alAcceder;

  Future<void> _pulsar(PictogramaClave pictograma) async {
    if (await controlador.anadirPictograma(pictograma)) alAcceder();
  }

  Future<void> _confirmar() async {
    if (await controlador.confirmarPictogramas()) alAcceder();
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
              child: CuadriculaAjustada<PictogramaClave>(
                elementos: PictogramaClave.values,
                maxColumnas: 3,
                anchoMinimoCelda: 150,
                altoMinimoCelda: 140,
                constructor: (context, pictograma) => BotonAccesible(
                  texto: pictograma.nombre,
                  pictograma: pictograma.pictograma,
                  icono: Icons.image_rounded,
                  color: pictograma.color,
                  alPulsar: bloqueado ? null : () => _pulsar(pictograma),
                ),
              ),
            ),
            const SizedBox(height: Dimensiones.espaciado),
            SizedBox(
              height: Dimensiones.altoBarraNavegacion,
              child: Row(
                children: [
                  Expanded(
                    child: BotonAccesible(
                      texto: 'Borrar el último',
                      pictograma: Pictogramas.borrar,
                      icono: Icons.backspace_rounded,
                      color: ColorPastel.rosa,
                      disposicion: DisposicionBoton.horizontal,
                      alPulsar: bloqueado || controlador.pictogramas.isEmpty
                          ? null
                          : controlador.borrarUltimo,
                    ),
                  ),
                  if (controlador.necesitaConfirmar) ...[
                    const SizedBox(width: Dimensiones.espaciado),
                    Expanded(
                      child: BotonAccesible(
                        texto: 'Entrar',
                        pictograma: Pictogramas.entrar,
                        icono: Icons.login_rounded,
                        color: ColorPastel.menta,
                        disposicion: DisposicionBoton.horizontal,
                        alPulsar: controlador.puedeConfirmar
                            ? _confirmar
                            : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
