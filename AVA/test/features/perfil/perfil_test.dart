import 'package:ava/core/constantes/paleta.dart';
import 'package:ava/core/constantes/pictogramas.dart';
import 'package:ava/core/utilidades/controlador_carga.dart';
import 'package:ava/features/agenda/dominio/vista_agenda.dart';
import 'package:ava/features/autenticacion/dominio/cuenta.dart';
import 'package:ava/features/autenticacion/dominio/metodo_acceso.dart';
import 'package:ava/features/aulas/dominio/ficha_aula.dart';
import 'package:ava/features/autenticacion/dominio/repositorio_autenticacion_simulado.dart';
import 'package:ava/features/autenticacion/dominio/rol.dart';
import 'package:ava/features/aulas/dominio/repositorio_aulas_simulado.dart';
import 'package:ava/features/aulas/logica/gestion_aulas_controlador.dart';
import 'package:ava/features/autenticacion/dominio/repositorio_cuentas_simulado.dart';
import 'package:ava/features/perfil/dominio/conversion_firestore.dart';
import 'package:ava/features/perfil/dominio/perfil_estudiante.dart';
import 'package:ava/features/perfil/dominio/preferencias_accesibilidad.dart';
import 'package:ava/features/perfil/dominio/repositorio_estudiantes_simulado.dart';
import 'package:ava/features/perfil/logica/ficha_estudiante_controlador.dart';
import 'package:ava/features/perfil/logica/preferencias_controlador.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas_prueba.dart';

