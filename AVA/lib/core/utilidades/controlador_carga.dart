import 'package:flutter/foundation.dart';

/// Base para los controladores de pantallas que cargan datos de un
/// repositorio.
///
/// Gestiona los tres estados posibles (cargando, error y datos) para que
/// cada controlador solo tenga que indicar cómo obtener sus datos.
abstract class ControladorCarga<T> extends ChangeNotifier {
  T? _datos;
  bool _cargando = false;
  String? _mensajeError;
  bool _desechado = false;

  T? get datos => _datos;
  bool get cargando => _cargando;
  String? get mensajeError => _mensajeError;

  /// Obtiene los datos del repositorio correspondiente. Puede lanzar
  /// [ErrorConMensaje] para mostrar un mensaje concreto.
  @protected
  Future<T> obtenerDatos();

  /// Mensaje que se muestra si la carga falla por otro motivo.
  @protected
  String get mensajeErrorCarga => 'No se han podido cargar los datos.';

  Future<void> cargar() async {
    if (_cargando) return;

    _cargando = true;
    _mensajeError = null;
    _notificar();

    try {
      _datos = await obtenerDatos();
    } on ErrorConMensaje catch (error) {
      _datos = null;
      _mensajeError = error.mensaje;
    } on Exception {
      _mensajeError = mensajeErrorCarga;
    } finally {
      _cargando = false;
      _notificar();
    }
  }

  /// Sustituye los datos tras guardar un cambio, sin volver a cargarlos.
  @protected
  void actualizarDatos(T datos) {
    _datos = datos;
    _notificar();
  }

  void _notificar() {
    // La carga puede terminar después de salir de la pantalla.
    if (!_desechado) notifyListeners();
  }

  @override
  void dispose() {
    _desechado = true;
    super.dispose();
  }
}

/// Error cuyo mensaje se puede mostrar directamente al usuario.
class ErrorConMensaje implements Exception {
  const ErrorConMensaje(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}
