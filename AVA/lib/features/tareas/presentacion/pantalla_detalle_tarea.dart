import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/dimensiones.dart';
import '../../../core/constantes/paleta.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/tema/ajustes_interfaz.dart';
import '../../../core/utilidades/formato_fecha.dart';
import '../../../core/widgets/boton_accesible.dart';
import '../../../core/widgets/dialogo_confirmacion.dart';
import '../../../core/widgets/pantalla_estudiante.dart';
import '../../../core/widgets/pictograma.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../dominio/repositorio_tareas.dart';
import '../dominio/tarea_agenda.dart';
import '../logica/detalle_tarea_controlador.dart';
import 'widgets/dialogo_celebracion.dart';

/// Detalle de una tarea (HU-06, HU-07): a la izquierda el pictograma, la
/// hora y el estado; a la derecha la explicación, de una en una (primero
/// qué hay que hacer y después cada paso), con botones para pasar.
/// Abajo, el botón para empezar o terminar (HU-12).
class PantallaDetalleTarea extends StatefulWidget {
  const PantallaDetalleTarea({
    super.key,
    required this.estudiante,
    required this.tarea,
  });

  final Estudiante estudiante;
  final Tarea tarea;

  @override
  State<PantallaDetalleTarea> createState() => _PantallaDetalleTareaState();
}

class _PantallaDetalleTareaState extends State<PantallaDetalleTarea> {
  late final DetalleTareaControlador _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = DetalleTareaControlador(
      repositorio: context.read<RepositorioTareas>(),
      tarea: widget.tarea,
      idEstudiante: widget.estudiante.id,
      puedeGestionarTareas: widget.estudiante.puedeGestionarTareas,
    );
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _empezar() async {
    final confirmado = await mostrarDialogoConfirmacion(
      context,
      titulo: '¿Empiezas ahora?',
      mensaje: _controlador.tarea.titulo,
      pictograma: Pictogramas.empezar,
      textoConfirmar: 'Sí, empiezo',
    );
    if (confirmado) await _controlador.empezar();
  }

  Future<void> _terminar() async {
    final confirmado = await mostrarDialogoConfirmacion(
      context,
      titulo: '¿Has terminado?',
      mensaje: _controlador.tarea.titulo,
      pictograma: Pictogramas.terminar,
      textoConfirmar: 'Sí, he terminado',
    );
    if (!confirmado) return;

    final guardado = await _controlador.terminar();
    if (guardado && mounted) await mostrarCelebracion(context);
  }

  Future<void> _borrar() async {
    final confirmado = await mostrarDialogoConfirmacion(
      context,
      titulo: '¿Borrar esta tarea?',
      mensaje: _controlador.tarea.titulo,
      pictograma: Pictogramas.borrar,
      textoConfirmar: 'Sí, borrar',
    );
    if (!confirmado) return;
    final borrada = await _controlador.eliminar();
    if (borrada && mounted) Navigator.of(context).pop();
  }

