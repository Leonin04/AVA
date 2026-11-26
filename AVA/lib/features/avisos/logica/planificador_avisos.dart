import '../../tareas/dominio/tarea_agenda.dart';

/// Aviso previo a una tarea (HU-28): se muestra [antelacion] antes de que
/// empiece.
class AvisoPrevio {
  const AvisoPrevio({required this.tarea, required this.momento});

  final Tarea tarea;

  /// Cuándo hay que avisar.
  final DateTime momento;

  /// Identifica el aviso para no repetirlo (T-135).
  String get clave => 'previo:${tarea.id}:${tarea.avisoMinutos}';

  int get minutos => tarea.avisoMinutos ?? 0;

  /// Texto breve y claro para el estudiante.
  String get texto =>
      'Dentro de $minutos minutos: ${tarea.titulo}. Prepárate para empezar.';
}

/// Motivo de un aviso al tutor (HU-29).
enum TipoRetraso {
  noIniciada('No ha empezado'),
  noTerminada('No ha terminado');

  const TipoRetraso(this.descripcion);

  final String descripcion;
}

/// Aviso al tutor: una tarea no se ha empezado o no se ha terminado a
/// tiempo (HU-29).
class AvisoRetraso {
  const AvisoRetraso({
    required this.tarea,
    required this.tipo,
    required this.nombreEstudiante,
  });

  final Tarea tarea;
  final TipoRetraso tipo;
  final String nombreEstudiante;

  /// Identifica el aviso: uno por tarea, día y motivo, sin duplicados
  /// (T-135).
  String get clave => 'retraso:${tarea.id}:${tipo.name}';

  /// Texto que identifica claramente la tarea y al estudiante (T-134).
  String get texto =>
      '$nombreEstudiante · ${tipo.descripcion} «${tarea.titulo}» '
      '(${_hora(tarea.inicio)}–${_hora(tarea.fin)})';

  static String _hora(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';
}

/// Cálculo de los avisos a partir de las tareas y la hora actual. Es
/// puro: no guarda nada ni depende del reloj del sistema, así se puede
/// probar y se evita avisar dos veces de lo mismo.
abstract final class PlanificadorAvisos {
  /// Margen antes de considerar que una tarea va con retraso.
  static const margenRetraso = Duration(minutes: 10);

  /// Ventana en la que un aviso previo sigue siendo útil: si la tableta
  /// estaba apagada a la hora del aviso, no se avisa después de empezar.
  static bool _vigente(AvisoPrevio aviso, DateTime ahora) =>
      !ahora.isBefore(aviso.momento) && ahora.isBefore(aviso.tarea.inicio);

  /// Avisos previos de [tareas] (HU-28, T-129): los de las tareas con
  /// antelación configurada que todavía no han empezado.
  static List<AvisoPrevio> avisosPrevios(Iterable<Tarea> tareas) => [
    for (final tarea in tareas)
      if (tarea.avisoMinutos case final minutos?
          when minutos > 0 && tarea.estado == EstadoTarea.pendiente)
        AvisoPrevio(
          tarea: tarea,
          momento: tarea.inicio.subtract(Duration(minutes: minutos)),
        ),
  ]..sort((a, b) => a.momento.compareTo(b.momento));

  /// Avisos previos que hay que mostrar en [ahora], sin los ya mostrados
  /// ([mostrados] son sus claves).
  static List<AvisoPrevio> pendientes(
    Iterable<Tarea> tareas,
    DateTime ahora, {
    Set<String> mostrados = const {},
  }) => [
    for (final aviso in avisosPrevios(tareas))
      if (_vigente(aviso, ahora) && !mostrados.contains(aviso.clave)) aviso,
  ];

  /// Tareas con retraso en [ahora] (HU-29, T-132): pendientes pasado el
  /// inicio más el margen, o en curso pasado el fin más el margen.
  static List<AvisoRetraso> retrasos(
    Iterable<Tarea> tareas,
    DateTime ahora, {
    required String nombreEstudiante,
  }) {
    final avisos = <AvisoRetraso>[];
    for (final tarea in tareas) {
      final tipo = switch (tarea.estado) {
        EstadoTarea.pendiente
            when ahora.isAfter(tarea.inicio.add(margenRetraso)) =>
          TipoRetraso.noIniciada,
        EstadoTarea.enCurso when ahora.isAfter(tarea.fin.add(margenRetraso)) =>
          TipoRetraso.noTerminada,
        _ => null,
      };
      if (tipo != null) {
        avisos.add(
          AvisoRetraso(
            tarea: tarea,
            tipo: tipo,
            nombreEstudiante: nombreEstudiante,
          ),
        );
      }
    }
    return avisos;
  }
}
