import 'package:flutter/material.dart';

import '../../../../core/constantes/dimensiones.dart';
import '../../../../core/constantes/paleta.dart';
import '../../../../core/tema/ajustes_interfaz.dart';
import '../../../../core/widgets/pictograma.dart';
import '../../logica/login_estudiante_controlador.dart';

/// Huecos de la clave (de 3 a 6): se rellenan con el pictograma o el número
/// que se va pulsando, para ver en todo momento lo que se lleva.
class HuecosClave extends StatelessWidget {
  const HuecosClave({super.key, required this.controlador});

  final LoginEstudianteControlador controlador;

  @override
  Widget build(BuildContext context) {
    final pictogramas = controlador.pictogramas;
    final digitos = controlador.digitos;
    final rellenos = pictogramas.isNotEmpty
        ? pictogramas.length
        : digitos.length;

    return Semantics(
      label: 'Llevas $rellenos de ${controlador.longitudClave}',
      excludeSemantics: true,
      child: Wrap(
        spacing: Dimensiones.espaciadoPequeno,
        runSpacing: Dimensiones.espaciadoPequeno,
        alignment: WrapAlignment.center,
        children: [
          for (var i = 0; i < controlador.longitudClave; i++)
            _Hueco(
              contenido: i < pictogramas.length
                  ? Pictograma(recurso: pictogramas[i].pictograma, tamano: 56)
                  : i < digitos.length
                  ? Text(
                      digitos[i],
                      style: Theme.of(context).textTheme.headlineMedium,
                    )
                  : null,
              color: i < pictogramas.length
                  ? pictogramas[i].color
                  : ColorPastel.cielo,
            ),
        ],
      ),
    );
  }
}

class _Hueco extends StatelessWidget {
  const _Hueco({required this.contenido, required this.color});

  final Widget? contenido;
  final ColorPastel color;

  @override
  Widget build(BuildContext context) {
    final ajustes = AjustesInterfaz.of(context);
    final estilo = ajustes.estiloDe(color);
    final esquema = Theme.of(context).colorScheme;
    final lleno = contenido != null;

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: lleno ? estilo.fondo : esquema.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(Dimensiones.radioBordePequeno),
        border: Border.all(
          color: lleno ? estilo.borde : esquema.outline,
          width: Dimensiones.grosorBorde,
        ),
      ),
      alignment: Alignment.center,
      child: contenido,
    );
  }
}
