import 'package:ava/core/servicios/almacen_simulado.dart';
import 'package:ava/core/utilidades/controlador_carga.dart';
import 'package:ava/features/autenticacion/dominio/clave_acceso.dart';
import 'package:ava/features/autenticacion/dominio/pictograma_clave.dart';
import 'package:ava/features/aulas/logica/estudiantes_aula_controlador.dart';
import 'package:ava/features/autenticacion/dominio/cuenta.dart';
import 'package:ava/features/autenticacion/dominio/repositorio_autenticacion_simulado.dart';
import 'package:ava/features/autenticacion/dominio/repositorio_cuentas_simulado.dart';
import 'package:ava/features/autenticacion/dominio/rol.dart';
import 'package:ava/features/autenticacion/logica/gestion_cuentas_controlador.dart';
import 'package:ava/features/autenticacion/logica/login_gestion_controlador.dart';
import 'package:ava/features/autenticacion/logica/permisos.dart';
import 'package:ava/features/autenticacion/logica/recuperacion_controlador.dart';
import 'package:ava/features/aulas/dominio/repositorio_aulas_simulado.dart';
import 'package:ava/features/perfil/dominio/repositorio_estudiantes_simulado.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas_prueba.dart';

void main() {
  _pruebasDesactivacion();

  group('HU-18: login de tutores y administración', () {
    test('entra con credenciales válidas y rechaza las inválidas', () async {
      final login = LoginGestionControlador(
        RepositorioAutenticacionSimulado(almacenDePrueba()),
      );

      final cuenta = await login.iniciarSesion(
        usuario: 'javier',
        contrasena: 'tutor1234',
      );
      expect(cuenta?.rol, Rol.tutor);

      expect(
        await login.iniciarSesion(usuario: 'javier', contrasena: 'mal'),
        isNull,
      );
      expect(login.mensajeError, isNotNull);
    });

    test(
      'un estudiante no puede entrar por el acceso del profesorado',
      () async {
        final login = LoginGestionControlador(
          RepositorioAutenticacionSimulado(almacenDePrueba()),
        );
        expect(
          await login.iniciarSesion(usuario: 'e02', contrasena: '1234'),
          isNull,
        );
      },
    );

    test('se puede pedir la recuperación de la contraseña', () async {
      final autenticacion = RepositorioAutenticacionSimulado(almacenDePrueba());
      final recuperacion = RecuperacionControlador(autenticacion);

      expect(recuperacion.validarEmail('no-es-correo'), isNotNull);
      await recuperacion.enviar('javier@colegio.example');

      expect(recuperacion.enviado, isTrue);
      expect(autenticacion.recuperacionesSolicitadas, [
        'javier@colegio.example',
      ]);
    });
  });

  group('HU-01 a HU-03: cuentas y roles', () {
    late GestionCuentasControlador gestion;
    late RepositorioAutenticacionSimulado autenticacion;
    late RepositorioEstudiantesSimulado estudiantes;

    setUp(() {
      final almacen = almacenDePrueba();
      autenticacion = RepositorioAutenticacionSimulado(almacen);
      estudiantes = RepositorioEstudiantesSimulado(almacen);
      gestion = GestionCuentasControlador(
        cuentas: RepositorioCuentasSimulado(almacen),
        autenticacion: autenticacion,
        estudiantes: estudiantes,
        aulas: RepositorioAulasSimulado(almacen),
      );
    });

    test('crea una cuenta de tutor que después puede iniciar sesión', () async {
      final error = await gestion.crear(
        cuenta: const Cuenta(
          id: 'marta.t',
          nombre: 'Marta Tutora',
          rol: Rol.tutor,
          email: 'marta@colegio.example',
        ),
        clave: const ClaveContrasena('secreta123'),
      );

      expect(error, isNull);
      final cuenta = await autenticacion.iniciarSesionGestion(
        usuario: 'marta.t',
        contrasena: 'secreta123',
      );
      expect(cuenta?.nombre, 'Marta Tutora');
    });

    test('impide crear una cuenta con un usuario repetido', () async {
      final error = await gestion.crear(
        cuenta: const Cuenta(id: 'javier', nombre: 'Otro', rol: Rol.tutor),
        clave: const ClaveContrasena('secreta123'),
      );
      expect(error, contains('Ya existe'));
    });

    test(
      'al crear un estudiante se crea su perfil en el aula elegida',
      () async {
        await gestion.crear(
          cuenta: const Cuenta(
            id: 'nuevo',
            nombre: 'Nuevo',
            rol: Rol.estudiante,
          ),
          clave: const ClavePin('5678'),
          idAula: '2A',
        );

        final perfil = await estudiantes.obtener('nuevo');
        expect(perfil?.idAula, '2A');
        final conectado = await autenticacion.entrarEstudiante(
          estudiante: perfil!,
          clave: const ClavePin('5678'),
        );
        expect(conectado?.nombre, 'Nuevo');
        expect(
          await autenticacion.entrarEstudiante(
            estudiante: perfil,
            clave: const ClavePin('0000'),
          ),
          isNull,
        );
      },
    );

    test('el rol limita las funciones', () {
      const admin = Cuenta(id: 'a', nombre: 'A', rol: Rol.administrador);
      const tutor = Cuenta(id: 't', nombre: 'T', rol: Rol.tutor);

      expect(Permisos.puedeGestionarCuentas(admin), isTrue);
      expect(Permisos.puedeGestionarAulas(admin), isTrue);
      expect(Permisos.puedeGestionarCuentas(tutor), isFalse);
      expect(Permisos.puedeGestionarAulas(tutor), isFalse);
      expect(Permisos.puedeCrearEncargos(tutor), isTrue);
    });

    test('valida usuario, correo y contraseña', () {
      expect(gestion.validarUsuario('Con Espacios'), isNotNull);
      expect(gestion.validarUsuario('ana.r'), isNull);
      expect(gestion.validarEmail('', rol: Rol.tutor), isNotNull);
      expect(gestion.validarEmail('', rol: Rol.estudiante), isNull);
      expect(gestion.validarContrasena('corta', obligatoria: true), isNotNull);
    });
  });
}

