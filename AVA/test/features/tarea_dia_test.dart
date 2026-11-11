import 'package:ava/features/tareas/dominio/tarea.dart';
import 'package:flutter_test/flutter_test.dart';

Tarea _t(String nombre, {List<int> dias = const [], String? fecha}) => Tarea(
  id: nombre,
  nombre: nombre,
  horaInicio: '10:00',
  horaFin: '10:30',
  diasSemana: dias,
  fecha: fecha,
  creadaPor: 'tutor',
);

void main() {
  // 9/11/2026 es lunes.
  final lunes = DateTime(2026, 11, 9);

  test('HU-10: solo salen las tareas de ese día', () {
    final todas = [
      _t('Lunes y miércoles', dias: [1, 3]),
      _t('Solo martes', dias: [2]),
      _t('Fecha concreta hoy', fecha: '2026-11-09'),
      _t('Fecha concreta otro día', fecha: '2026-11-10'),
    ];
    final hoy = [
      for (final tarea in todas)
        if (tarea.esParaDia(lunes)) tarea.nombre,
    ];
    expect(hoy, ['Lunes y miércoles', 'Fecha concreta hoy']);
  });

  test('la clave de fecha es yyyy-MM-dd', () {
    expect(Tarea.claveFecha(DateTime(2026, 1, 5)), '2026-01-05');
  });
}
