import 'package:ava/features/agenda/logica/agenda_dia.dart';
import 'package:ava/features/tareas/dominio/tarea.dart';
import 'package:flutter_test/flutter_test.dart';

Tarea _t(String nombre, String inicio, String fin,
        {List<int> dias = const [], String? fecha}) =>
    Tarea(
      id: nombre,
      nombre: nombre,
      horaInicio: inicio,
      horaFin: fin,
      diasSemana: dias,
      fecha: fecha,
      creadaPor: 'tutor',
    );

void main() {
  // 9/11/2026 es lunes
  final lunes = DateTime(2026, 11, 9);

  test('T-81: solo salen las tareas de ese día', () {
    final todas = [
      _t('Lunes y miércoles', '10:00', '10:30', dias: [1, 3]),
      _t('Solo martes', '09:00', '09:30', dias: [2]),
      _t('Fecha concreta hoy', '12:00', '12:30', fecha: '2026-11-09'),
      _t('Fecha concreta otro día', '12:00', '12:30', fecha: '2026-11-10'),
    ];
    final hoy = tareasDelDia(todas, lunes).map((t) => t.nombre);
    expect(hoy, ['Lunes y miércoles', 'Fecha concreta hoy']);
  });

  test('T-82: se ordenan por hora de inicio y luego de fin', () {
    final todas = [
      _t('C', '12:00', '12:30', dias: [1]),
      _t('A', '08:30', '09:00', dias: [1]),
      _t('B2', '10:00', '11:00', dias: [1]),
      _t('B1', '10:00', '10:15', dias: [1]),
    ];
    final orden = tareasDelDia(todas, lunes).map((t) => t.nombre);
    expect(orden, ['A', 'B1', 'B2', 'C']);
  });

  test('Sin tareas ese día devuelve lista vacía', () {
    expect(tareasDelDia([_t('X', '10:00', '11:00', dias: [7])], lunes), isEmpty);
  });

  test('Cabecera de la agenda en español', () {
    expect(fechaLarga(lunes), 'Lunes, 9 de noviembre');
  });
}
