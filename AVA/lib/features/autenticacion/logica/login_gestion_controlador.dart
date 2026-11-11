import 'package:flutter/foundation.dart';

import '../../../core/utilidades/controlador_carga.dart';
import '../dominio/cuenta.dart';
import '../dominio/repositorio_autenticacion.dart';

/// Lógica del inicio de sesión de tutores y administradores (HU-18).
class LoginGestionControlador extends ChangeNotifier {
  LoginGestionControlador(this._repositorio);

  final RepositorioAutenticacion _repositorio;

  bool _comprobando = false;
  String? _mensajeError;

  bool get comprobando => _comprobando;
  String? get mensajeError => _mensajeError;

  String? validarUsuario(String? valor) =>
      (valor == null || valor.trim().isEmpty) ? 'Escribe tu correo.' : null;

  String? validarContrasena(String? valor) =>
      (valor == null || valor.isEmpty) ? 'Escribe tu contraseña.' : null;

  /// Devuelve la cuenta si las credenciales son correctas, o `null`.
  Future<Cuenta?> iniciarSesion({
    required String usuario,
    required String contrasena,
  }) async {
    if (_comprobando) return null;

    _comprobando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      final cuenta = await _repositorio.iniciarSesionGestion(
        usuario: usuario.trim(),
        contrasena: contrasena,
      );
      if (cuenta == null) {
        _mensajeError = 'El correo o la contraseña no son correctos.';
      }
      return cuenta;
    } on ErrorConMensaje catch (error) {
      _mensajeError = error.mensaje;
      return null;
    } on Exception {
      _mensajeError = 'No se ha podido comprobar. Inténtalo de nuevo.';
      return null;
    } finally {
      _comprobando = false;
      notifyListeners();
    }
  }
}
