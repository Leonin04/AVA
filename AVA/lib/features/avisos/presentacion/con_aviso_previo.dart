import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constantes/dimensiones.dart';
import '../../../core/constantes/paleta.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/tema/ajustes_interfaz.dart';
import '../../../core/widgets/boton_accesible.dart';
import '../../../core/widgets/pictograma.dart';
import '../logica/avisos_estudiante_controlador.dart';
import '../logica/planificador_avisos.dart';

/// Muestra el aviso previo de una tarea (HU-28) en una banda tranquila en
/// la parte de arriba, encima de cualquier pantalla del estudiante, con un
/// botón «Vale» para cerrarlo. No interrumpe con ventanas ni sonidos
/// bruscos (RNF-11); si la voz está activada, lo lee una vez.
class ConAvisoPrevio extends StatelessWidget {
  const ConAvisoPrevio({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final avisos = context.watch<AvisosEstudianteControlador>();
    final aviso = avisos.aviso;
    return Column(
      children: [
        if (aviso != null)
          _BandaAviso(
            key: ValueKey(aviso.clave),
            aviso: aviso,
            alCerrar: avisos.descartar,
          ),
        Expanded(child: child),
      ],
    );
  }
}

class _BandaAviso extends StatefulWidget {
  const _BandaAviso({super.key, required this.aviso, required this.alCerrar});

  final AvisoPrevio aviso;
  final VoidCallback alCerrar;

  @override
  State<_BandaAviso> createState() => _BandaAvisoState();
}

class _BandaAvisoState extends State<_BandaAviso> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ajustes = AjustesInterfaz.of(context);
    if (ajustes.leerEnVoz) ajustes.voz.decir(widget.aviso.texto);
  }

  @override
  Widget build(BuildContext context) {
    final estilo = AjustesInterfaz.of(context).estiloDe(ColorPastel.amarillo);
    return Material(
      color: estilo.fondo,
      child: SafeArea(
        bottom: false,
        child: Semantics(
          liveRegion: true,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: estilo.borde,
                  width: Dimensiones.grosorBorde,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensiones.espaciado,
              vertical: Dimensiones.espaciadoPequeno,
            ),
            child: Row(
              children: [
                Pictograma(
                  recurso: widget.aviso.tarea.pictograma ?? Pictogramas.reloj,
                  tamano: 56,
                  iconoRespaldo: Icons.alarm_rounded,
                  colorRespaldo: estilo.acento,
                ),
                const SizedBox(width: Dimensiones.espaciado),
                Expanded(
                  child: Text(
                    widget.aviso.texto,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: estilo.texto),
                  ),
                ),
                const SizedBox(width: Dimensiones.espaciado),
                SizedBox(
                  width: 160,
                  height: Dimensiones.objetivoTactilMinimo,
                  child: BotonAccesible(
                    texto: 'Vale',
                    etiquetaSemantica: 'Vale, cerrar el aviso',
                    icono: Icons.check_rounded,
                    color: ColorPastel.menta,
                    disposicion: DisposicionBoton.horizontal,
                    alPulsar: widget.alCerrar,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
