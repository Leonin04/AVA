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
import 'package:ava/features/tareas/logica/tiempo_restante.dart';
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

  group('HU-14: repetición semanal', () {
    Future<Tarea> crearRepetida(List<int> dias) => formulario.guardar(
      idEstudiante: 'e01',
      titulo: 'Gimnasia',
      tipo: TipoTarea.escolar,
      inicio: DateTime(2026, 11, 9, 16),
      fin: DateTime(2026, 11, 9, 17),
      diasSemana: dias,
    );

    Future<List<int>> diasConGimnasia(DateTime desde, DateTime hasta) async => [
      for (final t in await tareas.obtenerTareas(
        idEstudiante: 'e01',
        desde: desde,
        hasta: hasta,
      ))
        if (t.titulo == 'Gimnasia') t.inicio.weekday,
    ];

    test('sale solo los días elegidos, también la semana siguiente', () async {
      await crearRepetida([DateTime.wednesday, DateTime.monday]);

      expect(await diasConGimnasia(lunes, lunesSiguiente), [1, 3]);
      expect(await diasConGimnasia(lunesSiguiente, DateTime(2026, 11, 23)), [
        1,
        3,
      ]);
    });

    test('al cambiar los días cambian las próximas apariciones y '
        'el historial se conserva', () async {
      await crearRepetida([DateTime.monday, DateTime.wednesday]);
      final delLunes = (await delDia(
        'e01',
        lunes,
      )).firstWhere((t) => t.titulo == 'Gimnasia');
      await tareas.actualizarEstado(delLunes.id, EstadoTarea.completada);

      await formulario.guardar(
        idEstudiante: 'e01',
        titulo: 'Gimnasia',
        tipo: TipoTarea.escolar,
        inicio: delLunes.inicio,
        fin: delLunes.fin,
        diasSemana: [DateTime.friday],
        existente: delLunes,
      );

      expect(await diasConGimnasia(lunesSiguiente, DateTime(2026, 11, 23)), [
        5,
      ]);
      final historial = await tareas.historial(
        idEstudiante: 'e01',
        desde: lunes,
        hasta: lunesSiguiente,
      );
      expect(historial.single.tituloTarea, 'Gimnasia');
      expect(historial.single.estadoNuevo, EstadoTarea.completada);
    });

    test('cada día guarda su propio estado', () async {
      await crearRepetida([DateTime.monday, DateTime.tuesday]);
      final delLunes = (await delDia(
        'e01',
        lunes,
      )).firstWhere((t) => t.titulo == 'Gimnasia');
      await tareas.actualizarEstado(delLunes.id, EstadoTarea.completada);

      final delMartes = (await delDia(
        'e01',
        martes,
      )).firstWhere((t) => t.titulo == 'Gimnasia');
      expect(delMartes.estado, EstadoTarea.pendiente);
    });

    test('rechaza días que no existen', () async {
      await expectLater(crearRepetida([0, 8]), throwsA(isA<ErrorConMensaje>()));
    });
  });

  group('HU-04 a HU-07: tareas creadas por el tutor', () {
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
          pasos: const [
            PasoTarea('Coge el libro.'),
            PasoTarea('  '),
            PasoTarea('Ve a la biblioteca.', imagen: Pictogramas.biblioteca),
          ],
          pictograma: Pictogramas.biblioteca,
        );

        final tarea = (await delDia(
          'e01',
          martes,
        )).firstWhere((t) => t.titulo == 'Ir a la biblioteca');
        expect(tarea.pasos, const [
          PasoTarea('Coge el libro.'),
          PasoTarea('Ve a la biblioteca.', imagen: Pictogramas.biblioteca),
        ]);
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

    test('la hora de fin debe ser posterior a la de inicio (HU-05)', () {
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

    test('un tutor no puede crear tareas a alumnos de otra aula (HU-17)', () {
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

  group('HU-08: encargos del centro', () {
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

  group('HU-04: tareas personales creadas por el estudiante', () {
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

    test('HU-14: puede repetirla todas las semanas (todos los sábados a las '
        '12, una hora)', () async {
      final sabado = DateTime(2026, 11, 14);
      final asistente =
          TareaEstudianteControlador(
              repositorio: tareas,
              idEstudiante: 'e01',
              hoy: lunes,
            )
            ..elegirActividad(ActividadPersonal.catalogo.first)
            ..elegirDia(sabado)
            ..elegirDuracion(60);
      // Empieza a las 17:00: se adelanta hasta las 12:00.
      while (asistente.inicio.isAfter(DateTime(2026, 11, 14, 12))) {
        asistente.adelantarHora();
      }
      asistente
        ..cambiarRepeticion()
        ..irAConfirmar();
      expect(asistente.diasSemana, [DateTime.saturday]);

      final tarea = (await asistente.guardar())!;
      expect(tarea.inicio, DateTime(2026, 11, 14, 12));

      Future<bool> laTiene(DateTime dia) async =>
          (await delDia('e01', dia)).any((t) => t.titulo == tarea.titulo);
      expect(await laTiene(sabado), isTrue);
      expect(
        await laTiene(DateTime(2026, 11, 21)),
        isTrue,
        reason: 'otro sábado',
      );
      expect(await laTiene(DateTime(2026, 11, 20)), isFalse, reason: 'viernes');
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

  group('HU-12: inicio y fin de una tarea', () {
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

        expect(detalle.paginas.first.texto, tarea.descripcion);
        expect(detalle.paginas, hasLength(1 + tarea.pasos.length));
        detalle.irAPagina(1);
        expect(detalle.pagina, 1);
        detalle.irAPagina(99);
        expect(detalle.pagina, 1);
      },
    );
  });

  group('HU-20 y HU-21: un paso cada vez y confirmar para avanzar', () {
    Future<DetalleTareaControlador> empezada() async {
      final tarea = (await delDia('e01', lunes)).first;
      final detalle = DetalleTareaControlador(
        repositorio: tareas,
        tarea: tarea,
        idEstudiante: 'e01',
      );
      await detalle.empezar();
      return detalle;
    }

    test('mientras se hace, solo se ve el paso actual', () async {
      final detalle = await empezada();
      expect(detalle.guiando, isTrue);
      expect(detalle.paginas, hasLength(1));
      expect(detalle.paginas.single.texto, startsWith('Paso 1 de 3'));
    });

    test('al confirmar se guarda el paso y se pasa al siguiente', () async {
      final detalle = await empezada();
      expect(await detalle.confirmarPaso(), isTrue);
      expect(detalle.pasoActual, 1);
      expect(detalle.paginas.single.texto, startsWith('Paso 2 de 3'));

      // Se ha guardado: al volver a abrir la tarea sigue en el paso 2.
      final otraVez = (await delDia('e01', lunes)).first;
      expect(otraVez.pasoActual, 1);
    });

    test('al confirmar el último paso la tarea queda terminada', () async {
      final detalle = await empezada();
      while (!detalle.esUltimoPaso) {
        await detalle.confirmarPaso();
      }
      await detalle.confirmarPaso();
      expect(detalle.tarea.estado, EstadoTarea.completada);
      expect(detalle.guiando, isFalse);
    });
  });

  group('HU-22: temporizador', () {
    final inicio = DateTime(2026, 11, 9, 10);
    final fin = DateTime(2026, 11, 9, 10, 30);

    test('dice en palabras cuánto queda y la barra se vacía', () {
      final mitad = TiempoRestante.en(
        DateTime(2026, 11, 9, 10, 15),
        inicio,
        fin,
      );
      expect(mitad.texto, 'Quedan 15 minutos');
      expect(mitad.fraccion, closeTo(0.5, 0.01));
    });

    test('al pasar la hora de fin dice que se ha acabado', () {
      final despues = TiempoRestante.en(DateTime(2026, 11, 9, 11), inicio, fin);
      expect(despues.acabado, isTrue);
      expect(despues.texto, 'Se ha acabado el tiempo');
      expect(despues.fraccion, 0);
    });
  });
}
