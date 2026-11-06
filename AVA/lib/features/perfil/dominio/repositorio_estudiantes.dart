import 'estudiante.dart';
import 'preferencias_accesibilidad.dart';

/// Acceso a los datos de los estudiantes.
///
/// Al conectar Firebase se implementará con Cloud Firestore.
abstract interface class RepositorioEstudiantes {
  Future<List<Estudiante>> obtenerEstudiantesDeAula(String idAula);

  Future<void> guardarPreferencias(
    String idEstudiante,
    PreferenciasAccesibilidad preferencias,
  );
}
