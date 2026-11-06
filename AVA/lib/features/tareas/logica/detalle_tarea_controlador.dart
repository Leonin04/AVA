import 'package:flutter/foundation.dart';

import '../dominio/repositorio_tareas.dart';
import '../dominio/tarea.dart';

/// Registro del inicio y fin de una tarea por parte del estudiante (HU-11).
///
/// La confirmación previa la pide la pantalla; este controlador solo guarda
/// el cambio una vez confirmado.
class DetalleTareaControlador extends ChangeNotifier {
  DetalleTareaControlador({
    required RepositorioTareas repositorio,
    required Tarea tarea,
  })  : _repositorio = repositorio,
        _tarea = tarea;

  final RepositorioTareas _repositorio;

  Tarea _tarea;
  bool _guardando = false;
  String? _mensajeError;

  Tarea get tarea => _tarea;
  bool get guardando => _guardando;
  String? get mensajeError => _mensajeError;

  bool get puedeEmpezar => _tarea.estado == EstadoTarea.pendiente;
  bool get puedeTerminar => _tarea.estado == EstadoTarea.enCurso;

  Future<bool> empezar() => _cambiarEstado(EstadoTarea.enCurso);

  Future<bool> terminar() => _cambiarEstado(EstadoTarea.completada);

  Future<bool> _cambiarEstado(EstadoTarea estado) async {
    if (_guardando) return false;

    _guardando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      _tarea = await _repositorio.actualizarEstado(_tarea.id, estado);
      return true;
    } on Exception {
      _mensajeError = 'No se ha podido guardar. Inténtalo otra vez.';
      return false;
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }
}
