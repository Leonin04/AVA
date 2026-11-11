import 'package:ava/core/servicios/autenticacion.dart';
import 'package:ava/features/perfil/dominio/estudiante.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('HU-09: correo interno y clave según el método', () {
    expect(Autenticacion.correoEstudiante(' Pablo '), 'pablo@alumnos.ava.test');
    expect(Autenticacion.claveDe(MetodoLogin.pin, '1234'), 'ava-pin-1234');
    expect(
      Autenticacion.claveDe(MetodoLogin.pictograma, ['sol', 'perro', 'flor']),
      'ava-pic-sol-perro-flor',
    );
    expect(
      Autenticacion.claveDe(MetodoLogin.contrasena, 'lucia123'),
      'lucia123',
    );
  });
}
