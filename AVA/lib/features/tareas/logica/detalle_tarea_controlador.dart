import 'package:flutter/foundation.dart';

import '../dominio/repositorio_tareas.dart';
import '../dominio/tarea_agenda.dart';

/// Detalle de una tarea para el estudiante.
///
/// Registra el inicio y el fin (HU-11) y permite borrar las tareas
/// personales que ha creado él mismo (HU-03). La confirmación previa la pide
/// la pantalla; este controlador solo guarda el cambio ya confirmado.
class DetalleTareaControlador extends ChangeNotifier {
  DetalleTareaControlador({
    required RepositorioTareas repositorio,
    required Tarea tarea,
    this.idEstudiante,
    this.puedeGestionarTareas = false,
  }) : _repositorio = repositorio,
       _tarea = tarea;

  final RepositorioTareas _repositorio;

  /// Estudiante que consulta la tarea.
  final String? idEstudiante;
  final bool puedeGestionarTareas;

  Tarea _tarea;
  bool _guardando = false;
  String? _mensajeError;
  int _pagina = 0;

  Tarea get tarea => _tarea;
  bool get guardando => _guardando;
  String? get mensajeError => _mensajeError;

  bool get puedeEmpezar => _tarea.estado == EstadoTarea.pendiente;
  bool get puedeTerminar => _tarea.estado == EstadoTarea.enCurso;

  /// Solo se pueden borrar o cambiar las tareas personales creadas por el
  /// propio estudiante, y si su tutor se lo permite.
  bool get puedeModificar =>
      puedeGestionarTareas &&
      idEstudiante != null &&
      _tarea.creadaPor == idEstudiante;

  /// Páginas de la explicación: primero la descripción y después un paso
  /// en cada página, para no saturar ni obligar a desplazarse.
  List<String> get paginas => [
    if (_tarea.descripcion.isNotEmpty) _tarea.descripcion,
    for (var i = 0; i < _tarea.pasos.length; i++)
      'Paso ${i + 1}: ${_tarea.pasos[i]}',
  ];

  int get pagina => _pagina;

  void irAPagina(int pagina) {
    if (pagina < 0 || pagina >= paginas.length) return;
    _pagina = pagina;
    notifyListeners();
  }

  Future<bool> empezar() => _cambiarEstado(EstadoTarea.enCurso);

  Future<bool> terminar() => _cambiarEstado(EstadoTarea.completada);

  Future<bool> eliminar() async {
    if (!puedeModificar) return false;
    return _guardar(() => _repositorio.eliminar(_tarea.id));
  }

  /// Actualiza la tarea mostrada, por ejemplo después de editarla.
  void reemplazar(Tarea tarea) {
    _tarea = tarea;
    _pagina = 0;
    notifyListeners();
  }

  Future<bool> _cambiarEstado(EstadoTarea estado) => _guardar(() async {
    _tarea = await _repositorio.actualizarEstado(_tarea.id, estado);
  });

  Future<bool> _guardar(Future<void> Function() accion) async {
    if (_guardando) return false;

    _guardando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      await accion();
      return true;
    } on Exception {
      _mensajeError = 'No se ha podido guardar. Prueba otra vez.';
      return false;
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }
}