void main() {
  const javier = Cuenta(id: 'javier', nombre: 'Javier', rol: Rol.tutor);

  FichaEstudianteControlador fichaDe(String id, {Cuenta cuenta = javier}) {
    final almacen = almacenDePrueba();
    return FichaEstudianteControlador(
      estudiantes: RepositorioEstudiantesSimulado(almacen),
      aulas: RepositorioAulasSimulado(almacen),
      autenticacion: RepositorioAutenticacionSimulado(almacen),
      cuenta: cuenta,
      idEstudiante: id,
    );
  }

  group('HU-17: el tutor solo gestiona a sus alumnos', () {
    test('puede abrir la ficha de un alumno de su aula', () async {
      final ficha = fichaDe('e01'); // Diego, 1ºA, tutor Javier.
      await ficha.cargar();
      expect(ficha.datos?.nombre, 'Diego');
    });

    test('se le deniega un alumno de otra aula', () async {
      final ficha = fichaDe('e10'); // Iván, 2ºA, tutora Ana.
      await ficha.cargar();
      expect(ficha.datos, isNull);
      expect(ficha.mensajeError, FichaEstudianteControlador.mensajeSinPermiso);
    });
  });

  group('HU-19: perfil del estudiante', () {
    test('guarda foto, intereses, necesidades y autorregulación', () async {
      final ficha = fichaDe('e01');
      await ficha.cargar();

      await ficha.guardarPerfil(
        ficha.datos!.copyWith(
          avatar: Pictogramas.alumno,
          intereses: ['Música', 'Fútbol'],
          necesidades: 'Botones grandes',
          autorregulacion: 'Música tranquila',
        ),
      );

      expect(ficha.datos?.intereses, ['Música', 'Fútbol']);
      expect(ficha.datos?.avatar, Pictogramas.alumno);
      expect(ficha.datos?.necesidades, 'Botones grandes');
      expect(ficha.datos?.autorregulacion, 'Música tranquila');
    });

    test(
      'el perfil se convierte a mapa y vuelve igual (formato Firestore)',
      () {
        const original = Estudiante(
          id: 'x',
          nombre: 'Prueba',
          idAula: '1A',
          metodoAcceso: AccesoConPin(),
          avatar: Pictogramas.sol,
          color: ColorPastel.menta,
          intereses: ['Cine'],
          preferencias: PreferenciasAccesibilidad(
            tamanoTexto: TamanoTexto.muyGrande,
            leerEnVoz: true,
            vistasAgenda: {VistaAgenda.diaria},
          ),
          puedeGestionarTareas: true,
        );
        final copia = Estudiante.fromMap('x', original.toMap());

        expect(copia.preferencias, original.preferencias);
        expect(copia.avatar, original.avatar);
        expect(copia.color, original.color);
        expect(copia.intereses, original.intereses);
        expect(copia.puedeGestionarTareas, isTrue);
      },
    );
  });

  group('T-60: tamaño de letra', () {
    test('los tres tamaños se conservan al guardarlos en Firebase', () {
      for (final tamano in TamanoTexto.values) {
        final mapa = ConversionFirestore.preferenciasA(
          PreferenciasAccesibilidad(tamanoTexto: tamano),
        );
        expect(
          ConversionFirestore.preferenciasDesde(mapa).tamanoTexto,
          tamano,
          reason: tamano.name,
        );
      }
    });

    test('se guarda en el perfil y sigue al volver a entrar', () async {
      final almacen = almacenDePrueba();
      final repositorio = RepositorioEstudiantesSimulado(almacen);
      final controlador = PreferenciasControlador(repositorio)
        ..aplicarDeEstudiante((await repositorio.obtener('e03'))!);

      await controlador.cambiar(
        const PreferenciasAccesibilidad(tamanoTexto: TamanoTexto.muyGrande),
      );

      final guardado = await repositorio.obtener('e03');
      expect(guardado!.preferencias.tamanoTexto, TamanoTexto.muyGrande);
    });

    test('si no se puede guardar, el cambio se deshace y se avisa', () async {
      final almacen = almacenDePrueba();
      final repositorio = _RepositorioQueFalla(almacen);
      final controlador = PreferenciasControlador(repositorio)
        ..aplicarDeEstudiante((await repositorio.obtener('e03'))!);
      final antes = controlador.preferencias.tamanoTexto;

      await expectLater(
        controlador.cambiar(
          const PreferenciasAccesibilidad(tamanoTexto: TamanoTexto.muyGrande),
        ),
        throwsA(isA<ErrorConMensaje>()),
      );
      expect(controlador.preferencias.tamanoTexto, antes);
    });
  });

  group('HU-15: preferencias de accesibilidad', () {
    test('no se puede ocultar a la vez el texto y los pictogramas', () {
      const p = PreferenciasAccesibilidad(
        mostrarTexto: false,
        mostrarPictogramas: false,
      );
      expect(validarPreferencias(p), isNotNull);
    });

    test('hace falta al menos una vista de la agenda', () {
      const p = PreferenciasAccesibilidad(vistasAgenda: {});
      expect(validarPreferencias(p), isNotNull);
    });

    test('los cambios del estudiante se guardan en su perfil', () async {
      final almacen = almacenDePrueba();
      final estudiantes = RepositorioEstudiantesSimulado(almacen);
      final preferencias = PreferenciasControlador(estudiantes);
      preferencias.aplicarDeEstudiante((await estudiantes.obtener('e01'))!);

      await preferencias.cambiar(
        preferencias.preferencias.copyWith(modoOscuro: true),
      );

      expect(
        (await estudiantes.obtener('e01'))!.preferencias.modoOscuro,
        isTrue,
      );
    });

    test('el tutor guarda preferencias y permisos', () async {
      final ficha = fichaDe('e03');
      await ficha.cargar();

      final error = await ficha.guardarPreferencias(
        const PreferenciasAccesibilidad(altoContraste: true),
        puedeModificarPreferencias: true,
        puedeGestionarTareas: false,
      );

      expect(error, isNull);
      expect(ficha.datos?.preferencias.altoContraste, isTrue);
      expect(ficha.datos?.puedeModificarPreferencias, isTrue);
    });

    test('un error de permisos se comunica con un mensaje claro', () async {
      final ficha = fichaDe('e01');
      await ficha.cargar();
      final otra = fichaDe('e10', cuenta: javier);
      await otra.cargar();

      expect(otra.mensajeError, isNotNull);
      expect(
        () => otra.guardarPerfil(ficha.datos!.copyWith(idAula: '2A')),
        throwsA(isA<ErrorConMensaje>()),
      );
    });
  });

  group('HU-16: aulas y tutores', () {
    test('crea un aula, le asigna alumnos y un tutor', () async {
      final almacen = almacenDePrueba();
      final estudiantes = RepositorioEstudiantesSimulado(almacen);
      final gestion = GestionAulasControlador(
        aulas: RepositorioAulasSimulado(almacen),
        cuentas: RepositorioCuentasSimulado(almacen),
        estudiantes: estudiantes,
      );
      await gestion.cargar();

      final id = gestion.nuevoId();
      await gestion.guardar(Aula(id: id, nombre: '3ºA', idTutor: 'javier'), {
        'e01',
        'e10',
      });

      final aula = gestion.datos!.aulas.firstWhere((a) => a.id == id);
      expect(aula.idTutor, 'javier');
      expect((await estudiantes.obtener('e01'))!.idAula, id);
      expect((await estudiantes.obtener('e10'))!.idAula, id);
    });

    test('no deja repetir el nombre de un aula', () async {
      final almacen = almacenDePrueba();
      final gestion = GestionAulasControlador(
        aulas: RepositorioAulasSimulado(almacen),
        cuentas: RepositorioCuentasSimulado(almacen),
        estudiantes: RepositorioEstudiantesSimulado(almacen),
      );
      await gestion.cargar();
      expect(gestion.validarNombre('1ºa', idAula: 'nueva'), isNotNull);
    });
  });
}

/// Repositorio que no puede guardar, como si Firebase rechazara el cambio.
class _RepositorioQueFalla extends RepositorioEstudiantesSimulado {
  _RepositorioQueFalla(super.almacen);

  @override
  Future<void> guardar(Estudiante estudiante) async =>
      throw Exception('Sin conexión');
}
