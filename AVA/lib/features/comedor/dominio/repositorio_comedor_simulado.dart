import '../../../core/servicios/almacen_simulado.dart';
import 'comedor.dart';
import 'repositorio_comedor.dart';

/// Datos del comedor en el [AlmacenSimulado], para las pruebas.
class RepositorioComedorSimulado implements RepositorioComedor {
  RepositorioComedorSimulado(this._almacen, {DateTime Function()? reloj})
    : _reloj = reloj ?? DateTime.now;

  static const _asistencia = 'comedor';
  static const _dietas = 'dietas';
  static const _cambios = 'cambios_dieta';

  final AlmacenSimulado _almacen;
  final DateTime Function() _reloj;

  /// Un documento por aula y día, como en Firebase.
  static String claveDia(String idAula, DateTime fecha) =>
      '${idAula}_${fecha.year.toString().padLeft(4, '0')}-'
      '${fecha.month.toString().padLeft(2, '0')}-'
      '${fecha.day.toString().padLeft(2, '0')}';

  @override
  Future<Map<String, AsistenciaComedor>> asistencia({
    required String idAula,
    required DateTime fecha,
  }) async {
    final datos = _almacen.obtener(_asistencia, claveDia(idAula, fecha));
    final porEstudiante = datos?['asistencia'] as Map? ?? const {};
    return {
      for (final MapEntry(:key, :value) in porEstudiante.entries)
        key as String: AsistenciaComedor.fromMap(key, value as Map),
    };
  }

  @override
  Future<void> registrarAsistencia({
    required String idAula,
    required DateTime fecha,
    required AsistenciaComedor asistencia,
  }) async {
    final clave = claveDia(idAula, fecha);
    final anterior = _almacen.obtener(_asistencia, clave);
    _almacen.guardar(_asistencia, clave, {
      'aulaId': idAula,
      'asistencia': {
        ...?anterior?['asistencia'] as Map?,
        asistencia.idEstudiante: asistencia.toMap(),
      },
    });
  }

  @override
  Future<Dieta?> dieta(String idEstudiante) async {
    final datos = _almacen.obtener(_dietas, idEstudiante);
    return datos == null ? null : Dieta.fromMap(idEstudiante, datos);
  }

  @override
  Future<void> guardarDieta(Dieta dieta, {required String idActor}) async {
    _almacen.guardar(_dietas, dieta.idEstudiante, dieta.toMap());
    _almacen.guardar(_cambios, _almacen.nuevoId('cambio'), {
      'idEstudiante': dieta.idEstudiante,
      ...CambioDieta(
        momento: _reloj(),
        idActor: idActor,
        resumen: dieta.vacia ? 'Sin dieta especial' : dieta.resumen,
      ).toMap(),
    });
  }

  @override
  Future<List<CambioDieta>> cambiosDieta(String idEstudiante) async => [
    for (final (_, datos) in _almacen.listar(
      _cambios,
      donde: (d) => d['idEstudiante'] == idEstudiante,
    ))
      CambioDieta.fromMap(datos),
  ]..sort((a, b) => b.momento.compareTo(a.momento));
}
