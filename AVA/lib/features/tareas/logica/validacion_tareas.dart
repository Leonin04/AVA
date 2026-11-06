/// Validaciones comunes de tareas y encargos (HU-03 a HU-07).
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

  /// La hora de fin debe ser posterior a la de inicio (HU-04).
  static String? horario(DateTime inicio, DateTime fin) => fin.isAfter(inicio)
      ? null
      : 'La hora de fin debe ser después del inicio.';

  /// Quita los pasos vacíos y los espacios sobrantes.
  static List<String> limpiarPasos(Iterable<String> pasos) => [
    for (final paso in pasos)
      if (paso.trim().isNotEmpty) paso.trim(),
  ];
}
