import 'perfil_estudiante.dart';

/// Acceso a los perfiles de los estudiantes.
///
/// Al conectar Firebase se implementará con Cloud Firestore.
abstract interface class RepositorioEstudiantes {
  Future<Estudiante?> obtener(String id);

  /// Todos los estudiantes, o solo los de [idAula] si se indica.
  Future<List<Estudiante>> listar({String? idAula});

  /// Crea o actualiza el perfil.
  Future<void> guardar(Estudiante estudiante);
}
