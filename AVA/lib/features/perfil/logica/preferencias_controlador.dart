import 'package:flutter/foundation.dart';

import '../../../core/utilidades/controlador_carga.dart';
import '../dominio/perfil_estudiante.dart';
import '../dominio/preferencias_accesibilidad.dart';
import '../dominio/repositorio_estudiantes.dart';

/// Comprueba que unas preferencias son utilizables. Devuelve el motivo si
/// no lo son.
String? validarPreferencias(PreferenciasAccesibilidad preferencias) {
  if (!preferencias.mostrarTexto && !preferencias.mostrarPictogramas) {
    return 'Hay que mostrar el texto, los pictogramas o los dos.';
  }
  if (preferencias.vistasAgenda.isEmpty) {
    return 'Elige al menos una forma de ver la agenda.';
  }
  return null;
}

/// Preferencias de accesibilidad activas en la aplicación (HU-15).
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

  /// Cambia las preferencias y las guarda en el perfil del estudiante.
  /// Devuelve el perfil actualizado, o lanza [ArgumentError] si las
  /// preferencias no son válidas.
  ///
  /// El cambio se ve al momento, pero si no se puede guardar se deshace y
  /// se lanza [ErrorConMensaje]: así lo que se ve coincide siempre con lo
  /// guardado y la preferencia se mantiene al volver a entrar (T-60).
  Future<Estudiante?> cambiar(PreferenciasAccesibilidad nuevas) async {
    final error = validarPreferencias(nuevas);
    if (error != null) throw ArgumentError(error);

    final anteriores = _preferencias;
    _preferencias = nuevas;
    notifyListeners();

    final id = _idEstudiante;
    Estudiante? actualizado;
    if (id != null) {
      try {
        final estudiante = await _repositorio.obtener(id);
        if (estudiante != null) {
          actualizado = estudiante.copyWith(preferencias: nuevas);
          await _repositorio.guardar(actualizado);
        }
      } on Exception {
        _preferencias = anteriores;
        notifyListeners();
        throw const ErrorConMensaje(
          'No se ha podido guardar el cambio. Prueba otra vez.',
        );
      }
    }
    return actualizado;
  }
}
