import 'package:ava/features/autenticacion/dominio/metodo_acceso.dart';
import 'package:ava/features/autenticacion/dominio/pictograma_clave.dart';
import 'package:ava/features/autenticacion/dominio/repositorio_autenticacion_simulado.dart';
import 'package:ava/features/autenticacion/logica/login_estudiante_controlador.dart';
import 'package:ava/features/perfil/dominio/estudiante.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repositorio = RepositorioAutenticacionSimulado();

  group('Login con pictogramas', () {
    const lucia = Estudiante(
      id: 'e03',
      nombre: 'Lucía',
      idAula: '1A',
      metodoAcceso: AccesoConPictogramas(longitudClave: 3),
    );

    test('la clave correcta da acceso al rellenar el último hueco', () async {
      final controlador =
          LoginEstudianteControlador(repositorio: repositorio, estudiante: lucia);

      expect(controlador.longitudClave, 3);
      expect(await controlador.anadirPictograma(PictogramaClave.sol), isFalse);
      expect(await controlador.anadirPictograma(PictogramaClave.luna), isFalse);
      expect(
        await controlador.anadirPictograma(PictogramaClave.estrella),
        isTrue,
      );
      expect(controlador.mensajeError, isNull);
    });

    test('una clave incorrecta vacía los huecos y avisa', () async {
      final controlador =
          LoginEstudianteControlador(repositorio: repositorio, estudiante: lucia);

      await controlador.anadirPictograma(PictogramaClave.coche);
      await controlador.anadirPictograma(PictogramaClave.coche);
      final correcto = await controlador.anadirPictograma(PictogramaClave.coche);

      expect(correcto, isFalse);
      expect(controlador.seleccion, isEmpty);
      expect(controlador.mensajeError, isNotNull);
    });

    test('borrar quita el último pictograma', () async {
      final controlador =
          LoginEstudianteControlador(repositorio: repositorio, estudiante: lucia);

      await controlador.anadirPictograma(PictogramaClave.sol);
      await controlador.anadirPictograma(PictogramaClave.flor);
      controlador.borrarUltimoPictograma();

      expect(controlador.seleccion, [PictogramaClave.sol]);
    });
  });

  group('Login con contraseña', () {
    const carlos = Estudiante(
      id: 'e02',
      nombre: 'Carlos',
      idAula: '1A',
      metodoAcceso: AccesoConContrasena(),
    );

    test('acepta la contraseña correcta', () async {
      final controlador = LoginEstudianteControlador(
        repositorio: repositorio,
        estudiante: carlos,
      );

      expect(await controlador.comprobarContrasena('1234'), isTrue);
    });

    test('rechaza una contraseña vacía o incorrecta', () async {
      final controlador = LoginEstudianteControlador(
        repositorio: repositorio,
        estudiante: carlos,
      );

      expect(await controlador.comprobarContrasena(''), isFalse);
      expect(controlador.mensajeError, 'Escribe tu contraseña');
      expect(await controlador.comprobarContrasena('0000'), isFalse);
      expect(controlador.mensajeError, isNotNull);
    });
  });
}
