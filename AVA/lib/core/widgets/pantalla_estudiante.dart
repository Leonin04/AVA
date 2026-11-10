import 'package:flutter/material.dart';

import '../constantes/dimensiones.dart';
import '../constantes/paleta.dart';
import '../constantes/pictogramas.dart';
import '../modelos/recurso_visual.dart';
import '../tema/ajustes_interfaz.dart';
import 'boton_accesible.dart';
import 'pictograma.dart';

/// Estructura común de todas las pantallas del estudiante.
///
/// - Ocupa exactamente la pantalla: el contenido se adapta al espacio y
///   nunca hay que desplazarse.
/// - La cabecera (pictograma, título y, si está activado, el botón
///   «Escuchar») y la barra de
///   navegación (Atrás, Inicio y Ayuda) están siempre en el mismo sitio
///   (WCAG 3.2.3 navegación consistente, RNF-11). La barra puede ir arriba
///   o abajo según las preferencias (RNF-05).
/// - El botón «Ayuda» está siempre disponible (personas Álex y Diego).
class PantallaEstudiante extends StatelessWidget {
  const PantallaEstudiante({
    super.key,
    required this.titulo,
    required this.cuerpo,
    this.pictograma,
    this.icono,
    this.color = ColorPastel.cielo,
    this.textoVoz,
  });

  final String titulo;
  final Widget cuerpo;
  final RecursoVisual? pictograma;
  final IconData? icono;
  final ColorPastel color;

  /// Texto que se lee al pulsar «Escuchar». Si es `null`, se lee el título.
  final String? textoVoz;

