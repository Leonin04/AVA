import 'package:flutter/foundation.dart';

import '../dominio/estudiante.dart';
import '../dominio/preferencias_accesibilidad.dart';
import '../dominio/repositorio_estudiantes.dart';

/// Preferencias de accesibilidad activas en la aplicación (HU-14).
///
/// Es único para toda la app: al cambiar, el tema se reconstruye y afecta a
/// todas las pantallas. Los cambios se guardan en el perfil del estudiante.
class PreferenciasControlador extends ChangeNotifier {
  PreferenciasControlador(this._repositorio);

  final RepositorioEstudiantes _repositorio;

  PreferenciasAccesibilidad _preferencias = const PreferenciasAccesibilidad();
  String? _idEstudiante;

  PreferenciasAccesibilidad get preferencias => _preferencias;

  /// Aplica las preferencias guardadas del estudiante que inicia sesión.
  void aplicarDeEstudiante(Estudiante estudiante) {
    _idEstudiante = estudiante.id;
    _preferencias = estudiante.preferencias;
    notifyListeners();
  }

  /// Vuelve al aspecto por defecto, por ejemplo al cerrar sesión.
  void restablecer() {
    _idEstudiante = null;
    _preferencias = const PreferenciasAccesibilidad();
    notifyListeners();
  }

  Future<void> alternarTextoGrande() => _actualizar(
        _preferencias.copyWith(textoGrande: !_preferencias.textoGrande),
      );

  Future<void> alternarAltoContraste() => _actualizar(
        _preferencias.copyWith(altoContraste: !_preferencias.altoContraste),
      );

  Future<void> alternarModoOscuro() => _actualizar(
        _preferencias.copyWith(modoOscuro: !_preferencias.modoOscuro),
      );

  Future<void> elegirColor(ColorTema color) =>
      _actualizar(_preferencias.copyWith(color: color));

  Future<void> _actualizar(PreferenciasAccesibilidad nuevas) async {
    _preferencias = nuevas;
    notifyListeners();

    final id = _idEstudiante;
    if (id != null) await _repositorio.guardarPreferencias(id, nuevas);
  }
}
