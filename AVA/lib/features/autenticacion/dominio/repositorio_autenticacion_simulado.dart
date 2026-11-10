import '../../../core/servicios/almacen_simulado.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../../perfil/dominio/repositorio_estudiantes_simulado.dart';
import 'clave_acceso.dart';
import 'cuenta.dart';
import 'repositorio_autenticacion.dart';
import 'repositorio_cuentas_simulado.dart';

/// Credenciales guardadas en el [AlmacenSimulado], para las pruebas
/// automáticas. Las credenciales de prueba están en
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
  Future<void> prepararDispositivo() async {}

  @override
  Future<Cuenta?> iniciarSesionGestion({
    required String usuario,
    required String contrasena,
  }) async {
    final buscado = usuario.trim().toLowerCase();
    // Se puede entrar con el correo o con el identificador de la cuenta.
    final encontradas = _almacen.listar(
      RepositorioCuentasSimulado.coleccion,
      donde: (d) => (d['email'] as String?)?.toLowerCase() == buscado,
    );
    final id = encontradas.isEmpty ? buscado : encontradas.first.$1;
    final datos = _almacen.obtener(RepositorioCuentasSimulado.coleccion, id);
    if (datos == null) return null;

    final cuenta = Cuenta.fromMap(id, datos);
    if (!cuenta.esGestion) return null;
    return _clave(id) == ClaveContrasena(contrasena) ? cuenta : null;
  }

  @override
  Future<Estudiante?> entrarEstudiante({
    required Estudiante estudiante,
    required ClaveAcceso clave,
  }) async {
    if (_clave(estudiante.id) != clave) return null;
    final datos = _almacen.obtener(
      RepositorioEstudiantesSimulado.coleccion,
      estudiante.id,
    );
    return datos == null ? null : Estudiante.fromMap(estudiante.id, datos);
  }

  @override
  Future<void> guardarClave(String idCuenta, ClaveAcceso clave) async {
    _almacen.guardar(coleccion, idCuenta, clave.toMap());
  }

  @override
  Future<void> solicitarRecuperacion(String email) async {
    recuperacionesSolicitadas.add(email.trim().toLowerCase());
  }

  @override
  Future<void> cerrarSesion() async {}
}
