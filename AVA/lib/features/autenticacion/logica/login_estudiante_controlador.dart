import 'package:flutter/foundation.dart';

import '../../perfil/dominio/estudiante.dart';
import '../dominio/metodo_acceso.dart';
import '../dominio/pictograma_clave.dart';
import '../dominio/repositorio_autenticacion.dart';

/// Lógica del inicio de sesión accesible del estudiante (HU-08), tanto con
/// contraseña como con pictogramas.
class LoginEstudianteControlador extends ChangeNotifier {
  LoginEstudianteControlador({
    required RepositorioAutenticacion repositorio,
    required this.estudiante,
  }) : _repositorio = repositorio;

  static const _mensajeIncorrecto = 'No es correcto. Inténtalo otra vez.';

  final RepositorioAutenticacion _repositorio;
  final Estudiante estudiante;

  final List<PictogramaClave> _seleccion = [];
  bool _comprobando = false;
  String? _mensajeError;

  bool get comprobando => _comprobando;
  String? get mensajeError => _mensajeError;
  List<PictogramaClave> get seleccion => List.unmodifiable(_seleccion);

  /// Número de huecos de la clave de pictogramas (0 si usa contraseña).
  int get longitudClave => switch (estudiante.metodoAcceso) {
        AccesoConPictogramas(:final longitudClave) => longitudClave,
        AccesoConContrasena() => 0,
      };

  Future<bool> comprobarContrasena(String contrasena) async {
    if (contrasena.isEmpty) {
      _mensajeError = 'Escribe tu contraseña';
      notifyListeners();
      return false;
    }
    return _comprobar(
      () => _repositorio.validarContrasenaEstudiante(
        idEstudiante: estudiante.id,
        contrasena: contrasena,
      ),
    );
  }

  /// Añade un pictograma a la clave. Al rellenar todos los huecos se
  /// comprueba automáticamente; si es incorrecta, los huecos se vacían.
  ///
  /// Devuelve `true` solo cuando la clave completa es correcta.
  Future<bool> anadirPictograma(PictogramaClave pictograma) async {
    if (_comprobando || _seleccion.length >= longitudClave) return false;

    _seleccion.add(pictograma);
    _mensajeError = null;
    notifyListeners();

    if (_seleccion.length < longitudClave) return false;

    final correcto = await _comprobar(
      () => _repositorio.validarPictogramasEstudiante(
        idEstudiante: estudiante.id,
        secuencia: List.of(_seleccion),
      ),
    );
    if (!correcto) {
      _seleccion.clear();
      notifyListeners();
    }
    return correcto;
  }

  void borrarUltimoPictograma() {
    if (_comprobando || _seleccion.isEmpty) return;
    _seleccion.removeLast();
    notifyListeners();
  }

  Future<bool> _comprobar(Future<bool> Function() validar) async {
    if (_comprobando) return false;

    _comprobando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      final correcto = await validar();
      if (!correcto) _mensajeError = _mensajeIncorrecto;
      return correcto;
    } on Exception {
      _mensajeError = 'No se ha podido comprobar. Inténtalo otra vez.';
      return false;
    } finally {
      _comprobando = false;
      notifyListeners();
    }
  }
}
