import '../../../core/utilidades/controlador_carga.dart';
import '../../autenticacion/dominio/cuenta.dart';
import '../../autenticacion/dominio/repositorio_cuentas.dart';
import '../../autenticacion/dominio/rol.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../../perfil/dominio/repositorio_estudiantes.dart';
import '../dominio/ficha_aula.dart';
import '../dominio/repositorio_aulas.dart';

/// Datos que necesita la gestión de aulas.
typedef DatosAulas = ({
  List<Aula> aulas,
  List<Cuenta> tutores,
  List<Estudiante> estudiantes,
});

/// Creación de aulas y asignación de alumnos y tutor responsable (HU-16).
class GestionAulasControlador extends ControladorCarga<DatosAulas> {
  GestionAulasControlador({
    required RepositorioAulas aulas,
    required RepositorioCuentas cuentas,
    required RepositorioEstudiantes estudiantes,
  }) : _aulas = aulas,
       _cuentas = cuentas,
       _estudiantes = estudiantes;

  final RepositorioAulas _aulas;
  final RepositorioCuentas _cuentas;
  final RepositorioEstudiantes _estudiantes;

  @override
  Future<DatosAulas> obtenerDatos() async => (
    aulas: await _aulas.obtenerAulas(),
    tutores: [
      for (final c in await _cuentas.listar())
        if (c.rol == Rol.tutor) c,
    ],
    estudiantes: await _estudiantes.listar(),
  );

  @override
  String get mensajeErrorCarga => 'No se han podido cargar las aulas.';

  String nuevoId() => _aulas.nuevoId();

  String? validarNombre(String? valor, {required String idAula}) {
    final nombre = valor?.trim() ?? '';
    if (nombre.isEmpty) return 'Escribe el nombre del aula.';
    final repetido =
        datos?.aulas.any(
          (a) =>
              a.id != idAula && a.nombre.toLowerCase() == nombre.toLowerCase(),
        ) ??
        false;
    return repetido ? 'Ya hay un aula con ese nombre.' : null;
  }

  /// Guarda el aula y deja en ella exactamente a [idsAlumnos]. Un alumno
  /// solo puede estar en un aula, así que se mueve si estaba en otra.
  Future<void> guardar(Aula aula, Set<String> idsAlumnos) async {
    await _aulas.guardar(aula);
    for (final estudiante in await _estudiantes.listar()) {
      final elegido = idsAlumnos.contains(estudiante.id);
      if (elegido && estudiante.idAula != aula.id) {
        await _estudiantes.guardar(estudiante.copyWith(idAula: aula.id));
      } else if (!elegido && estudiante.idAula == aula.id) {
        await _estudiantes.guardar(estudiante.copyWith(quitarAula: true));
      }
    }
    await cargar();
  }
}
