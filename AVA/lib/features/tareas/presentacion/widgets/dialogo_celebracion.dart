import 'package:flutter/material.dart';

import '../../../../core/constantes/dimensiones.dart';
import '../../../../core/constantes/paleta.dart';
import '../../../../core/constantes/pictogramas.dart';
import '../../../../core/tema/ajustes_interfaz.dart';
import '../../../../core/widgets/boton_accesible.dart';
import '../../../../core/widgets/pictograma.dart';

/// Refuerzo positivo al terminar una tarea (persona Álex): un
/// mensaje tranquilo con pictograma y, si la voz está activada, dicho en
/// voz alta. Sin sonidos bruscos ni animaciones (RNF-11).
Future<void> mostrarCelebracion(BuildContext context) {
  const mensaje = '¡Muy bien! Has terminado la tarea.';
  final ajustes = AjustesInterfaz.of(context);
  if (ajustes.leerEnVoz) ajustes.voz.decir(mensaje);

  return showDialog<void>(
    context: context,
    builder: (contexto) => Dialog(
      insetPadding: const EdgeInsets.all(48),
      child: Padding(
        padding: const EdgeInsets.all(Dimensiones.espaciado * 1.5),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Pictograma(
                recurso: Pictogramas.exito,
                tamano: 200,
                iconoRespaldo: Icons.celebration_rounded,
              ),
              const SizedBox(height: Dimensiones.espaciado),
              Semantics(
                liveRegion: true,
                child: Text(
                  '¡Muy bien!\nHas terminado la tarea.',
                  textAlign: TextAlign.center,
                  style: Theme.of(contexto).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: Dimensiones.espaciado * 1.5),
              SizedBox(
                height: Dimensiones.altoBotonGrande,
                width: 320,
                child: BotonAccesible(
                  texto: 'Seguir',
                  icono: Icons.check_rounded,
                  pictograma: Pictogramas.contento,
                  color: ColorPastel.menta,
                  disposicion: DisposicionBoton.horizontal,
                  autofoco: true,
                  alPulsar: () => Navigator.of(contexto).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
