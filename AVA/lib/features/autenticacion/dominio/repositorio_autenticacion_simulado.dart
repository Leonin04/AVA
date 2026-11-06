import '../../../core/servicios/almacen_simulado.dart';
import 'clave_acceso.dart';
import 'cuenta.dart';
import 'repositorio_autenticacion.dart';
import 'repositorio_cuentas_simulado.dart';

/// Credenciales guardadas en el [AlmacenSimulado] mientras no se conecta
/// Firebase Authentication. Las credenciales de prueba están en
/// `lib/app/datos_iniciales.dart`.
class RepositorioAutenticacionSimulado implements RepositorioAutenticacion {
  RepositorioAutenticacionSimulado(this._almacen);

  static const coleccion = 'credenciales';

  final AlmacenSimulado _almacen;

  /// Correos a los que se ha pedido recuperar la contraseña (para pruebas).
  final List<String> recuperacionesSolicitadas = [];

  ClaveAcceso? _clave(String idCuenta) =>
      ClaveAcceso.fromMap(_almacen.obtener(coleccion, idCuenta));

  @override
  Future<Cuenta?> iniciarSesionGestion({
    required String usuario,
    required String contrasena,
  }) async {
    final datos = _almacen.obtener(
      RepositorioCuentasSimulado.coleccion,
      usuario,
    );
    if (datos == null) return null;

    final cuenta = Cuenta.fromMap(usuario, datos);
    if (!cuenta.esGestion) return null;
    return _clave(usuario) == ClaveContrasena(contrasena) ? cuenta : null;
  }

  @override
  Future<bool> validarEstudiante({
    required String idEstudiante,
    required ClaveAcceso clave,
  }) async => _clave(idEstudiante) == clave;

  @override
  Future<void> guardarClave(String idCuenta, ClaveAcceso clave) async {
    _almacen.guardar(coleccion, idCuenta, clave.toMap());
  }

  @override
  Future<void> solicitarRecuperacion(String email) async {
    recuperacionesSolicitadas.add(email.trim().toLowerCase());
  }
}