  Future<void> _cambiar() async {
    final cambiada = await Navigator.pushNamed(
      context,
      Rutas.nuevaTareaEstudiante,
      arguments: _controlador.tarea,
    );
    if (cambiada is Tarea) _controlador.reemplazar(cambiada);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controlador,
      builder: (context, _) {
        final tarea = _controlador.tarea;
        final paginas = _controlador.paginas;
        final pagina = _controlador.pagina;

        return PantallaEstudiante(
          titulo: tarea.titulo,
          pictograma: tarea.pictograma,
          icono: Icons.event_rounded,
          color: tarea.tipo.color,
          textoVoz: [
            tarea.titulo,
            FormatoFecha.intervaloHablado(tarea.inicio, tarea.fin),
            if (paginas.isNotEmpty) paginas[pagina],
          ].join('. '),
          cuerpo: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: _Resumen(tarea: tarea)),
              const SizedBox(width: Dimensiones.espaciado),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _Explicacion(
                        paginas: paginas,
                        pagina: pagina,
                        color: tarea.tipo.color,
                      ),
                    ),
                    if (paginas.length > 1) ...[
                      const SizedBox(height: Dimensiones.espaciadoPequeno),
                      SizedBox(
                        height: Dimensiones.objetivoTactilMinimo + 16,
                        child: Row(
                          children: [
                            Expanded(
                              child: BotonAccesible(
                                texto: 'Anterior',
                                icono: Icons.arrow_back_rounded,
                                color: ColorPastel.lavanda,
                                disposicion: DisposicionBoton.horizontal,
                                alPulsar: pagina > 0
                                    ? () => _controlador.irAPagina(pagina - 1)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: Dimensiones.espaciadoPequeno),
                            Expanded(
                              child: BotonAccesible(
                                texto: 'Siguiente',
                                icono: Icons.arrow_forward_rounded,
                                color: ColorPastel.lavanda,
                                disposicion: DisposicionBoton.horizontal,
                                alPulsar: pagina < paginas.length - 1
                                    ? () => _controlador.irAPagina(pagina + 1)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: Dimensiones.espaciadoPequeno),
                    SizedBox(
                      height: Dimensiones.altoBotonGrande,
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: _botonPrincipal()),
                          if (_controlador.puedeModificar) ...[
                            const SizedBox(width: Dimensiones.espaciadoPequeno),
                            Expanded(
                              child: BotonAccesible(
                                texto: 'Cambiar',
                                pictograma: Pictogramas.lapiz,
                                icono: Icons.edit_rounded,
                                color: ColorPastel.amarillo,
                                disposicion: DisposicionBoton.horizontal,
                                alPulsar: _cambiar,
                              ),
                            ),
                            const SizedBox(width: Dimensiones.espaciadoPequeno),
                            Expanded(
                              child: BotonAccesible(
                                texto: 'Borrar',
                                pictograma: Pictogramas.borrar,
                                icono: Icons.delete_rounded,
                                color: ColorPastel.rosa,
                                disposicion: DisposicionBoton.horizontal,
                                alPulsar: _borrar,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _botonPrincipal() {
    final ocupado = _controlador.guardando;
    if (_controlador.puedeEmpezar) {
      return BotonAccesible(
        texto: 'Empezar',
        pictograma: Pictogramas.empezar,
        icono: Icons.play_arrow_rounded,
        color: ColorPastel.cielo,
        disposicion: DisposicionBoton.horizontal,
        alPulsar: ocupado ? null : _empezar,
      );
    }
    if (_controlador.puedeTerminar) {
      return BotonAccesible(
        texto: 'He terminado',
        pictograma: Pictogramas.terminar,
        icono: Icons.check_rounded,
        color: ColorPastel.menta,
        disposicion: DisposicionBoton.horizontal,
        alPulsar: ocupado ? null : _terminar,
      );
    }
    return const BotonAccesible(
      texto: 'Tarea terminada',
      pictograma: Pictogramas.exito,
      icono: Icons.check_circle_rounded,
      color: ColorPastel.menta,
      disposicion: DisposicionBoton.horizontal,
      seleccionado: true,
      alPulsar: null,
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen({required this.tarea});

  final Tarea tarea;

  @override
  Widget build(BuildContext context) {
    final ajustes = AjustesInterfaz.of(context);
    final estilo = ajustes.estiloDe(tarea.tipo.color);
    final textos = Theme.of(context).textTheme;
    final momento = MomentoDia.de(tarea.inicio);

    return Container(
      padding: const EdgeInsets.all(Dimensiones.espaciado),
      decoration: BoxDecoration(
        color: estilo.fondo,
        borderRadius: BorderRadius.circular(Dimensiones.radioBorde),
        border: Border.all(color: estilo.borde, width: Dimensiones.grosorBorde),
      ),
      child: LayoutBuilder(
        builder: (context, restricciones) => FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: restricciones.maxWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (ajustes.mostrarPictogramas)
                  Pictograma(
                    recurso: tarea.pictograma,
                    tamano: (restricciones.maxHeight * 0.45).clamp(80, 220),
                    iconoRespaldo: Icons.event_rounded,
                    colorRespaldo: estilo.acento,
                  ),
                const SizedBox(height: Dimensiones.espaciadoPequeno),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (ajustes.mostrarPictogramas) ...[
                        Pictograma(recurso: momento.pictograma, tamano: 48),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        FormatoFecha.intervalo(tarea.inicio, tarea.fin),
                        style: textos.headlineSmall?.copyWith(
                          color: estilo.texto,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  momento.nombre,
                  style: textos.titleMedium?.copyWith(color: estilo.texto),
                ),
                const SizedBox(height: Dimensiones.espaciadoPequeno),
                Text(
                  '${tarea.tipo.nombre} · ${tarea.estado.nombre}',
                  textAlign: TextAlign.center,
                  style: textos.titleMedium?.copyWith(color: estilo.texto),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Explicacion extends StatelessWidget {
  const _Explicacion({
    required this.paginas,
    required this.pagina,
    required this.color,
  });

  final List<String> paginas;
  final int pagina;
  final ColorPastel color;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(Dimensiones.espaciado),
      decoration: BoxDecoration(
        color: esquema.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(Dimensiones.radioBorde),
        border: Border.all(color: esquema.outline, width: 2),
      ),
      child: paginas.isEmpty
          ? Center(
              child: Text(
                'Esta tarea no tiene explicación.',
                style: textos.titleLarge,
              ),
            )
          : Semantics(
              liveRegion: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paginas.length > 1
                        ? '${pagina + 1} de ${paginas.length}'
                        : 'Qué hay que hacer',
                    style: textos.titleMedium?.copyWith(
                      color: esquema.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: Dimensiones.espaciadoPequeno),
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Text(
                            paginas[pagina],
                            textAlign: TextAlign.center,
                            style: textos.headlineMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
