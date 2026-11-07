import 'package:ava/core/servicios/autenticacion.dart';
import 'package:ava/features/agenda/dominio/registro.dart';
import 'package:ava/features/agenda/logica/agenda_dia.dart';
import 'package:ava/features/perfil/dominio/estudiante.dart';
import 'package:ava/features/tareas/dominio/tarea.dart';
import 'package:flutter_test/flutter_test.dart';

Tarea _t(String id, String inicio) => Tarea(
      id: id,
      nombre: id,
      horaInicio: inicio,
      horaFin: inicio,
      diasSemana: const [1, 2, 3, 4, 5, 6, 7],
      creadaPor: 'tutor',
    );

Registro _r(String tareaId, EstadoTarea e) =>
    Registro(tareaId: tareaId, fecha: '2026-11-09', estado: e);

void main() {
  final hoy = [_t('A', '09:00'), _t('B', '10:00'), _t('C', '11:00')];

  test('HU-11: sin registros, la siguiente es la primera del día', () {
    expect(siguienteTarea(hoy, const [])?.id, 'A');
  });

  test('HU-11: al terminar una, pasa a la siguiente', () {
    final r = [_r('A', EstadoTarea.terminada)];
    expect(siguienteTarea(hoy, r)?.id, 'B');
  });

  test('HU-11: una tarea iniciada sigue siendo la actual', () {
    final r = [_r('A', EstadoTarea.terminada), _r('B', EstadoTarea.iniciada)];
    expect(siguienteTarea(hoy, r)?.id, 'B');
  });

  test('HU-11: si todo está terminado no hay siguiente', () {
    final r = [for (final t in hoy) _r(t.id, EstadoTarea.terminada)];
    expect(siguienteTarea(hoy, r), isNull);
  });

  test('HU-12: estado de una tarea según sus registros', () {
    expect(estadoDe(hoy[0], const []), EstadoTarea.pendiente);
    expect(estadoDe(hoy[0], [_r('A', EstadoTarea.iniciada)]), EstadoTarea.iniciada);
  });

  test('HU-09: correo interno y clave según el método', () {
    expect(Autenticacion.correoEstudiante(' Pablo '), 'pablo@alumnos.ava.test');
    expect(Autenticacion.claveDe(MetodoLogin.pin, '1234'), 'ava-pin-1234');
    expect(Autenticacion.claveDe(MetodoLogin.pictograma, ['sol', 'perro', 'flor']),
        'ava-pic-sol-perro-flor');
    expect(Autenticacion.claveDe(MetodoLogin.contrasena, 'lucia123'), 'lucia123');
  });
}
