import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constantes/dimensiones.dart';
import '../../../core/constantes/paleta.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/tema/ajustes_interfaz.dart';
import '../../../core/utilidades/formato_fecha.dart';
import '../../../core/widgets/boton_accesible.dart';
import '../../../core/widgets/cuadricula_ajustada.dart';
import '../../../core/widgets/pantalla_estudiante.dart';
import '../../../core/widgets/pictograma.dart';
import '../../agenda/presentacion/widgets/boton_tarea.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../dominio/repositorio_tareas.dart';
import '../dominio/tarea_agenda.dart';
import '../logica/tarea_estudiante_controlador.dart';

/// Asistente para que el estudiante cree o cambie una tarea personal
/// (HU-04), con una sola pregunta por pantalla: qué, cuándo y confirmar.
class PantallaNuevaTareaEstudiante extends StatefulWidget {
  const PantallaNuevaTareaEstudiante({
    super.key,
    required this.estudiante,
    this.tarea,
  });

  final Estudiante estudiante;

  /// Tarea a cambiar, o `null` para crear una nueva.
  final Tarea? tarea;

  @override
  State<PantallaNuevaTareaEstudiante> createState() =>
      _PantallaNuevaTareaEstudianteState();
}

class _PantallaNuevaTareaEstudianteState
    extends State<PantallaNuevaTareaEstudiante> {
  late final TareaEstudianteControlador _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = TareaEstudianteControlador(
      repositorio: context.read<RepositorioTareas>(),
      idEstudiante: widget.estudiante.id,
      hoy: DateTime.now(),
      tareaExistente: widget.tarea,
    );
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final ajustes = AjustesInterfaz.of(context);
    try {
      final tarea = await _controlador.guardar();
      if (tarea == null || !mounted) return;
      if (ajustes.leerEnVoz) await ajustes.voz.decir('Tarea guardada.');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarea guardada en tu agenda.')),
      );
      Navigator.of(context).pop(tarea);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $error')),
      );
    }
  }

  String _pregunta(PasoAsistente paso) => switch (paso) {
    PasoAsistente.que => '¿Qué quieres hacer?',
    PasoAsistente.cuando => '¿Cuándo?',
    PasoAsistente.confirmar => '¿Está bien así?',
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controlador,
      builder: (context, _) {
        final paso = _controlador.paso;

        // «Atrás» vuelve a la pregunta anterior en lugar de salir.
        return PopScope(
          canPop: paso == PasoAsistente.que,
          onPopInvokedWithResult: (salio, _) {
            if (!salio) _controlador.volver();
          },
          child: PantallaEstudiante(
            titulo: _pregunta(paso),
            pictograma: Pictogramas.lapiz,
            icono: Icons.add_task_rounded,
            color: ColorPastel.menta,
            textoVoz: _pregunta(paso),
            cuerpo: switch (paso) {
              PasoAsistente.que => _PasoQue(controlador: _controlador),
              PasoAsistente.cuando => _PasoCuando(controlador: _controlador),
              PasoAsistente.confirmar => _PasoConfirmar(
                controlador: _controlador,
                alGuardar: _guardar,
              ),
            },
          ),
        );
      },
    );
  }
}

class _PasoQue extends StatelessWidget {
  const _PasoQue({required this.controlador});

  final TareaEstudianteControlador controlador;

  @override
  Widget build(BuildContext context) {
    return CuadriculaAjustada<ActividadPersonal>(
      elementos: ActividadPersonal.catalogo,
      maxColumnas: 4,
      anchoMinimoCelda: 200,
      altoMinimoCelda: 190,
      constructor: (context, actividad) => BotonAccesible(
        texto: actividad.nombre,
        pictograma: actividad.pictograma,
        icono: Icons.event_rounded,
        color: actividad.tipo.color,
        seleccionado: controlador.actividad?.nombre == actividad.nombre,
        alPulsar: () => controlador.elegirActividad(actividad),
      ),
    );
  }
}

class _PasoCuando extends StatelessWidget {
  const _PasoCuando({required this.controlador});

