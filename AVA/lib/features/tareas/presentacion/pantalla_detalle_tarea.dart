import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constantes/dimensiones.dart';
import '../../../core/utilidades/formato_fecha.dart';
import '../../../core/widgets/boton_grande.dart';
import '../../../core/widgets/dialogo_confirmacion.dart';
import '../dominio/repositorio_tareas.dart';
import '../dominio/tarea.dart';
import '../logica/detalle_tarea_controlador.dart';
import 'widgets/etiqueta_estado_tarea.dart';

/// Detalle de una tarea: título, horario, descripción y pasos (HU-05 y
/// HU-06). Desde aquí el estudiante marca el inicio y el fin (HU-11).
class PantallaDetalleTarea extends StatefulWidget {
  const PantallaDetalleTarea({super.key, required this.tarea});

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
      titulo: '¿Empezar la tarea?',
      mensaje: _controlador.tarea.titulo,
      textoConfirmar: 'Sí, empezar',
    );
    if (confirmado) await _controlador.empezar();
  }

  Future<void> _terminar() async {
    final confirmado = await mostrarDialogoConfirmacion(
      context,
      titulo: '¿Has terminado la tarea?',
      mensaje: _controlador.tarea.titulo,
      textoConfirmar: 'Sí, he terminado',
    );
    if (!confirmado) return;

    final guardado = await _controlador.terminar();
    if (!guardado || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Muy bien! Has terminado la tarea.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarea')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controlador,
          builder: (context, _) {
            final tarea = _controlador.tarea;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensiones.espaciado),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: Dimensiones.anchoMaximoContenido,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CajaTitulo(titulo: tarea.titulo),
                      const SizedBox(height: Dimensiones.espaciado),
                      _InformacionTarea(tarea: tarea),
                      const SizedBox(height: Dimensiones.espaciado),
                      if (_controlador.mensajeError case final mensaje?) ...[
                        Text(
                          mensaje,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: Dimensiones.espaciadoPequeno),
                      ],
                      _botonAccion(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _botonAccion() {
    final ocupado = _controlador.guardando;

    if (_controlador.puedeEmpezar) {
      return BotonGrande(
        texto: 'Empezar',
        icono: Icons.play_arrow,
        alPulsar: ocupado ? null : _empezar,
      );
    }
    if (_controlador.puedeTerminar) {
      return BotonGrande(
        texto: 'He terminado',
        icono: Icons.check,
        alPulsar: ocupado ? null : _terminar,
      );
    }
    return const Center(
      child: EtiquetaEstadoTarea(estado: EstadoTarea.completada),
    );
  }
}

class _CajaTitulo extends StatelessWidget {
  const _CajaTitulo({required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Semantics(
      header: true,
      child: Container(
        padding: const EdgeInsets.all(Dimensiones.espaciado),
        decoration: BoxDecoration(
          color: esquema.primaryContainer,
          borderRadius: BorderRadius.circular(Dimensiones.radioBorde),
        ),
        child: Text(
          titulo,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: esquema.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _InformacionTarea extends StatelessWidget {
  const _InformacionTarea({required this.tarea});

  final Tarea tarea;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Dimensiones.espaciado),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Dato(
              icono: Icons.schedule,
              texto: '${FormatoFecha.diaCompleto(tarea.inicio)}\n'
                  '${FormatoFecha.intervalo(tarea.inicio, tarea.fin)}',
            ),
            if (tarea.tipo == TipoTarea.encargoCentro)
              const _Dato(icono: Icons.school, texto: 'Encargo del centro'),
            const SizedBox(height: Dimensiones.espaciadoPequeno),
            EtiquetaEstadoTarea(estado: tarea.estado),
            if (tarea.descripcion.isNotEmpty) ...[
              const SizedBox(height: Dimensiones.espaciado),
              Text('Qué hay que hacer', style: textos.titleLarge),
              const SizedBox(height: 8),
              Text(tarea.descripcion, style: textos.titleMedium),
            ],
            if (tarea.pasos.isNotEmpty) ...[
              const SizedBox(height: Dimensiones.espaciado),
              Text('Pasos', style: textos.titleLarge),
              const SizedBox(height: 8),
              for (var i = 0; i < tarea.pasos.length; i++)
                _Paso(numero: i + 1, texto: tarea.pasos[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: Dimensiones.espaciadoPequeno),
          Expanded(
            child: Text(texto, style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}

class _Paso extends StatelessWidget {
  const _Paso({required this.numero, required this.texto});

  final int numero;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensiones.espaciadoPequeno),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: esquema.primary,
            foregroundColor: esquema.onPrimary,
            child: Text('$numero'),
          ),
          const SizedBox(width: Dimensiones.espaciadoPequeno),
          Expanded(
            child: Text(texto, style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}
