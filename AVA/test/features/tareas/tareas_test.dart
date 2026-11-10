import 'package:ava/core/constantes/pictogramas.dart';
import 'package:ava/core/utilidades/controlador_carga.dart';
import 'package:ava/features/autenticacion/dominio/cuenta.dart';
import 'package:ava/features/autenticacion/dominio/rol.dart';
import 'package:ava/features/aulas/dominio/repositorio_aulas_simulado.dart';
import 'package:ava/features/perfil/dominio/repositorio_estudiantes_simulado.dart';
import 'package:ava/features/tareas/dominio/repositorio_tareas_simulado.dart';
import 'package:ava/features/tareas/dominio/tarea_agenda.dart';
import 'package:ava/features/tareas/logica/detalle_tarea_controlador.dart';
import 'package:ava/features/tareas/logica/encargos_controlador.dart';
import 'package:ava/features/tareas/logica/formulario_tarea_controlador.dart';
import 'package:ava/features/tareas/logica/tarea_estudiante_controlador.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas_prueba.dart';

void main() {
  final lunes = DateTime(2026, 11, 9);
  final martes = DateTime(2026, 11, 10);
  final lunesSiguiente = DateTime(2026, 11, 16);
  const javier = Cuenta(id: 'javier', nombre: 'Javier', rol: Rol.tutor);

  late RepositorioTareasSimulado tareas;
  late FormularioTareaControlador formulario;

  setUp(() {
    final almacen = almacenDePrueba();
    tareas = RepositorioTareasSimulado(almacen);
    formulario = FormularioTareaControlador(
      tareas: tareas,
      estudiantes: RepositorioEstudiantesSimulado(almacen),
      aulas: RepositorioAulasSimulado(almacen),
      cuenta: javier,
    );
  });

  Future<List<Tarea>> delDia(String id, DateTime dia) => tareas.obtenerTareas(
    idEstudiante: id,
    desde: dia,
    hasta: DateTime(dia.year, dia.month, dia.day + 1),
  );

  test('la rutina de ejemplo cubre los siete días, con pictogramas', () async {
    final semana = await tareas.obtenerTareas(
      idEstudiante: 'e01',
      desde: lunes,
      hasta: lunesSiguiente,
    );

    expect(semana.map((t) => t.inicio.weekday).toSet(), hasLength(7));
    expect(semana.every((t) => t.pictograma != null), isTrue);
    expect(semana.any((t) => t.tipo == TipoTarea.encargoCentro), isTrue);
  });

  group('HU-03 a HU-06: tareas creadas por el tutor', () {
    test(
      'crea una tarea con horario, pictograma, descripción y pasos',
      () async {
        await formulario.guardar(
          idEstudiante: 'e01',
          titulo: 'Ir a la biblioteca',
          tipo: TipoTarea.escolar,
          inicio: DateTime(2026, 11, 10, 16),
          fin: DateTime(2026, 11, 10, 17),
          descripcion: 'Devolvemos un libro.',
          pasos: ['Coge el libro.', '  ', 'Ve a la biblioteca.'],
          pictograma: Pictogramas.biblioteca,
        );

        final tarea = (await delDia(
          'e01',
          martes,
        )).firstWhere((t) => t.titulo == 'Ir a la biblioteca');
        expect(tarea.pasos, ['Coge el libro.', 'Ve a la biblioteca.']);
        expect(tarea.pictograma, Pictogramas.biblioteca);
        expect(tarea.creadaPor, 'javier');
      },
    );

    test(
      'al cambiar la hora la agenda la muestra en el nuevo horario',
      () async {
        final original = (await delDia('e01', martes)).first;
        await formulario.guardar(
          idEstudiante: 'e01',
          titulo: original.titulo,
          tipo: original.tipo,
          inicio: DateTime(2026, 11, 10, 8),
          fin: DateTime(2026, 11, 10, 8, 30),
          existente: original,
        );

        final cambiada = (await delDia(
          'e01',
          martes,
        )).firstWhere((t) => t.id == original.id);
        expect(cambiada.inicio.hour, 8);
      },
    );

    test('la hora de fin debe ser posterior a la de inicio (HU-04)', () {
      expect(
        () => formulario.guardar(
          idEstudiante: 'e01',
          titulo: 'Mal',
          tipo: TipoTarea.escolar,
          inicio: DateTime(2026, 11, 10, 10),
          fin: DateTime(2026, 11, 10, 9),
        ),
        throwsA(isA<ErrorConMensaje>()),
      );
    });

    test('un tutor no puede crear tareas a alumnos de otra aula (HU-16)', () {
      expect(
        () => formulario.guardar(
          idEstudiante: 'e10',
          titulo: 'No permitido',
          tipo: TipoTarea.escolar,
          inicio: DateTime(2026, 11, 10, 10),
          fin: DateTime(2026, 11, 10, 11),
        ),
        throwsA(isA<ErrorConMensaje>()),
      );
    });
  });

  group('HU-07: encargos del centro', () {
    test('aparece en la agenda de cada alumno asignado en la fecha', () async {
      final creados = await EncargosControlador(tareas).crear(
        titulo: 'Repartir folletos',
        inicio: DateTime(2026, 11, 10, 12),
        fin: DateTime(2026, 11, 10, 12, 30),
        idsEstudiantes: {'e01', 'e02', 'e03'},
        creadaPor: 'javier',
      );

      expect(creados, 3);
      for (final id in ['e01', 'e02', 'e03']) {
        final encargo = (await delDia(
          id,
          martes,
        )).where((t) => t.titulo == 'Repartir folletos').single;
        expect(encargo.tipo, TipoTarea.encargoCentro);
        expect(encargo.idEncargo, isNotNull);
      }
      expect(
        (await delDia(
          'e04',
          martes,
        )).any((t) => t.titulo == 'Repartir folletos'),
        isFalse,
      );
    });

    test('hay que elegir al menos un alumno', () {
      expect(
        () => EncargosControlador(tareas).crear(
          titulo: 'Sin nadie',
          inicio: DateTime(2026, 11, 10, 12),
          fin: DateTime(2026, 11, 10, 13),
          idsEstudiantes: {},
          creadaPor: 'javier',
        ),
        throwsArgumentError,
      );
    });
  });

  group('HU-03: tareas personales creadas por el estudiante', () {
    test('el asistente crea la tarea en el día y la hora elegidos', () async {
      final asistente =
          TareaEstudianteControlador(
              repositorio: tareas,
              idEstudiante: 'e01',
              hoy: lunes,
            )
            ..elegirActividad(ActividadPersonal.catalogo.first)
            ..elegirDia(martes)
            ..retrasarHora()
            ..elegirDuracion(60)
            ..irAConfirmar();

      expect(asistente.paso, PasoAsistente.confirmar);
      final tarea = (await asistente.guardar())!;

      expect(tarea.inicio, DateTime(2026, 11, 10, 17, 15));
      expect(tarea.fin, DateTime(2026, 11, 10, 18, 15));
      expect(tarea.creadaPor, 'e01');
      expect(
        (await delDia('e01', martes)).any((t) => t.id == tarea.id),
        isTrue,
      );
    });

    test('solo puede borrar las suyas y si su tutor se lo permite', () async {
      final asistente = TareaEstudianteControlador(
        repositorio: tareas,
        idEstudiante: 'e01',
        hoy: martes,
      )..elegirActividad(ActividadPersonal.catalogo.first);
      final propia = (await asistente.guardar())!;
      final delColegio = (await delDia('e01', martes)).first;

      final sinPermiso = DetalleTareaControlador(
        repositorio: tareas,
        tarea: propia,
        idEstudiante: 'e01',
      );
      final ajena = DetalleTareaControlador(
        repositorio: tareas,
        tarea: delColegio,
        idEstudiante: 'e01',
        puedeGestionarTareas: true,
      );
      final conPermiso = DetalleTareaControlador(
        repositorio: tareas,
        tarea: propia,
        idEstudiante: 'e01',
        puedeGestionarTareas: true,
      );

      expect(sinPermiso.puedeModificar, isFalse);
      expect(ajena.puedeModificar, isFalse);
      expect(await conPermiso.eliminar(), isTrue);
      expect(
        (await delDia('e01', martes)).any((t) => t.id == propia.id),
        isFalse,
      );
    });
  });

  group('HU-11: inicio y fin de una tarea', () {
    test('empezar y terminar se guarda', () async {
      final tarea = (await delDia('e01', lunes)).first;
      final detalle = DetalleTareaControlador(
        repositorio: tareas,
        tarea: tarea,
      );

      expect(detalle.puedeEmpezar, isTrue);
      expect(await detalle.empezar(), isTrue);
      expect(detalle.puedeTerminar, isTrue);
      expect(await detalle.terminar(), isTrue);
      expect((await delDia('e01', lunes)).first.estado, EstadoTarea.completada);
    });

    test(
      'la explicación se muestra de una en una: descripción y pasos',
      () async {
        final tarea = (await delDia('e01', lunes)).first;
        final detalle = DetalleTareaControlador(
          repositorio: tareas,
          tarea: tarea,
        );

        expect(detalle.paginas.first, tarea.descripcion);
        expect(detalle.paginas, hasLength(1 + tarea.pasos.length));
        detalle.irAPagina(1);
        expect(detalle.pagina, 1);
        detalle.irAPagina(99);
        expect(detalle.pagina, 1);
      },
    );
  });
}
