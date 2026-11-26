import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/dimensiones.dart';
import '../../../core/utilidades/formato_fecha.dart';
import '../../../core/widgets/pantalla_gestion.dart';
import '../../../core/widgets/vista_carga.dart';
import '../../autenticacion/dominio/cuenta.dart';
import '../../aulas/dominio/repositorio_aulas.dart';
import '../../avisos/logica/planificador_avisos.dart';
import '../../perfil/dominio/repositorio_estudiantes.dart';
import '../../tareas/dominio/repositorio_tareas.dart';
import '../../tareas/dominio/tarea_agenda.dart';
import '../logica/seguimiento_controlador.dart';

/// Seguimiento de hoy (HU-26, HU-29): el estado y el progreso de las tareas
/// de los estudiantes asignados y, arriba, las que van con retraso. El tutor
/// del centro puede confirmar que una tarea está terminada (T-124).
class PantallaSeguimiento extends StatefulWidget {
  const PantallaSeguimiento({super.key, required this.cuenta});

  final Cuenta cuenta;

  @override
  State<PantallaSeguimiento> createState() => _PantallaSeguimientoState();
}

class _PantallaSeguimientoState extends State<PantallaSeguimiento> {
  late final SeguimientoControlador _controlador;
  Timer? _actualizar;

  @override
  void initState() {
    super.initState();
    _controlador = SeguimientoControlador(
      estudiantes: context.read<RepositorioEstudiantes>(),
      aulas: context.read<RepositorioAulas>(),
      tareas: context.read<RepositorioTareas>(),
      cuenta: widget.cuenta,
    );
    unawaited(_controlador.cargar());
    // Los retrasos dependen de la hora: se revisan cada minuto.
    _actualizar = Timer.periodic(
      const Duration(minutes: 1),
      (_) => unawaited(_controlador.cargar()),
    );
  }

  @override
  void dispose() {
    _actualizar?.cancel();
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _confirmar(ProgresoAlumno alumno, Tarea tarea) async {
    final avisos = ScaffoldMessenger.of(context);
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('¿Confirmar que está terminada?'),
        content: Text(
          '«${tarea.titulo}» de ${alumno.estudiante.nombre} quedará como '
          'terminada y se guardará en su historial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmado == true) {
      final error = await _controlador.confirmarTerminada(tarea);
      avisos.showSnackBar(
        SnackBar(content: Text(error ?? 'Tarea marcada como terminada.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PantallaGestion(
      titulo: 'Seguimiento de hoy',
      acciones: [
        IconButton(
          tooltip: 'Actualizar',
          onPressed: _controlador.cargar,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      cuerpo: VistaCarga<List<ProgresoAlumno>>(
        controlador: _controlador,
        constructor: (context, alumnos) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Avisos(avisos: _controlador.avisos),
            if (alumnos.isEmpty)
              const Padding(
                padding: EdgeInsets.all(Dimensiones.espaciado),
                child: Text('No tienes alumnos asignados.'),
              ),
            for (final alumno in alumnos)
              _TarjetaAlumno(
                alumno: alumno,
                puedeConfirmar: _controlador.puedeConfirmar,
                alConfirmar: (tarea) => _confirmar(alumno, tarea),
              ),
          ],
        ),
      ),
    );
  }
}

/// Avisos de retraso (HU-29): uno por tarea y motivo.
class _Avisos extends StatefulWidget {
  const _Avisos({required this.avisos});

  /// Avisos que se ven sin desplegar, para no tapar la lista de alumnos.
  static const visibles = 5;

  final List<AvisoRetraso> avisos;

  @override
  State<_Avisos> createState() => _AvisosState();
}

class _AvisosState extends State<_Avisos> {
  bool _todos = false;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final avisos = widget.avisos;
    final mostrados = _todos ? avisos : avisos.take(_Avisos.visibles);
    final ocultos = avisos.length - mostrados.length;
    final plegable = avisos.length > _Avisos.visibles;
    return Semantics(
      liveRegion: true,
      child: Card(
        color: avisos.isEmpty
            ? esquema.surfaceContainerHighest
            : esquema.tertiaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(Dimensiones.espaciadoPequeno),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(
                  avisos.isEmpty
                      ? Icons.check_circle_rounded
                      : Icons.notification_important_rounded,
                ),
                title: Text(
                  avisos.isEmpty
                      ? 'Todo va a su hora.'
                      : avisos.length == 1
                      ? '1 tarea va con retraso'
                      : '${avisos.length} tareas van con retraso',
                ),
              ),
              for (final aviso in mostrados)
                Padding(
                  padding: const EdgeInsets.only(left: 72, bottom: 6),
                  child: Text(aviso.texto),
                ),
              if (plegable)
                Padding(
                  padding: const EdgeInsets.only(left: 60),
                  child: TextButton(
                    onPressed: () => setState(() => _todos = !_todos),
                    child: Text(
                      _todos ? 'Ver menos' : 'Ver todos ($ocultos más)',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaAlumno extends StatelessWidget {
  const _TarjetaAlumno({
    required this.alumno,
    required this.puedeConfirmar,
    required this.alConfirmar,
  });

  final ProgresoAlumno alumno;
  final bool puedeConfirmar;
  final ValueChanged<Tarea> alConfirmar;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final terminadas = alumno.contar(EstadoTarea.completada);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Dimensiones.espaciadoPequeno),
        child: ExpansionTile(
          title: Text(alumno.estudiante.nombre, style: textos.titleMedium),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${alumno.aula?.nombre ?? 'Sin aula'} · '
                '$terminadas de ${alumno.total} terminadas · '
                '${alumno.contar(EstadoTarea.enCurso)} haciendo',
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: alumno.fraccion,
                minHeight: 10,
                semanticsLabel:
                    'Progreso de hoy: $terminadas de ${alumno.total} '
                    'terminadas',
                semanticsValue: '${(alumno.fraccion * 100).round()}',
              ),
            ],
          ),
          trailing: TextButton.icon(
            onPressed: () => Navigator.pushNamed(
              context,
              Rutas.historial,
              arguments: alumno.estudiante,
            ),
            icon: const Icon(Icons.history_rounded),
            label: const Text('Historial'),
          ),
          children: [
            if (alumno.tareas.isEmpty)
              const ListTile(title: Text('Hoy no tiene tareas.')),
            for (final tarea in alumno.tareas)
              ListTile(
                leading: Icon(_icono(tarea.estado)),
                title: Text(tarea.titulo),
                subtitle: Text(
                  '${FormatoFecha.intervalo(tarea.inicio, tarea.fin)} · '
                  '${tarea.estado.nombre}',
                ),
                trailing:
                    puedeConfirmar && tarea.estado != EstadoTarea.completada
                    ? OutlinedButton(
                        onPressed: () => alConfirmar(tarea),
                        child: const Text('Marcar terminada'),
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  static IconData _icono(EstadoTarea estado) => switch (estado) {
    EstadoTarea.pendiente => Icons.radio_button_unchecked_rounded,
    EstadoTarea.enCurso => Icons.timelapse_rounded,
    EstadoTarea.completada => Icons.check_circle_rounded,
  };
}
