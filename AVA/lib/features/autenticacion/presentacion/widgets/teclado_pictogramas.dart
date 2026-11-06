import 'package:flutter/material.dart';

import '../../../../core/constantes/dimensiones.dart';
import '../../dominio/pictograma_clave.dart';
import '../../logica/login_estudiante_controlador.dart';
import 'icono_pictograma.dart';

/// Login con pictogramas: arriba los huecos de la clave (de 3 a 6) y debajo
/// los pictogramas que se pueden pulsar.
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controlador,
      builder: (context, _) {
        final seleccion = controlador.seleccion;
        final bloqueado = controlador.comprobando;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: Dimensiones.espaciadoPequeno,
              runSpacing: Dimensiones.espaciadoPequeno,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < controlador.longitudClave; i++)
                  _Hueco(
                    posicion: i + 1,
                    pictograma: i < seleccion.length ? seleccion[i] : null,
                  ),
              ],
            ),
            if (controlador.mensajeError case final mensaje?) ...[
              const SizedBox(height: Dimensiones.espaciado),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
            const SizedBox(height: Dimensiones.espaciado * 1.5),
            Wrap(
              spacing: Dimensiones.espaciado,
              runSpacing: Dimensiones.espaciado,
              alignment: WrapAlignment.center,
              children: [
                for (final pictograma in PictogramaClave.values)
                  _BotonPictograma(
                    pictograma: pictograma,
                    alPulsar: bloqueado ? null : () => _pulsar(pictograma),
                  ),
              ],
            ),
            const SizedBox(height: Dimensiones.espaciado),
            OutlinedButton.icon(
              onPressed: bloqueado || seleccion.isEmpty
                  ? null
                  : controlador.borrarUltimoPictograma,
              icon: const Icon(Icons.backspace_outlined),
              label: const Text('Borrar'),
            ),
          ],
        );
      },
    );
  }
}

class _Hueco extends StatelessWidget {
  const _Hueco({required this.posicion, required this.pictograma});

  final int posicion;
  final PictogramaClave? pictograma;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final elegido = pictograma;

    return Semantics(
      label: 'Hueco $posicion: ${elegido?.nombre ?? 'vacío'}',
      excludeSemantics: true,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: esquema.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(Dimensiones.radioBorde),
          border: Border.all(color: esquema.outline, width: 2),
        ),
        child: elegido == null
            ? null
            : Center(child: IconoPictograma(pictograma: elegido)),
      ),
    );
  }
}

class _BotonPictograma extends StatelessWidget {
  const _BotonPictograma({required this.pictograma, required this.alPulsar});

  final PictogramaClave pictograma;
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: alPulsar != null,
      label: pictograma.nombre,
      excludeSemantics: true,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(Dimensiones.radioBorde),
        child: InkWell(
          onTap: alPulsar,
          borderRadius: BorderRadius.circular(Dimensiones.radioBorde),
          child: SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.all(Dimensiones.espaciadoPequeno),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconoPictograma(pictograma: pictograma, tamano: 64),
                  const SizedBox(height: 4),
                  Text(
                    pictograma.nombre,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
