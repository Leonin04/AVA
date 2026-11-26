import '../dominio/tarea_agenda.dart';

/// Validaciones comunes de tareas y encargos (HU-04 a HU-08, HU-14).
abstract final class ValidacionTareas {
  static const longitudMaximaTitulo = 40;

  static String? titulo(String? valor) {
    final titulo = valor?.trim() ?? '';
    if (titulo.isEmpty) return 'Escribe el nombre de la tarea.';
    if (titulo.length > longitudMaximaTitulo) {
      return 'Usa un nombre corto, de $longitudMaximaTitulo letras como mucho.';
    }
    return null;
  }

  /// La hora de fin debe ser posterior a la de inicio (HU-05).
  static String? horario(DateTime inicio, DateTime fin) => fin.isAfter(inicio)
      ? null
      : 'La hora de fin debe ser después del inicio.';

  /// Los días de repetición van del 1 (lunes) al 7 (domingo) (HU-14).
  static String? diasSemana(Iterable<int> dias) =>
      dias.every((dia) => dia >= 1 && dia <= 7)
      ? null
      : 'Los días de la semana no son válidos.';

  /// Quita los pasos sin texto y los espacios sobrantes, conservando su
  /// imagen de apoyo.
  static List<PasoTarea> limpiarPasos(Iterable<PasoTarea> pasos) => [
    for (final paso in pasos)
      if (paso.texto.trim().isNotEmpty)
        PasoTarea(paso.texto.trim(), imagen: paso.imagen),
  ];

  /// Días sin repetir y en orden.
  static List<int> normalizarDias(Iterable<int> dias) =>
      dias.toSet().toList()..sort();
}
