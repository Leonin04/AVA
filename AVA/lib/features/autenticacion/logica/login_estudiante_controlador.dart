import 'package:flutter/foundation.dart';

import '../../perfil/dominio/estudiante.dart';
import '../dominio/clave_acceso.dart';
import '../dominio/metodo_acceso.dart';
import '../dominio/pictograma_clave.dart';
import '../dominio/repositorio_autenticacion.dart';

/// Lógica del inicio de sesión accesible del estudiante (HU-08) con
/// contraseña, número (PIN) o pictogramas.
class LoginEstudianteControlador extends ChangeNotifier {
  LoginEstudianteControlador({
    required RepositorioAutenticacion repositorio,
    required this.estudiante,
  }) : _repositorio = repositorio;

  static const mensajeIncorrecto = 'No es correcto. Prueba otra vez.';

  final RepositorioAutenticacion _repositorio;
  final Estudiante estudiante;

  final List<PictogramaClave> _pictogramas = [];
  String _digitos = '';
  bool _comprobando = false;
  String? _mensajeError;

  bool get comprobando => _comprobando;
  String? get mensajeError => _mensajeError;
  List<PictogramaClave> get pictogramas => List.unmodifiable(_pictogramas);
  String get digitos => _digitos;

  /// Número de huecos de la clave (0 si usa contraseña).
  int get longitudClave => switch (estudiante.metodoAcceso) {
    AccesoConPictogramas(:final longitudClave) => longitudClave,
    AccesoConPin() => AccesoConPin.longitud,
    AccesoConContrasena() => 0,
  };

  Future<bool> comprobarContrasena(String contrasena) async {
    if (contrasena.isEmpty) {
      _mensajeError = 'Escribe tu contraseña.';
      notifyListeners();
      return false;
    }
    return _comprobar(ClaveContrasena(contrasena));
  }

  /// Añade un pictograma. Al rellenar todos los huecos se comprueba la clave
  /// automáticamente; si no es correcta, los huecos se vacían.
  ///
  /// Devuelve `true` solo cuando la clave completa es correcta.
  Future<bool> anadirPictograma(PictogramaClave pictograma) async {
    if (_comprobando || _pictogramas.length >= longitudClave) return false;

    _pictogramas.add(pictograma);
    _mensajeError = null;
    notifyListeners();

    if (_pictogramas.length < longitudClave) return false;
    final correcto = await _comprobar(ClavePictogramas(List.of(_pictogramas)));
    if (!correcto) {
      _pictogramas.clear();
      notifyListeners();
    }
    return correcto;
  }

  /// Igual que [anadirPictograma], para el teclado numérico.
  Future<bool> anadirDigito(int digito) async {
    if (_comprobando || _digitos.length >= longitudClave) return false;

    _digitos += '$digito';
    _mensajeError = null;
    notifyListeners();

    if (_digitos.length < longitudClave) return false;
    final correcto = await _comprobar(ClavePin(_digitos));
    if (!correcto) {
      _digitos = '';
      notifyListeners();
    }
    return correcto;
  }

  /// Borra el último pictograma o número.
  void borrarUltimo() {
    if (_comprobando) return;
    if (_pictogramas.isNotEmpty) _pictogramas.removeLast();
    if (_digitos.isNotEmpty) {
      _digitos = _digitos.substring(0, _digitos.length - 1);
    }
    notifyListeners();
  }

  Future<bool> _comprobar(ClaveAcceso clave) async {
    if (_comprobando) return false;

    _comprobando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      final correcto = await _repositorio.validarEstudiante(
        idEstudiante: estudiante.id,
        clave: clave,
      );
      if (!correcto) _mensajeError = mensajeIncorrecto;
      return correcto;
    } on Exception {
      _mensajeError = 'No se ha podido comprobar. Prueba otra vez.';
      return false;
    } finally {
      _comprobando = false;
      notifyListeners();
    }
  }
}
