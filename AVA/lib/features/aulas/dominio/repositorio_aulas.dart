import 'ficha_aula.dart';

/// Acceso a los datos de las aulas.
///
/// Al conectar Firebase se implementará con Cloud Firestore.
abstract interface class RepositorioAulas {
  Future<List<Aula>> obtenerAulas();

  Future<Aula?> obtener(String id);

  /// Crea o actualiza el aula.
  Future<void> guardar(Aula aula);

  /// Identificador libre para un aula nueva.
  String nuevoId();
}
