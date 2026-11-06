import '../core/constantes/paleta.dart';
import '../core/constantes/pictogramas.dart';
import '../core/servicios/almacen_simulado.dart';
import '../features/autenticacion/dominio/clave_acceso.dart';
import '../features/autenticacion/dominio/cuenta.dart';
import '../features/autenticacion/dominio/metodo_acceso.dart';
import '../features/autenticacion/dominio/pictograma_clave.dart';
import '../features/autenticacion/dominio/repositorio_autenticacion_simulado.dart';
import '../features/autenticacion/dominio/repositorio_cuentas_simulado.dart';
import '../features/autenticacion/dominio/rol.dart';
import '../features/aulas/dominio/aula.dart';
import '../features/aulas/dominio/repositorio_aulas_simulado.dart';
import '../features/perfil/dominio/estudiante.dart';
import '../features/perfil/dominio/preferencias_accesibilidad.dart';
import '../features/perfil/dominio/repositorio_estudiantes_simulado.dart';

/// Datos de prueba mientras no se conecta Firebase.
///
/// Credenciales:
/// - Administradora: usuario `admin`, contraseña `admin1234`.
/// - Tutores: `javier` (1ºA y 1ºB) y `ana` (2ºA y 2ºB), contraseña
///   `tutor1234`.
/// - Estudiantes con contraseña o con número (PIN): `1234`.
/// - Estudiantes con pictogramas: los N primeros pictogramas en orden
///   (sol, manzana, mariposa, flor, coche, perro), siendo N la longitud de
///   su clave.
void cargarDatosIniciales(AlmacenSimulado almacen) {
  void cuenta(Cuenta cuenta, ClaveAcceso clave) {
    almacen.guardar(
      RepositorioCuentasSimulado.coleccion,
      cuenta.id,
      cuenta.toMap(),
    );
    almacen.guardar(
      RepositorioAutenticacionSimulado.coleccion,
      cuenta.id,
      clave.toMap(),
    );
  }

  cuenta(
    const Cuenta(
      id: 'admin',
      nombre: 'Lucía Romero',
      rol: Rol.administrador,
      email: 'admin@colegio.example',
    ),
    const ClaveContrasena('admin1234'),
  );
  cuenta(
    const Cuenta(
      id: 'javier',
      nombre: 'Javier Morales',
      rol: Rol.tutor,
      email: 'javier@colegio.example',
    ),
    const ClaveContrasena('tutor1234'),
  );
  cuenta(
    const Cuenta(
      id: 'ana',
      nombre: 'Ana Ruiz',
      rol: Rol.tutor,
      email: 'ana@colegio.example',
    ),
    const ClaveContrasena('tutor1234'),
  );

  const aulas = [
    Aula(
      id: '1A',
      nombre: '1ºA',
      color: ColorPastel.amarillo,
      pictograma: Pictogramas.sol,
      idTutor: 'javier',
    ),
    Aula(
      id: '1B',
      nombre: '1ºB',
      color: ColorPastel.menta,
      pictograma: Pictogramas.flor,
      idTutor: 'javier',
    ),
    Aula(
      id: '2A',
      nombre: '2ºA',
      color: ColorPastel.cielo,
      pictograma: Pictogramas.mariposa,
      idTutor: 'ana',
    ),
    Aula(
      id: '2B',
      nombre: '2ºB',
      color: ColorPastel.lavanda,
      pictograma: Pictogramas.musica,
      idTutor: 'ana',
    ),
  ];
  for (final aula in aulas) {
    almacen.guardar(RepositorioAulasSimulado.coleccion, aula.id, aula.toMap());
  }

  final estudiantes = [
    (
      'e01',
      'Diego',
      '1A',
      const AccesoConPictogramas(longitudClave: 4),
      const PreferenciasAccesibilidad(),
      true,
    ),
    (
      'e02',
      'Carlos',
      '1A',
      const AccesoConContrasena(),
      const PreferenciasAccesibilidad(
        tamanoTexto: TamanoTexto.grande,
        filtroAntitemblor: true,
      ),
      true,
    ),
    (
      'e03',
      'Lucía',
      '1A',
      const AccesoConPictogramas(longitudClave: 3),
      const PreferenciasAccesibilidad(color: ColorPastel.rosa),
      false,
    ),
    (
      'e04',
      'Álex',
      '1A',
      const AccesoConPictogramas(longitudClave: 3),
      const PreferenciasAccesibilidad(
        tamanoTexto: TamanoTexto.grande,
        leerEnVoz: true,
        color: ColorPastel.menta,
      ),
      false,
    ),
    (
      'e05',
      'Marta',
      '1A',
      const AccesoConPin(),
      const PreferenciasAccesibilidad(),
      false,
    ),
    (
      'e06',
      'Pablo',
      '1A',
      const AccesoConPictogramas(longitudClave: 5),
      const PreferenciasAccesibilidad(),
      false,
    ),
    (
      'e07',
      'Sara',
      '1B',
      const AccesoConContrasena(),
      const PreferenciasAccesibilidad(),
      true,
    ),
    (
      'e08',
      'Hugo',
      '1B',
      const AccesoConPictogramas(longitudClave: 3),
      const PreferenciasAccesibilidad(),
      false,
    ),
    (
      'e09',
      'Elena',
      '1B',
      const AccesoConPin(),
      const PreferenciasAccesibilidad(),
      false,
    ),
    (
      'e10',
      'Iván',
      '2A',
      const AccesoConContrasena(),
      const PreferenciasAccesibilidad(),
      true,
    ),
    (
      'e11',
      'Nerea',
      '2A',
      const AccesoConPictogramas(longitudClave: 4),
      const PreferenciasAccesibilidad(),
      false,
    ),
    (
      'e12',
      'Óscar',
      '2A',
      const AccesoConPin(),
      const PreferenciasAccesibilidad(),
      false,
    ),
    (
      'e13',
      'Samuel',
      '2B',
      const AccesoConPictogramas(longitudClave: 3),
      const PreferenciasAccesibilidad(
        leerEnVoz: true,
        tamanoTexto: TamanoTexto.muyGrande,
      ),
      false,
    ),
    (
      'e14',
      'Mario',
      '2B',
      const AccesoConContrasena(),
      const PreferenciasAccesibilidad(),
      true,
    ),
    (
      'e15',
      'Irene',
      '2B',
      const AccesoConPictogramas(longitudClave: 4),
      const PreferenciasAccesibilidad(),
      false,
    ),
  ];

  for (var i = 0; i < estudiantes.length; i++) {
    final (id, nombre, idAula, metodo, preferencias, autorizado) =
        estudiantes[i];
    final estudiante = Estudiante(
      id: id,
      nombre: nombre,
      idAula: idAula,
      metodoAcceso: metodo,
      color: ColorPastel.paraIndice(i),
      preferencias: preferencias,
      puedeModificarPreferencias: autorizado,
      puedeGestionarTareas: autorizado,
    );
    almacen.guardar(
      RepositorioEstudiantesSimulado.coleccion,
      id,
      estudiante.toMap(),
    );

    final clave = switch (metodo) {
      AccesoConContrasena() => const ClaveContrasena('1234'),
      AccesoConPin() => const ClavePin('1234'),
      AccesoConPictogramas(:final longitudClave) => ClavePictogramas(
        PictogramaClave.values.take(longitudClave).toList(),
      ),
    };
    cuenta(Cuenta(id: id, nombre: nombre, rol: Rol.estudiante), clave);
  }
}
