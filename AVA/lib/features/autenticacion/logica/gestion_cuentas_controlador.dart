import '../../../core/constantes/paleta.dart';
import '../../../core/utilidades/controlador_carga.dart';
import '../../aulas/dominio/ficha_aula.dart';
import '../../aulas/dominio/repositorio_aulas.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../../perfil/dominio/repositorio_estudiantes.dart';
import '../dominio/clave_acceso.dart';
import '../dominio/cuenta.dart';
import '../dominio/repositorio_autenticacion.dart';
import '../dominio/repositorio_cuentas.dart';
import '../dominio/rol.dart';

/// Creación y edición de cuentas y roles (HU-01, HU-02).
class GestionCuentasControlador extends ControladorCarga<List<Cuenta>> {
  GestionCuentasControlador({
    required RepositorioCuentas cuentas,
    required RepositorioAutenticacion autenticacion,
    required RepositorioEstudiantes estudiantes,
    required RepositorioAulas aulas,
  }) : _cuentas = cuentas,
       _autenticacion = autenticacion,
       _estudiantes = estudiantes,
       _aulas = aulas;

  static final _formatoUsuario = RegExp(r'^[a-z0-9._-]{3,}$');
  static final _formatoEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static const longitudMinimaContrasena = 8;

  final RepositorioCuentas _cuentas;
  final RepositorioAutenticacion _autenticacion;
  final RepositorioEstudiantes _estudiantes;
  final RepositorioAulas _aulas;

  @override
  Future<List<Cuenta>> obtenerDatos() => _cuentas.listar();

  @override
  String get mensajeErrorCarga => 'No se han podido cargar las cuentas.';

  Future<List<Aula>> aulas() => _aulas.obtenerAulas();

  String? validarUsuario(String? valor) {
    final usuario = valor?.trim() ?? '';
    if (usuario.isEmpty) return 'Escribe un nombre de usuario.';
    if (!_formatoUsuario.hasMatch(usuario)) {
      return 'Usa al menos 3 letras minúsculas o números, sin espacios.';
    }
    return null;
  }

  String? validarNombre(String? valor) =>
      (valor == null || valor.trim().isEmpty) ? 'Escribe el nombre.' : null;

  String? validarEmail(String? valor, {required Rol rol}) {
    final email = valor?.trim() ?? '';
    if (email.isEmpty) {
      return rol == Rol.estudiante
          ? null
          : 'Escribe un correo para poder recuperar la contraseña.';
    }
    return _formatoEmail.hasMatch(email) ? null : 'Escribe un correo válido.';
  }

  String? validarContrasena(String? valor, {required bool obligatoria}) {
    final contrasena = valor ?? '';
    if (contrasena.isEmpty) {
      return obligatoria ? 'Escribe una contraseña.' : null;
    }
    return contrasena.length < longitudMinimaContrasena
        ? 'Usa al menos $longitudMinimaContrasena caracteres.'
        : null;
  }

  /// Crea una cuenta con su clave. Si es de estudiante crea también su
  /// perfil en [idAula]. Devuelve un mensaje de error o `null` si todo va
  /// bien.
  Future<String?> crear({
    required Cuenta cuenta,
    required ClaveAcceso clave,
    String? idAula,
  }) async {
    try {
      await _cuentas.crear(cuenta);
    } on CuentaDuplicada catch (error) {
      return error.toString();
    }

    await _autenticacion.guardarClave(cuenta.id, clave);
    if (cuenta.rol == Rol.estudiante) {
      final total = (await _estudiantes.listar()).length;
      await _estudiantes.guardar(
        Estudiante(
          id: cuenta.id,
          nombre: cuenta.nombre,
          idAula: idAula,
          metodoAcceso: clave.metodo,
          color: ColorPastel.paraIndice(total),
        ),
      );
    }
    await cargar();
    return null;
  }

  /// Actualiza nombre, rol y correo. Si [nuevaClave] no es `null`, cambia
  /// también la clave.
  Future<void> actualizar(Cuenta cuenta, {ClaveAcceso? nuevaClave}) async {
    await _cuentas.actualizar(cuenta);
    if (nuevaClave != null) {
      await _autenticacion.guardarClave(cuenta.id, nuevaClave);
    }
    if (cuenta.rol == Rol.estudiante) {
      final perfil = await _estudiantes.obtener(cuenta.id);
      if (perfil != null) {
        await _estudiantes.guardar(
          perfil.copyWith(
            nombre: cuenta.nombre,
            metodoAcceso: nuevaClave?.metodo,
          ),
        );
      }
    }
    await cargar();
  }
}
