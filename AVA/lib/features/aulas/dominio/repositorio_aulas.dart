import 'aula.dart';

/// Acceso a los datos de las aulas.
///
/// Por ahora solo existe [RepositorioAulasSimulado]; al conectar Firebase se
/// añadirá una implementación con Cloud Firestore sin tocar el resto de capas.
abstract interface class RepositorioAulas {
  Future<List<Aula>> obtenerAulas();
}
