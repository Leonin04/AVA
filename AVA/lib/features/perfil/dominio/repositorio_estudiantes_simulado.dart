import '../../autenticacion/dominio/metodo_acceso.dart';
import 'estudiante.dart';
import 'preferencias_accesibilidad.dart';
import 'repositorio_estudiantes.dart';

/// Estudiantes de prueba mientras no se conecta la base de datos.
///
/// Los cambios de preferencias se guardan en memoria y se pierden al cerrar
/// la aplicación.
class RepositorioEstudiantesSimulado implements RepositorioEstudiantes {
  final Map<String, Estudiante> _estudiantes = {
    for (final estudiante in _estudiantesIniciales) estudiante.id: estudiante,
  };

  static const _estudiantesIniciales = [
    Estudiante(
      id: 'e01',
      nombre: 'Diego',
      idAula: '1A',
      metodoAcceso: AccesoConPictogramas(longitudClave: 4),
    ),
    Estudiante(
      id: 'e02',
      nombre: 'Carlos',
      idAula: '1A',
      metodoAcceso: AccesoConContrasena(),
    ),
    Estudiante(
      id: 'e03',
      nombre: 'Lucía',
      idAula: '1A',
      metodoAcceso: AccesoConPictogramas(longitudClave: 3),
    ),
    Estudiante(
      id: 'e04',
      nombre: 'Álex',
      idAula: '1A',
      metodoAcceso: AccesoConPictogramas(longitudClave: 6),
      preferencias: PreferenciasAccesibilidad(textoGrande: true),
    ),
    Estudiante(
      id: 'e05',
      nombre: 'Marta',
      idAula: '1A',
      metodoAcceso: AccesoConContrasena(),
    ),
    Estudiante(
      id: 'e06',
      nombre: 'Pablo',
      idAula: '1A',
      metodoAcceso: AccesoConPictogramas(longitudClave: 5),
    ),
    Estudiante(
      id: 'e07',
      nombre: 'Sara',
      idAula: '1B',
      metodoAcceso: AccesoConContrasena(),
    ),
    Estudiante(
      id: 'e08',
      nombre: 'Hugo',
      idAula: '1B',
      metodoAcceso: AccesoConPictogramas(longitudClave: 3),
    ),
    Estudiante(
      id: 'e09',
      nombre: 'Elena',
      idAula: '1B',
      metodoAcceso: AccesoConPictogramas(longitudClave: 4),
    ),
    Estudiante(
      id: 'e10',
      nombre: 'Iván',
      idAula: '2A',
      metodoAcceso: AccesoConContrasena(),
    ),
    Estudiante(
      id: 'e11',
      nombre: 'Nerea',
      idAula: '2A',
      metodoAcceso: AccesoConPictogramas(longitudClave: 4),
    ),
    Estudiante(
      id: 'e12',
      nombre: 'Óscar',
      idAula: '2A',
      metodoAcceso: AccesoConPictogramas(longitudClave: 3),
    ),
    Estudiante(
      id: 'e13',
      nombre: 'Laura',
      idAula: '2B',
      metodoAcceso: AccesoConPictogramas(longitudClave: 5),
    ),
    Estudiante(
      id: 'e14',
      nombre: 'Mario',
      idAula: '2B',
      metodoAcceso: AccesoConContrasena(),
    ),
    Estudiante(
      id: 'e15',
      nombre: 'Irene',
      idAula: '2B',
      metodoAcceso: AccesoConPictogramas(longitudClave: 4),
    ),
  ];

  @override
  Future<List<Estudiante>> obtenerEstudiantesDeAula(String idAula) async {
    return _estudiantes.values
        .where((estudiante) => estudiante.idAula == idAula)
        .toList(growable: false);
  }

  @override
  Future<void> guardarPreferencias(
    String idEstudiante,
    PreferenciasAccesibilidad preferencias,
  ) async {
    final estudiante = _estudiantes[idEstudiante];
    if (estudiante == null) {
      throw StateError('No existe el estudiante $idEstudiante');
    }
    _estudiantes[idEstudiante] = estudiante.copyWith(preferencias: preferencias);
  }
}