void _pruebasDesactivacion() {
  group('HU-13: desactivar una cuenta', () {
    late GestionCuentasControlador gestion;
    late RepositorioAutenticacionSimulado autenticacion;
    late RepositorioEstudiantesSimulado estudiantes;
    late RepositorioCuentasSimulado cuentas;
    late AlmacenSimulado almacen;

    setUp(() {
      almacen = almacenDePrueba();
      autenticacion = RepositorioAutenticacionSimulado(almacen);
      estudiantes = RepositorioEstudiantesSimulado(almacen);
      cuentas = RepositorioCuentasSimulado(almacen);
      gestion = GestionCuentasControlador(
        cuentas: cuentas,
        autenticacion: autenticacion,
        estudiantes: estudiantes,
        aulas: RepositorioAulasSimulado(almacen),
      );
    });

    test('un tutor desactivado no puede entrar y se le explica', () async {
      final javier = (await cuentas.obtener('javier'))!;
      final error = await gestion.cambiarActivacion(
        javier,
        activa: false,
        idCuentaActual: 'admin',
      );
      expect(error, isNull);
      expect((await cuentas.obtener('javier'))!.activa, isFalse);
      expect((await cuentas.obtener('javier'))!.desactivadaEn, isNotNull);

      final login = LoginGestionControlador(autenticacion);
      final cuenta = await login.iniciarSesion(
        usuario: 'javier',
        contrasena: 'tutor1234',
      );
      expect(cuenta, isNull);
      expect(login.mensajeError, contains('desactivada'));
    });

    test('al reactivarla vuelve a poder entrar', () async {
      final javier = (await cuentas.obtener('javier'))!;
      await gestion.cambiarActivacion(
        javier,
        activa: false,
        idCuentaActual: 'admin',
      );
      await gestion.cambiarActivacion(
        (await cuentas.obtener('javier'))!,
        activa: true,
        idCuentaActual: 'admin',
      );
      final cuenta = await autenticacion.iniciarSesionGestion(
        usuario: 'javier',
        contrasena: 'tutor1234',
      );
      expect(cuenta?.activa, isTrue);
    });

    test('un alumno desactivado no sale en la tableta ni entra, '
        'pero conserva sus datos', () async {
      final diego = (await cuentas.obtener('e01'))!;
      await gestion.cambiarActivacion(
        diego,
        activa: false,
        idCuentaActual: 'admin',
      );

      final perfil = await estudiantes.obtener('e01');
      expect(perfil, isNotNull, reason: 'no se borran sus datos');
      expect(perfil!.activo, isFalse);

      final aula = (await RepositorioAulasSimulado(
        almacen,
      ).obtenerAulas()).firstWhere((a) => a.id == perfil.idAula);
      final tableta = EstudiantesAulaControlador(
        repositorio: estudiantes,
        aula: aula,
      );
      await tableta.cargar();
      expect(tableta.datos!.map((e) => e.id), isNot(contains('e01')));

      await expectLater(
        autenticacion.entrarEstudiante(
          estudiante: perfil,
          clave: const ClavePictogramas([
            PictogramaClave.sol,
            PictogramaClave.casa,
            PictogramaClave.perro,
            PictogramaClave.coche,
          ]),
        ),
        throwsA(isA<ErrorConMensaje>()),
      );
    });

    test('la administración no puede desactivar su propia cuenta', () async {
      final admin = (await cuentas.obtener('admin'))!;
      final error = await gestion.cambiarActivacion(
        admin,
        activa: false,
        idCuentaActual: 'admin',
      );
      expect(error, isNotNull);
      expect((await cuentas.obtener('admin'))!.activa, isTrue);
    });
  });
}
