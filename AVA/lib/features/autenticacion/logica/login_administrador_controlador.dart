import 'package:flutter/foundation.dart';

import '../dominio/repositorio_autenticacion.dart';

/// Lógica del inicio de sesión de profesorado y administración (HU-17).
class LoginAdministradorControlador extends ChangeNotifier {
  LoginAdministradorControlador(this._repositorio);

  final RepositorioAutenticacion _repositorio;

  bool _comprobando = false;
  String? _mensajeError;

  bool get comprobando => _comprobando;
  String? get mensajeError => _mensajeError;

  String? validarUsuario(String? valor) =>
      (valor == null || valor.trim().isEmpty) ? 'Escribe tu usuario' : null;

  String? validarContrasena(String? valor) =>
      (valor == null || valor.isEmpty) ? 'Escribe tu contraseña' : null;

  /// Devuelve `true` si las credenciales son correctas.
  Future<bool> iniciarSesion({
    required String usuario,
    required String contrasena,
  }) async {
    if (_comprobando) return false;

    _comprobando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      final correcto = await _repositorio.validarAdministrador(
        usuario: usuario.trim(),
        contrasena: contrasena,
      );
      if (!correcto) _mensajeError = 'Usuario o contraseña incorrectos';
      return correcto;
    } on Exception {
      _mensajeError = 'No se ha podido comprobar. Inténtalo de nuevo.';
      return false;
    } finally {
      _comprobando = false;
      notifyListeners();
    }
  }
}