  @override
  Widget build(BuildContext context) {
    final ajustes = AjustesInterfaz.of(context);
    final barra = _BarraNavegacion(
      puedeVolver: Navigator.of(context).canPop(),
      esInicio: ModalRoute.of(context)?.isFirst ?? true,
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Dimensiones.espaciado),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (ajustes.menuArriba) ...[
                barra,
                const SizedBox(height: Dimensiones.espaciado),
              ],
              _Cabecera(
                titulo: titulo,
                pictograma: pictograma,
                icono: icono,
                color: color,
                textoVoz: textoVoz ?? titulo,
              ),
              const SizedBox(height: Dimensiones.espaciado),
              Expanded(child: cuerpo),
              if (!ajustes.menuArriba) ...[
                const SizedBox(height: Dimensiones.espaciado),
                barra,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({
    required this.titulo,
    required this.pictograma,
    required this.icono,
    required this.color,
    required this.textoVoz,
  });

  final String titulo;
  final RecursoVisual? pictograma;
  final IconData? icono;
  final ColorPastel color;
  final String textoVoz;

  @override
  Widget build(BuildContext context) {
    final ajustes = AjustesInterfaz.of(context);
    final estilo = ajustes.estiloDe(color);

    return SizedBox(
      height: Dimensiones.altoCabecera,
      child: Row(
        children: [
          if (ajustes.mostrarPictogramas &&
              (pictograma != null || icono != null)) ...[
            Container(
              width: Dimensiones.altoCabecera,
              height: Dimensiones.altoCabecera,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: estilo.fondo,
                shape: BoxShape.circle,
                border: Border.all(
                  color: estilo.borde,
                  width: Dimensiones.grosorBorde,
                ),
              ),
              child: Pictograma(
                recurso: pictograma,
                tamano: Dimensiones.altoCabecera - 26,
                iconoRespaldo: icono ?? Icons.image_outlined,
                colorRespaldo: estilo.acento,
              ),
            ),
            const SizedBox(width: Dimensiones.espaciado),
          ],
          Expanded(
            child: Semantics(
              header: true,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  titulo,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
          ),
          if (ajustes.botonEscuchar) ...[
            const SizedBox(width: Dimensiones.espaciado),
            SizedBox(
              width: 220,
              child: BotonAccesible(
                texto: 'Escuchar',
                etiquetaSemantica: 'Escuchar en voz alta',
                pictograma: Pictogramas.escuchar,
                icono: Icons.volume_up_rounded,
                color: ColorPastel.amarillo,
                disposicion: DisposicionBoton.horizontal,
                alPulsar: () => escuchar(context, textoVoz),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Lee [texto] en voz alta. Si el dispositivo no tiene ninguna voz
/// instalada, lo avisa en pantalla en lugar de no hacer nada.
Future<void> escuchar(BuildContext context, String texto) async {
  final voz = AjustesInterfaz.of(context).voz;
  final avisos = ScaffoldMessenger.maybeOf(context);
  final hablando = await voz.decir(texto);
  if (!hablando) {
    avisos?.showSnackBar(
      const SnackBar(
        content: Text(
          'Este dispositivo no tiene voz instalada. '
          'Actívala en los ajustes de accesibilidad del sistema.',
        ),
      ),
    );
  }
}

class _BarraNavegacion extends StatelessWidget {
  const _BarraNavegacion({required this.puedeVolver, required this.esInicio});

  final bool puedeVolver;
  final bool esInicio;

  @override
  Widget build(BuildContext context) {
    // Los tres huecos se mantienen aunque un botón no aparezca, para que
    // los demás no cambien de sitio.
    return SizedBox(
      height: Dimensiones.altoBarraNavegacion,
      child: Row(
        children: [
          Expanded(
            child: puedeVolver
                ? BotonAccesible(
                    texto: 'Atrás',
                    icono: Icons.arrow_back_rounded,
                    color: ColorPastel.lavanda,
                    disposicion: DisposicionBoton.horizontal,
                    alPulsar: () => Navigator.of(context).maybePop(),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: Dimensiones.espaciado),
          Expanded(
            child: esInicio
                ? const SizedBox.shrink()
                : BotonAccesible(
                    texto: 'Inicio',
                    icono: Icons.home_rounded,
                    color: ColorPastel.menta,
                    disposicion: DisposicionBoton.horizontal,
                    alPulsar: () =>
                        Navigator.of(context).popUntil((ruta) => ruta.isFirst),
                  ),
          ),
          const SizedBox(width: Dimensiones.espaciado),
          Expanded(
            child: BotonAccesible(
              texto: 'Ayuda',
              etiquetaSemantica: 'Pedir ayuda',
              pictograma: Pictogramas.ayuda,
              icono: Icons.pan_tool_rounded,
              color: ColorPastel.rosa,
              disposicion: DisposicionBoton.horizontal,
              alPulsar: () => mostrarAyuda(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pantalla de ayuda: indica con pictograma, texto y voz que avise a su
/// profesor. No hace nada que no se pueda deshacer.
Future<void> mostrarAyuda(BuildContext context) {
  const mensaje = 'Levanta la mano. Tu profesor viene a ayudarte.';
  final ajustes = AjustesInterfaz.of(context);
  if (ajustes.leerEnVoz) ajustes.voz.decir(mensaje);

  return showDialog<void>(
    context: context,
    builder: (contexto) => Dialog(
      insetPadding: const EdgeInsets.all(48),
      child: Padding(
        padding: const EdgeInsets.all(Dimensiones.espaciado * 1.5),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Pictograma(
                recurso: Pictogramas.ayuda,
                tamano: 180,
                iconoRespaldo: Icons.pan_tool_rounded,
              ),
              const SizedBox(height: Dimensiones.espaciado),
              Text(
                'Levanta la mano.\nTu profesor viene a ayudarte.',
                textAlign: TextAlign.center,
                style: Theme.of(contexto).textTheme.headlineSmall,
              ),
              const SizedBox(height: Dimensiones.espaciado * 1.5),
              SizedBox(
                height: Dimensiones.altoBotonGrande,
                width: 320,
                child: BotonAccesible(
                  texto: 'Volver',
                  icono: Icons.check_rounded,
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