  final TareaEstudianteControlador controlador;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final momento = MomentoDia.de(controlador.inicio);
    final hoy = controlador.diasDisponibles.first;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: CuadriculaAjustada<DateTime>(
            elementos: controlador.diasDisponibles,
            maxColumnas: 4,
            anchoMinimoCelda: 130,
            altoMinimoCelda: 130,
            espaciado: Dimensiones.espaciadoPequeno,
            constructor: (context, dia) => BotonAccesible(
              texto: dia == hoy ? 'Hoy' : FormatoFecha.nombreDia(dia),
              textoSecundario: '${dia.day}',
              etiquetaSemantica: FormatoFecha.diaCompleto(dia),
              color: ColorPastel.paraIndice(dia.weekday - 1),
              seleccionado: dia == controlador.dia,
              alPulsar: () => controlador.elegirDia(dia),
            ),
          ),
        ),
        const SizedBox(width: Dimensiones.espaciado),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  label:
                      'A las ${FormatoFecha.hora(controlador.inicio)}, '
                      '${momento.nombre}, durante ${controlador.duracion} minutos',
                  excludeSemantics: true,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Pictograma(recurso: momento.pictograma, tamano: 72),
                            const SizedBox(width: 12),
                            Text(
                              FormatoFecha.hora(controlador.inicio),
                              style: textos.displaySmall,
                            ),
                          ],
                        ),
                        Text(momento.nombre, style: textos.titleLarge),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensiones.espaciadoPequeno),
              SizedBox(
                height: Dimensiones.objetivoTactilMinimo + 16,
                child: Row(
                  children: [
                    Expanded(
                      child: BotonAccesible(
                        texto: 'Antes',
                        icono: Icons.remove_rounded,
                        color: ColorPastel.lavanda,
                        disposicion: DisposicionBoton.horizontal,
                        alPulsar: controlador.puedeAdelantar
                            ? controlador.adelantarHora
                            : null,
                      ),
                    ),
                    const SizedBox(width: Dimensiones.espaciadoPequeno),
                    Expanded(
                      child: BotonAccesible(
                        texto: 'Después',
                        icono: Icons.add_rounded,
                        color: ColorPastel.lavanda,
                        disposicion: DisposicionBoton.horizontal,
                        alPulsar: controlador.puedeRetrasar
                            ? controlador.retrasarHora
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensiones.espaciadoPequeno),
              SizedBox(
                height: Dimensiones.objetivoTactilMinimo + 16,
                child: Row(
                  children: [
                    for (final (i, minutos)
                        in TareaEstudianteControlador.duraciones.indexed) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: BotonAccesible(
                          texto: minutos < 60 ? '$minutos min' : '1 hora',
                          color: ColorPastel.amarillo,
                          disposicion: DisposicionBoton.horizontal,
                          seleccionado: controlador.duracion == minutos,
                          alPulsar: () => controlador.elegirDuracion(minutos),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: Dimensiones.espaciadoPequeno),
              SizedBox(
                height: Dimensiones.altoBotonGrande,
                child: BotonAccesible(
                  texto: 'Siguiente',
                  pictograma: Pictogramas.siguiente,
                  icono: Icons.arrow_forward_rounded,
                  color: ColorPastel.menta,
                  disposicion: DisposicionBoton.horizontal,
                  alPulsar: controlador.irAConfirmar,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PasoConfirmar extends StatelessWidget {
  const _PasoConfirmar({required this.controlador, required this.alGuardar});

  final TareaEstudianteControlador controlador;
  final VoidCallback alGuardar;

  @override
  Widget build(BuildContext context) {
    final actividad = controlador.actividad!;
    final vistaPrevia = Tarea(
      id: 'vista-previa',
      idEstudiante: controlador.idEstudiante,
      titulo: actividad.nombre,
      pictograma: actividad.pictograma,
      tipo: actividad.tipo,
      inicio: controlador.inicio,
      fin: controlador.fin,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: BotonTarea(
                tarea: vistaPrevia,
                disposicion: DisposicionBoton.vertical,
                alPulsar: null,
              ),
            ),
          ),
        ),
        const SizedBox(height: Dimensiones.espaciado),
        Text(
          FormatoFecha.diaCompleto(controlador.inicio),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: Dimensiones.espaciado),
        SizedBox(
          height: Dimensiones.altoBotonGrande,
          child: Row(
            children: [
              Expanded(
                child: BotonAccesible(
                  texto: 'Cambiar algo',
                  icono: Icons.arrow_back_rounded,
                  pictograma: Pictogramas.lapiz,
                  color: ColorPastel.lavanda,
                  disposicion: DisposicionBoton.horizontal,
                  alPulsar: controlador.volver,
                ),
              ),
              const SizedBox(width: Dimensiones.espaciado),
              Expanded(
                child: BotonAccesible(
                  texto: 'Guardar',
                  icono: Icons.check_rounded,
                  pictograma: Pictogramas.exito,
                  color: ColorPastel.menta,
                  disposicion: DisposicionBoton.horizontal,
                  alPulsar: controlador.guardando ? null : alGuardar,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
