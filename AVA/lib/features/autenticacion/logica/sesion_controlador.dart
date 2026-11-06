import 'package:flutter/foundation.dart';

import '../../perfil/dominio/estudiante.dart';

/// Guarda quién ha iniciado sesión. Es único para toda la aplicación.
class SesionControlador extends ChangeNotifier {
  Estudiante? _estudiante;
  String? _usuarioAdministrador;

  Estudiante? get estudiante => _estudiante;
  String? get usuarioAdministrador => _usuarioAdministrador;
  bool get haySesion => _estudiante != null || _usuarioAdministrador != null;

  void iniciarComoEstudiante(Estudiante estudiante) {
    _estudiante = estudiante;
    _usuarioAdministrador = null;
    notifyListeners();
  }

  void iniciarComoAdministrador(String usuario) {
    _usuarioAdministrador = usuario;
    _estudiante = null;
    notifyListeners();
  }

  void cerrarSesion() {
    _estudiante = null;
    _usuarioAdministrador = null;
    notifyListeners();
  }
}
