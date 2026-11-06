import 'package:ava/features/autenticacion/dominio/pictograma_clave.dart';
import 'package:ava/features/autenticacion/dominio/repositorio_autenticacion_simulado.dart';
import 'package:ava/features/autenticacion/logica/login_estudiante_controlador.dart';
import 'package:ava/features/perfil/dominio/repositorio_estudiantes_simulado.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas_prueba.dart';

/// HU-08: inicio de sesión accesible del estudiante.
void main() {
  final almacen = almacenDePrueba();
  final autenticacion = RepositorioAutenticacionSimulado(almacen);
  final estudiantes = RepositorioEstudiantesSimulado(almacen);

  Future<LoginEstudianteControlador> controladorDe(String id) async =>
      LoginEstudianteControlador(
        repositorio: autenticacion,
        estudiante: (await estudiantes.obtener(id))!,
      );

  group('Con pictogramas', () {
    test('la clave correcta da acceso al rellenar el último hueco', () async {
      final login = await controladorDe('e03'); // Lucía, 3 pictogramas.

      expect(login.longitudClave, 3);
      expect(await login.anadirPictograma(PictogramaClave.sol), isFalse);
      expect(await login.anadirPictograma(PictogramaClave.manzana), isFalse);
      expect(await login.anadirPictograma(PictogramaClave.mariposa), isTrue);
      expect(login.mensajeError, isNull);
    });

    test(
      'una clave incorrecta vacía los huecos y avisa con claridad',
      () async {
        final login = await controladorDe('e03');

        await login.anadirPictograma(PictogramaClave.coche);
        await login.anadirPictograma(PictogramaClave.coche);
        final correcto = await login.anadirPictograma(PictogramaClave.coche);

        expect(correcto, isFalse);
        expect(login.pictogramas, isEmpty);
        expect(
          login.mensajeError,
          LoginEstudianteControlador.mensajeIncorrecto,
        );
      },
    );

    test('«Borrar» quita el último pictograma', () async {
      final login = await controladorDe('e03');

      await login.anadirPictograma(PictogramaClave.sol);
      await login.anadirPictograma(PictogramaClave.flor);
      login.borrarUltimo();

      expect(login.pictogramas, [PictogramaClave.sol]);
    });
  });

  group('Con número (PIN)', () {
    test('se comprueba al pulsar la cuarta cifra', () async {
      final login = await controladorDe('e05'); // Marta.

      expect(login.longitudClave, 4);
      for (final cifra in [1, 2, 3]) {
        expect(await login.anadirDigito(cifra), isFalse);
      }
      expect(await login.anadirDigito(4), isTrue);
    });

    test('un número incorrecto se vacía', () async {
      final login = await controladorDe('e05');
      for (final cifra in [9, 9, 9, 9]) {
        await login.anadirDigito(cifra);
      }
      expect(login.digitos, isEmpty);
      expect(login.mensajeError, isNotNull);
    });
  });

  group('Con contraseña', () {
    test('acepta la correcta y rechaza la vacía o la incorrecta', () async {
      final login = await controladorDe('e02'); // Carlos.

      expect(await login.comprobarContrasena(''), isFalse);
      expect(login.mensajeError, 'Escribe tu contraseña.');
      expect(await login.comprobarContrasena('0000'), isFalse);
      expect(await login.comprobarContrasena('1234'), isTrue);
    });
  });
}
