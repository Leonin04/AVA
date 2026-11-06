import 'package:flutter/foundation.dart';

import '../../perfil/dominio/estudiante.dart';
import '../dominio/cuenta.dart';
import '../dominio/rol.dart';

/// Guarda quién ha iniciado sesión. Es único para toda la aplicación.
class SesionControlador extends ChangeNotifier {
  Cuenta? _cuenta;
  Estudiante? _estudiante;

  /// Cuenta con la sesión iniciada (de cualquier rol).
  Cuenta? get cuenta => _cuenta;

  /// Perfil del estudiante, si la sesión es de un estudiante.
  Estudiante? get estudiante => _estudiante;

  bool get haySesion => _cuenta != null;

  void iniciarComoEstudiante(Estudiante estudiante) {
    _cuenta = Cuenta(
      id: estudiante.id,
      nombre: estudiante.nombre,
      rol: Rol.estudiante,
    );
    _estudiante = estudiante;
    notifyListeners();
  }

  void iniciarGestion(Cuenta cuenta) {
    assert(cuenta.esGestion, 'Solo tutores y administradores');
    _cuenta = cuenta;
    _estudiante = null;
    notifyListeners();
  }

  /// Actualiza el perfil del estudiante con sesión, por ejemplo tras cambiar
  /// sus preferencias.
  void actualizarEstudiante(Estudiante estudiante) {
    if (_estudiante?.id != estudiante.id) return;
    _estudiante = estudiante;
    notifyListeners();
  }

  void cerrarSesion() {
    _cuenta = null;
    _estudiante = null;
    notifyListeners();
  }
}
