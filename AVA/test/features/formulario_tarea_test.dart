import 'package:ava/features/tareas/dominio/tarea.dart';
import 'package:ava/features/tareas/logica/formulario_tarea.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

FormularioTarea _valido() {
  final f = FormularioTarea(creadaPor: 'tutor1', estudianteInicial: 'est1')
    ..nombre = 'Preparar la mochila'
    ..cambiarHoraInicio(const TimeOfDay(hour: 20, minute: 0))
    ..cambiarHoraFin(const TimeOfDay(hour: 20, minute: 15))
    ..alternarDia(1);
  return f;
}

void main() {
  test('T-78: un formulario completo no tiene errores', () {
    expect(_valido().validar(), isEmpty);
  });

  test('T-78: avisa de nombre, horas, días y estudiantes vacíos', () {
    final f = FormularioTarea(creadaPor: 'tutor1');
    expect(f.validar().length, 5);
  });

  test('T-78: la hora de fin debe ser posterior a la de inicio', () {
    final f = _valido()..cambiarHoraFin(const TimeOfDay(hour: 19, minute: 0));
    expect(f.validar(), contains(startsWith('La hora de fin')));
  });

  test('T-78: no deja guardar pasos vacíos', () {
    final f = _valido()..anadirPaso();
    expect(f.validar(), contains(startsWith('Hay pasos vacíos')));
  });

  test('T-74 a T-77: añadir, editar, eliminar y reordenar pasos', () {
    final f = _valido()
      ..anadirPaso()
      ..anadirPaso()
      ..anadirPaso();
    f.editarPaso(0, 'Uno');
    f.editarPaso(1, 'Dos');
    f.editarPaso(2, 'Tres');
    f.reordenarPaso(2, 0); // "Tres" pasa al principio
    expect(f.pasos.map((p) => p.texto), ['Tres', 'Uno', 'Dos']);
    f.eliminarPaso(1);
    expect(f.aPasos().map((p) => '${p.orden}:${p.texto}'), ['1:Tres', '2:Dos']);
  });

  test('T-71/T-72/T-73: la tarea guarda horas "HH:mm" y días ordenados', () {
    final f = _valido()
      ..alternarDia(5)
      ..alternarDia(3);
    final t = f.aTarea();
    expect(t.horaInicio, '20:00');
    expect(t.horaFin, '20:15');
    expect(t.diasSemana, [1, 3, 5]);
    expect(t.fecha, isNull);
  });

  test('Tarea de un solo día: guarda la fecha si no hay días', () {
    final f = _valido()
      ..alternarDia(1) // quita el lunes
      ..cambiarFecha(DateTime(2026, 11, 12));
    final t = f.aTarea();
    expect(t.diasSemana, isEmpty);
    expect(t.fecha, '2026-11-12');
    expect(t.esParaDia(DateTime(2026, 11, 12)), isTrue);
    expect(t.tipo, TipoTarea.colegio);
  });
}
