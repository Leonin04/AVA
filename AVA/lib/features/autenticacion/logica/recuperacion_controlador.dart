import 'package:flutter/foundation.dart';

import '../dominio/repositorio_autenticacion.dart';

/// Recuperación de la contraseña de tutores y administradores (HU-18).
class RecuperacionControlador extends ChangeNotifier {
  RecuperacionControlador(this._repositorio);

  static final _formatoEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final RepositorioAutenticacion _repositorio;

  bool _enviando = false;
  bool _enviado = false;
  String? _mensajeError;

  bool get enviando => _enviando;
  bool get enviado => _enviado;
  String? get mensajeError => _mensajeError;

  String? validarEmail(String? valor) {
    final email = valor?.trim() ?? '';
    if (email.isEmpty) return 'Escribe tu correo.';
    if (!_formatoEmail.hasMatch(email)) {
      return 'Escribe un correo válido, por ejemplo nombre@colegio.es.';
    }
    return null;
  }

  /// Pide el enlace de recuperación. Por seguridad, el mensaje es el mismo
  /// exista o no una cuenta con ese correo.
  Future<void> enviar(String email) async {
    if (_enviando) return;

    _enviando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      await _repositorio.solicitarRecuperacion(email.trim());
      _enviado = true;
    } on Exception {
      _mensajeError = 'No se ha podido enviar. Inténtalo de nuevo.';
    } finally {
      _enviando = false;
      notifyListeners();
    }
  }
}
