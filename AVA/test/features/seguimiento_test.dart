import 'package:ava/features/autenticacion/dominio/cuenta.dart';
import 'package:ava/features/autenticacion/dominio/rol.dart';
import 'package:ava/features/aulas/dominio/repositorio_aulas_simulado.dart';
import 'package:ava/features/avisos/logica/planificador_avisos.dart';
import 'package:ava/features/perfil/dominio/repositorio_estudiantes_simulado.dart';
import 'package:ava/features/seguimiento/logica/historial_controlador.dart';
import 'package:ava/features/seguimiento/logica/seguimiento_controlador.dart';
import 'package:ava/features/tareas/dominio/evento_historial.dart';
import 'package:ava/features/tareas/dominio/repositorio_tareas_simulado.dart';
import 'package:ava/features/tareas/dominio/tarea_agenda.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ayudas_prueba.dart';

void main() {
  // Lunes 9 de noviembre de 2026 a mediodía.
  final mediodia = DateTime(2026, 11, 9, 12);
  DateTime reloj() => mediodia;
  const javier = Cuenta(id: 'javier', nombre: 'Javier', rol: Rol.tutor);
  const familiar = Cuenta(
    id: 'javier',
    nombre: 'Javier',
    rol: Rol.tutor,
    esFamiliar: true,
  );

  late RepositorioTareasSimulado tareas;
  late SeguimientoControlador seguimiento;

  SeguimientoControlador seguimientoDe(Cuenta cuenta) {
    final almacen = almacenDePrueba();
    tareas = RepositorioTareasSimulado(almacen, reloj: reloj);
    return SeguimientoControlador(
      estudiantes: RepositorioEstudiantesSimulado(almacen),
      aulas: RepositorioAulasSimulado(almacen),
      tareas: tareas,
      cuenta: cuenta,
      reloj: reloj,
    );
  }

  setUp(() => seguimiento = seguimientoDe(javier));

  group('HU-26: estado y progreso de los alumnos asignados', () {
    test('el tutor solo ve a sus alumnos, con sus tareas de hoy', () async {
      await seguimiento.cargar();
      final alumnos = seguimiento.datos!;

      expect(alumnos, isNotEmpty);
      expect(
        alumnos.every((a) => a.aula?.id == '1A' || a.aula?.id == '1B'),
        isTrue,
      );
      expect(alumnos.first.total, 5);
      expect(alumnos.first.fraccion, 0);
    });

    test('el tutor del centro confirma una tarea y queda en el historial '
        'como hecha por el tutor (T-124)', () async {
      await seguimiento.cargar();
      final diego = seguimiento.datos!.firstWhere(
        (a) => a.estudiante.id == 'e01',
      );
      final asamblea = diego.tareas.first;

      expect(await seguimiento.confirmarTerminada(asamblea), isNull);
      final actualizado = seguimiento.datos!.firstWhere(
        (a) => a.estudiante.id == 'e01',
      );
      expect(actualizado.contar(EstadoTarea.completada), 1);

      final historial = await tareas.historial(
        idEstudiante: 'e01',
        desde: DateTime(2026, 11, 9),
        hasta: DateTime(2026, 11, 10),
      );
      expect(historial.single.origen, OrigenCambio.tutor);
      expect(historial.single.idActor, 'javier');
    });

    test('el tutor familiar solo consulta', () async {
      final soloLectura = seguimientoDe(familiar);
      await soloLectura.cargar();
      final tarea = soloLectura.datos!.first.tareas.first;

      expect(soloLectura.puedeConfirmar, isFalse);
      expect(await soloLectura.confirmarTerminada(tarea), isNotNull);
    });
  });

  group('HU-29: avisos al tutor por retraso', () {
    test(
      'avisa de las tareas sin empezar pasada su hora, sin duplicados',
      () async {
        await seguimiento.cargar();
        final avisos = seguimiento.avisos;
        final deDiego = avisos.where((a) => a.nombreEstudiante == 'Diego');

        // A las 12:00 no ha empezado la asamblea (9:00), ni el taller (9:30),
        // ni el recreo (11:00), ni el encargo (11:30).
        expect(deDiego.map((a) => a.tarea.titulo), [
          'Asamblea',
          'Taller de cocina',
          'Recreo',
          'Llevar fotocopias',
        ]);
        expect(deDiego.every((a) => a.tipo == TipoRetraso.noIniciada), isTrue);
        expect(avisos.map((a) => a.clave).toSet(), hasLength(avisos.length));
        expect(deDiego.first.texto, contains('Diego'));
        expect(deDiego.first.texto, contains('Asamblea'));
      },
    );

    test('una tarea empezada que no termina a su hora avisa como «no ha '
        'terminado» y una terminada no avisa', () {
      Tarea tarea(EstadoTarea estado) => Tarea(
        id: 't',
        idEstudiante: 'e01',
        titulo: 'Huerto',
        inicio: DateTime(2026, 11, 9, 10),
        fin: DateTime(2026, 11, 9, 11),
        estado: estado,
      );

      final retrasos = PlanificadorAvisos.retrasos(
        [tarea(EstadoTarea.enCurso)],
        mediodia,
        nombreEstudiante: 'Diego',
      );
      expect(retrasos.single.tipo, TipoRetraso.noTerminada);
      expect(
        PlanificadorAvisos.retrasos(
          [tarea(EstadoTarea.completada)],
          mediodia,
          nombreEstudiante: 'Diego',
        ),
        isEmpty,
      );
    });
  });

  group('HU-28: avisos previos', () {
    Tarea conAviso(int? minutos) => Tarea(
      id: 'gimnasia',
      idEstudiante: 'e01',
      titulo: 'Gimnasia',
      inicio: DateTime(2026, 11, 9, 16),
      fin: DateTime(2026, 11, 9, 17),
      avisoMinutos: minutos,
    );

    test('avisa con la antelación elegida y solo una vez', () {
      final tareas = [conAviso(15)];
      expect(
        PlanificadorAvisos.pendientes(tareas, DateTime(2026, 11, 9, 15, 40)),
        isEmpty,
        reason: 'todavía es pronto',
      );

      final aviso = PlanificadorAvisos.pendientes(
        tareas,
        DateTime(2026, 11, 9, 15, 45),
      ).single;
      expect(aviso.texto, contains('15 minutos'));
      expect(
        PlanificadorAvisos.pendientes(
          tareas,
          DateTime(2026, 11, 9, 15, 50),
          mostrados: {aviso.clave},
        ),
        isEmpty,
        reason: 'no se repite',
      );
    });

    test('si cambia la antelación el aviso se recalcula; sin antelación o '
        'empezada la tarea no hay aviso', () {
      expect(
        PlanificadorAvisos.avisosPrevios([conAviso(30)]).single.momento,
        DateTime(2026, 11, 9, 15, 30),
      );
      expect(PlanificadorAvisos.avisosPrevios([conAviso(null)]), isEmpty);
      expect(
        PlanificadorAvisos.pendientes([
          conAviso(15),
        ], DateTime(2026, 11, 9, 16, 5)),
        isEmpty,
        reason: 'ya ha empezado',
      );
    });
  });

  group('HU-27: historial por día o por semana', () {
    test('muestra las tareas terminadas agrupadas por día', () async {
      final almacen = almacenDePrueba();
      final repo = RepositorioTareasSimulado(almacen, reloj: reloj);
      final lunes = await repo.obtenerTareas(
        idEstudiante: 'e01',
        desde: DateTime(2026, 11, 9),
        hasta: DateTime(2026, 11, 10),
      );
      final martes = await repo.obtenerTareas(
        idEstudiante: 'e01',
        desde: DateTime(2026, 11, 10),
        hasta: DateTime(2026, 11, 11),
      );
      await repo.actualizarEstado(lunes.first.id, EstadoTarea.enCurso);
      await repo.actualizarEstado(lunes.first.id, EstadoTarea.completada);
      await repo.actualizarEstado(martes.first.id, EstadoTarea.completada);

      final historial = HistorialControlador(
        tareas: repo,
        idEstudiante: 'e01',
        reloj: reloj,
      );
      await historial.cargar();
      expect(historial.periodo, PeriodoHistorial.semana);
      expect(historial.completadasPorDia.keys, [
        DateTime(2026, 11, 9),
        DateTime(2026, 11, 10),
      ]);

      await historial.cambiarPeriodo(PeriodoHistorial.dia);
      expect(historial.completadasPorDia.keys, [DateTime(2026, 11, 9)]);
      expect(historial.datos, hasLength(2), reason: 'empezar y terminar');

      await historial.mover(1);
      expect(historial.completadasPorDia.keys, [DateTime(2026, 11, 10)]);
    });
  });
}
