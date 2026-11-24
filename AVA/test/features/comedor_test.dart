import 'package:ava/core/utilidades/controlador_carga.dart';
import 'package:ava/features/autenticacion/dominio/cuenta.dart';
import 'package:ava/features/autenticacion/dominio/rol.dart';
import 'package:ava/features/aulas/dominio/repositorio_aulas_simulado.dart';
import 'package:ava/features/comedor/dominio/comedor.dart';
import 'package:ava/features/comedor/dominio/repositorio_comedor_simulado.dart';
import 'package:ava/features/comedor/logica/comedor_controladores.dart';
import 'package:ava/features/comedor/logica/listado_cocina.dart';
import 'package:ava/features/perfil/dominio/repositorio_estudiantes_simulado.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ayudas_prueba.dart';

void main() {
  // Lunes 9 de noviembre de 2026.
  final lunes = DateTime(2026, 11, 9);
  DateTime reloj() => DateTime(2026, 11, 9, 9);
  const javier = Cuenta(id: 'javier', nombre: 'Javier', rol: Rol.tutor);
  const familiar = Cuenta(
    id: 'javier',
    nombre: 'Javier',
    rol: Rol.tutor,
    esFamiliar: true,
  );

  late RepositorioComedorSimulado comedor;
  late RepositorioEstudiantesSimulado estudiantes;
  late RepositorioAulasSimulado aulas;

  setUp(() {
    final almacen = almacenDePrueba();
    comedor = RepositorioComedorSimulado(almacen, reloj: reloj);
    estudiantes = RepositorioEstudiantesSimulado(almacen);
    aulas = RepositorioAulasSimulado(almacen);
  });

  group('HU-23: asistencia al comedor', () {
    test('el alumno marca qué días de la semana va (boceto)', () async {
      final diego = (await estudiantes.obtener('e01'))!;
      final propio = ComedorEstudianteControlador(
        comedor: comedor,
        estudiante: diego,
        reloj: reloj,
      );
      await propio.cargar();
      expect(propio.datos!.map((d) => d.dia.weekday), [1, 2, 3, 4, 5]);
      expect(propio.datos!.every((d) => d.come == null), isTrue);

      await propio.cambiar(propio.datos!.first);
      expect(propio.datos!.first.come, isTrue);
      await propio.cambiar(propio.datos!.first);
      expect(propio.datos!.first.come, isFalse);
    });

    test(
      'el encargado pasa la lista de su aula y el tutor la corrige',
      () async {
        final aula = (await aulas.obtener('1A'))!;
        final encargado = ListaComedorControlador(
          comedor: comedor,
          estudiantes: estudiantes,
          aula: aula,
          fecha: lunes,
          origen: OrigenAsistencia.encargado,
          idActor: 'e01',
        );
        await encargado.cargar();
        final total = encargado.datos!.length;
        expect(encargado.sinResponder, total);

        final primero = encargado.datos!.first.estudiante;
        await encargado.marcar(primero, come: true);
        expect(encargado.sinResponder, total - 1);

        final tutor = ListaComedorControlador(
          comedor: comedor,
          estudiantes: estudiantes,
          aula: aula,
          fecha: lunes,
          origen: OrigenAsistencia.tutor,
          idActor: 'javier',
        );
        await tutor.marcar(primero, come: false);
        final corregida = (await comedor.asistencia(
          idAula: '1A',
          fecha: lunes,
        ))[primero.id]!;
        expect(corregida.come, isFalse);
        expect(corregida.revisadaPorTutor, isTrue);
      },
    );
  });

  group('HU-24: dietas protegidas', () {
    test(
      'el tutor del centro la guarda y queda registrado el cambio',
      () async {
        final diego = (await estudiantes.obtener('e01'))!;
        final dieta = DietaControlador(
          comedor: comedor,
          estudiante: diego,
          cuenta: javier,
        );
        await dieta.cargar();
        expect(
          await dieta.guardar(
            tipo: 'Sin gluten',
            alergias: 'frutos secos, huevo',
            indicaciones: '',
          ),
          isNull,
        );

        final (guardada, cambios) = dieta.datos!;
        expect(guardada.alergias, ['frutos secos', 'huevo']);
        expect(cambios.single.idActor, 'javier');
        expect(cambios.single.resumen, contains('Sin gluten'));
      },
    );

    test('el tutor familiar no puede ver ni cambiar las dietas', () async {
      final diego = (await estudiantes.obtener('e01'))!;
      final dieta = DietaControlador(
        comedor: comedor,
        estudiante: diego,
        cuenta: familiar,
      );
      await dieta.cargar();
      expect(dieta.datos, isNull);
      expect(dieta.mensajeError, contains('no puede'));
      expect(
        await dieta.guardar(tipo: 'x', alergias: '', indicaciones: ''),
        isNotNull,
      );
    });
  });

  group('HU-25: listado diario para cocina', () {
    test('solo quienes comen, con su dieta y nada más', () async {
      final aula = (await aulas.obtener('1A'))!;
      final delAula = await estudiantes.listar(idAula: '1A');
      await comedor.registrarAsistencia(
        idAula: '1A',
        fecha: lunes,
        asistencia: AsistenciaComedor(
          idEstudiante: delAula[0].id,
          come: true,
          origen: OrigenAsistencia.tutor,
        ),
      );
      await comedor.registrarAsistencia(
        idAula: '1A',
        fecha: lunes,
        asistencia: AsistenciaComedor(
          idEstudiante: delAula[1].id,
          come: false,
          origen: OrigenAsistencia.tutor,
        ),
      );
      await comedor.guardarDieta(
        Dieta(idEstudiante: delAula[0].id, tipo: 'Triturado'),
        idActor: 'javier',
      );

      final panel = ComedorTutorControlador(
        comedor: comedor,
        estudiantes: estudiantes,
        aulas: aulas,
        cuenta: javier,
        reloj: reloj,
      )..elegir(aula: aula, fecha: lunes);
      final listado = await panel.listado();

      expect(listado.comensales.single.nombre, delAula[0].nombre);
      expect(listado.comensales.single.dieta, 'Triturado');
      expect(listado.sinResponder, delAula.length - 2);
      expect(CalculosComedor.comoTexto(listado), contains('Comensales: 1'));
    });

    test('valida el aula y la fecha (no hay comedor en fin de semana)', () {
      expect(
        () => CalculosComedor.validar(null, lunes),
        throwsA(isA<ErrorConMensaje>()),
      );
      expect(
        () => CalculosComedor.validar(null, DateTime(2026, 11, 14)),
        throwsA(isA<ErrorConMensaje>()),
      );
      expect(
        CalculosComedor.proximoDiaDeComedor(DateTime(2026, 11, 14)),
        DateTime(2026, 11, 16),
      );
    });
  });
}
