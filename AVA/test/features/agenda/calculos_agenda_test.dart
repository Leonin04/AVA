import 'package:ava/features/agenda/logica/calculos_agenda.dart';
import 'package:ava/features/tareas/dominio/tarea_agenda.dart';
import 'package:flutter_test/flutter_test.dart';

Tarea _tarea(
  String id,
  DateTime inicio, {
  int minutos = 30,
  EstadoTarea estado = EstadoTarea.pendiente,
}) {
  return Tarea(
    id: id,
    idEstudiante: 'e01',
    titulo: id,
    inicio: inicio,
    fin: inicio.add(Duration(minutes: minutos)),
    estado: estado,
  );
}

void main() {
  // Miércoles 11 de noviembre de 2026.
  final miercoles = DateTime(2026, 11, 11);

  group('Semana', () {
    test('empieza en lunes y tiene siete días', () {
      final dias = CalculosAgenda.diasDeSemana(DateTime(2026, 11, 11, 15));

      expect(dias, hasLength(7));
      expect(dias.first, DateTime(2026, 11, 9));
      expect(dias.last, DateTime(2026, 11, 15));
    });

    test('cruza correctamente un cambio de mes', () {
      expect(
        CalculosAgenda.inicioDeSemana(DateTime(2026, 12, 2)),
        DateTime(2026, 11, 30),
      );
    });
  });

  test('tareasDelDia filtra por día y ordena por hora', () {
    final tareas = [
      _tarea('tarde', DateTime(2026, 11, 11, 16)),
      _tarea('otroDia', DateTime(2026, 11, 12, 9)),
      _tarea('manana', DateTime(2026, 11, 11, 9)),
    ];

    final delDia = CalculosAgenda.tareasDelDia(tareas, miercoles);

    expect(delDia.map((t) => t.id), ['manana', 'tarde']);
  });

  group('Tarea actual y siguiente (HU-11)', () {
    final asamblea = _tarea('asamblea', DateTime(2026, 11, 11, 9));
    final taller = _tarea('taller', DateTime(2026, 11, 11, 9, 30), minutos: 90);
    final recreo = _tarea('recreo', DateTime(2026, 11, 11, 11));

    test('la actual es la que está en su horario', () {
      final ahora = DateTime(2026, 11, 11, 9, 45);

      expect(
        CalculosAgenda.tareaActual([asamblea, taller, recreo], ahora)?.id,
        'taller',
      );
      expect(
        CalculosAgenda.siguienteTarea([asamblea, taller, recreo], ahora)?.id,
        'recreo',
      );
    });

    test('una tarea empezada por el estudiante tiene prioridad', () {
      final ahora = DateTime(2026, 11, 11, 9, 45);
      final asambleaEmpezada = asamblea.copyWith(estado: EstadoTarea.enCurso);

      expect(
        CalculosAgenda.tareaActual([asambleaEmpezada, taller], ahora)?.id,
        'asamblea',
      );
    });

    test('al terminar la actual, la siguiente se actualiza', () {
      final ahora = DateTime(2026, 11, 11, 9, 10);
      final asambleaHecha = asamblea.copyWith(estado: EstadoTarea.completada);

      expect(
        CalculosAgenda.siguienteTarea([asamblea, taller, recreo], ahora)?.id,
        'taller',
      );
      expect(
        CalculosAgenda.siguienteTarea([
          asambleaHecha,
          taller,
          recreo,
        ], ahora)?.id,
        'taller',
      );
      expect(
        CalculosAgenda.tareaActual([asambleaHecha, taller, recreo], ahora),
        isNull,
      );
    });

    test('no hay siguiente cuando ya no quedan tareas', () {
      final ahora = DateTime(2026, 11, 11, 20);

      expect(CalculosAgenda.siguienteTarea([asamblea, taller], ahora), isNull);
    });
  });
}
