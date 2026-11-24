import 'comedor.dart';

/// Datos del comedor (HU-23 a HU-25).
///
/// Implementaciones: `RepositorioComedorSimulado` (pruebas) y
/// `RepositorioComedorFirebase`. La asistencia y las dietas van separadas:
/// quien registra la asistencia nunca ve las dietas (T-117).
abstract interface class RepositorioComedor {
  /// Asistencia de un aula en un día, por estudiante. Quien no aparece no
  /// ha respondido.
  Future<Map<String, AsistenciaComedor>> asistencia({
    required String idAula,
    required DateTime fecha,
  });

  /// Guarda si [asistencia] come en el centro ese día (HU-23, T-114).
  Future<void> registrarAsistencia({
    required String idAula,
    required DateTime fecha,
    required AsistenciaComedor asistencia,
  });

  /// Dieta autorizada de un estudiante, o `null` si no tiene (HU-24).
  Future<Dieta?> dieta(String idEstudiante);

  /// Guarda la dieta y añade el cambio a su registro (T-116, T-118).
  Future<void> guardarDieta(Dieta dieta, {required String idActor});

  /// Cambios de la dieta de un estudiante, del más reciente al más antiguo.
  Future<List<CambioDieta>> cambiosDieta(String idEstudiante);
}
