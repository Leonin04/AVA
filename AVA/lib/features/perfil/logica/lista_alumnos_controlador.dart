import '../../../core/utilidades/controlador_carga.dart';
import '../../autenticacion/dominio/cuenta.dart';
import '../../autenticacion/logica/permisos.dart';
import '../../aulas/dominio/ficha_aula.dart';
import '../../aulas/dominio/repositorio_aulas.dart';
import '../dominio/perfil_estudiante.dart';
import '../dominio/repositorio_estudiantes.dart';

/// Alumno con el aula a la que pertenece.
typedef AlumnoConAula = ({Estudiante estudiante, Aula? aula});

/// Alumnos que la cuenta puede gestionar: todos para la administración y
/// solo los de sus aulas para un tutor (HU-17).
class ListaAlumnosControlador extends ControladorCarga<List<AlumnoConAula>> {
  ListaAlumnosControlador({
    required RepositorioEstudiantes estudiantes,
    required RepositorioAulas aulas,
    required this.cuenta,
  }) : _estudiantes = estudiantes,
       _aulas = aulas;

  final RepositorioEstudiantes _estudiantes;
  final RepositorioAulas _aulas;
  final Cuenta cuenta;

  @override
  Future<List<AlumnoConAula>> obtenerDatos() async {
    final aulas = await _aulas.obtenerAulas();
    final visibles = Permisos.estudiantesVisibles(
      cuenta,
      await _estudiantes.listar(),
      aulas,
    );
    return [
      for (final estudiante in visibles)
        (
          estudiante: estudiante,
          aula: aulas.where((a) => a.id == estudiante.idAula).firstOrNull,
        ),
    ];
  }

  @override
  String get mensajeErrorCarga => 'No se han podido cargar los alumnos.';
}
