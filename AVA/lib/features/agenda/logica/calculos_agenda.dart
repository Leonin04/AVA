import '../../tareas/dominio/tarea_agenda.dart';

/// Funciones puras para organizar las tareas en la agenda.
///
/// No guardan estado, así que se pueden probar fácilmente con pruebas
/// unitarias.
abstract final class CalculosAgenda {
  static const int diasPorSemana = 7;

  static DateTime soloFecha(DateTime fecha) =>
      DateTime(fecha.year, fecha.month, fecha.day);

  static bool esMismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Lunes de la semana a la que pertenece [fecha].
  static DateTime inicioDeSemana(DateTime fecha) => DateTime(
    fecha.year,
    fecha.month,
    fecha.day - (fecha.weekday - DateTime.monday),
  );

  /// Los siete días (de lunes a domingo) de la semana de [fecha].
  static List<DateTime> diasDeSemana(DateTime fecha) {
    final lunes = inicioDeSemana(fecha);
    return List.generate(
      diasPorSemana,
      (i) => DateTime(lunes.year, lunes.month, lunes.day + i),
    );
  }

  static List<Tarea> ordenarPorHora(Iterable<Tarea> tareas) =>
      tareas.toList()..sort((a, b) => a.inicio.compareTo(b.inicio));

  static List<Tarea> tareasDelDia(Iterable<Tarea> tareas, DateTime dia) =>
      ordenarPorHora(tareas.where((tarea) => esMismoDia(tarea.inicio, dia)));

  /// Tarea que el estudiante está haciendo ahora.
  ///
  /// Si el estudiante ha marcado una tarea como empezada, esa tiene prioridad;
  /// si no, se toma la tarea pendiente cuyo horario incluye [ahora].
  static Tarea? tareaActual(Iterable<Tarea> tareas, DateTime ahora) {
    final ordenadas = ordenarPorHora(tareas);
    return ordenadas
            .where((tarea) => tarea.estado == EstadoTarea.enCurso)
            .firstOrNull ??
        ordenadas
            .where(
              (tarea) =>
                  tarea.estado == EstadoTarea.pendiente &&
                  tarea.contiene(ahora),
            )
            .firstOrNull;
  }

  /// Siguiente tarea pendiente después de la actual (HU-10).
  ///
  /// Se ignoran las tareas terminadas y las que ya han pasado. Devuelve
  /// `null` si no queda ninguna actividad programada.
  static Tarea? siguienteTarea(Iterable<Tarea> tareas, DateTime ahora) {
    final actual = tareaActual(tareas, ahora);
    return ordenarPorHora(tareas)
        .where(
          (tarea) =>
              tarea.id != actual?.id &&
              tarea.estado == EstadoTarea.pendiente &&
              tarea.fin.isAfter(ahora),
        )
        .firstOrNull;
  }
}
