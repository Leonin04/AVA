import '../../../core/utilidades/controlador_carga.dart';
import '../../perfil/dominio/estudiante.dart';
import '../../perfil/dominio/repositorio_estudiantes.dart';
import '../dominio/aula.dart';

/// Carga los estudiantes de un aula.
class EstudiantesAulaControlador extends ControladorCarga<List<Estudiante>> {
  EstudiantesAulaControlador({
    required RepositorioEstudiantes repositorio,
    required this.aula,
  }) : _repositorio = repositorio;

  final RepositorioEstudiantes _repositorio;
  final Aula aula;

  @override
  Future<List<Estudiante>> obtenerDatos() =>
      _repositorio.obtenerEstudiantesDeAula(aula.id);

  @override
  String get mensajeErrorCarga => 'No se han podido cargar los alumnos.';
}
