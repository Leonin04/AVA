import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/modelos/recurso_visual.dart';
import '../dominio/repositorio_tareas.dart';
import '../dominio/tarea_agenda.dart';

/// Una página de la explicación de una tarea: su texto y, si lo tiene, su
/// pictograma o foto de apoyo (HU-20).
class PaginaExplicacion {
  const PaginaExplicacion(this.texto, {this.imagen});

  final String texto;
  final RecursoVisual? imagen;
}

/// Detalle de una tarea para el estudiante.
///
/// Sigue el flujo de una tarea guiada (figura 1 del entregable 2):
/// - Antes de empezar, y al terminar, se puede consultar la explicación
///   página a página.
/// - Mientras se hace, se ve solo el paso actual con su apoyo (HU-20). El
///   estudiante confirma que lo ha terminado y entonces se guarda y se pasa
///   al siguiente; si cancela, se queda en el mismo (HU-21). Al confirmar el
///   último, la tarea queda terminada.
///
/// Las confirmaciones las pide la pantalla; este controlador solo guarda
/// los cambios ya confirmados. También permite borrar las tareas personales
/// que ha creado el propio estudiante (HU-04).
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

  /// Mientras se hace una tarea con pasos, se guía paso a paso.
  bool get guiando => puedeTerminar && _tarea.pasos.isNotEmpty;

  /// Paso que toca hacer ahora (0 = el primero).
  int get pasoActual =>
      math.max(0, math.min(_tarea.pasoActual, _tarea.pasos.length - 1));

  bool get esUltimoPaso => pasoActual >= _tarea.pasos.length - 1;

  /// Solo se pueden borrar o cambiar las tareas personales creadas por el
  /// propio estudiante, y si su tutor se lo permite.
  bool get puedeModificar =>
      puedeGestionarTareas &&
      idEstudiante != null &&
      _tarea.creadaPor == idEstudiante;

  /// Páginas de la explicación. Mientras se guía, solo el paso actual; si
  /// no, primero la descripción y después cada paso en una página, para no
  /// saturar ni obligar a desplazarse.
  List<PaginaExplicacion> get paginas {
    final pasos = _tarea.pasos;
    return guiando
        ? [
            PaginaExplicacion(
              'Paso ${pasoActual + 1} de ${pasos.length}: '
              '${pasos[pasoActual].texto}',
              imagen: pasos[pasoActual].imagen,
            ),
          ]
        : [
            if (_tarea.descripcion.isNotEmpty)
              PaginaExplicacion(_tarea.descripcion),
            for (var i = 0; i < pasos.length; i++)
              PaginaExplicacion(
                'Paso ${i + 1}: ${pasos[i].texto}',
                imagen: pasos[i].imagen,
              ),
          ];
  }

  int get pagina => guiando ? 0 : _pagina;

  void irAPagina(int pagina) {
    if (!guiando && pagina >= 0 && pagina < paginas.length) {
      _pagina = pagina;
      notifyListeners();
    }
  }

  Future<bool> empezar() => _guardar(() async {
    _tarea = await _repositorio.actualizarEstado(
      _tarea.id,
      EstadoTarea.enCurso,
      idActor: idEstudiante,
    );
  });

  Future<bool> terminar() => _guardar(() async {
    _tarea = await _repositorio.actualizarEstado(
      _tarea.id,
      EstadoTarea.completada,
      idActor: idEstudiante,
    );
  });

  /// El estudiante ha confirmado que ha terminado el paso actual (HU-21):
  /// se guarda y se pasa al siguiente, o se termina la tarea si era el
  /// último. Devuelve si se ha guardado.
  Future<bool> confirmarPaso() => esUltimoPaso
      ? terminar()
      : _guardar(() async {
          _tarea = await _repositorio.guardarPasoActual(
            _tarea.id,
            pasoActual + 1,
          );
        });

  Future<bool> eliminar() async {
    final permitido = puedeModificar;
    return permitido && await _guardar(() => _repositorio.eliminar(_tarea.id));
  }

  /// Actualiza la tarea mostrada, por ejemplo después de editarla.
  void reemplazar(Tarea tarea) {
    _tarea = tarea;
    _pagina = 0;
    notifyListeners();
  }

  Future<bool> _guardar(Future<void> Function() accion) async {
    var guardado = false;
    if (!_guardando) {
      _guardando = true;
      _mensajeError = null;
      notifyListeners();
      try {
        await accion();
        guardado = true;
      } on Exception {
        _mensajeError = 'No se ha podido guardar. Prueba otra vez.';
      } finally {
        _guardando = false;
        notifyListeners();
      }
    }
    return guardado;
  }
}
