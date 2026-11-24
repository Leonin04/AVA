import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../autenticacion/logica/sesion_controlador.dart';
import '../../tareas/dominio/repositorio_tareas.dart';
import 'planificador_avisos.dart';

/// Avisos previos al estudiante con la sesión iniciada (HU-28).
///
/// Mientras la app está abierta revisa cada [intervalo] las tareas de hoy y
/// deja en [aviso] el que toca mostrar. Cada aviso se muestra una sola vez
/// (T-135) y, si cambia la hora de la tarea o su antelación, se recalcula
/// solo porque se lee de las tareas guardadas (T-131).
class AvisosEstudianteControlador extends ChangeNotifier {
  AvisosEstudianteControlador({
    required RepositorioTareas tareas,
    required SesionControlador sesion,
    this.intervalo = const Duration(seconds: 30),
    DateTime Function()? reloj,
  }) : _tareas = tareas,
       _sesion = sesion,
       _reloj = reloj ?? DateTime.now {
    _sesion.addListener(_alCambiarSesion);
    _alCambiarSesion();
  }

  final RepositorioTareas _tareas;
  final SesionControlador _sesion;
  final DateTime Function() _reloj;
  final Duration intervalo;

  final Set<String> _mostrados = {};
  Timer? _revision;
  AvisoPrevio? _aviso;
  String? _idEstudiante;

  /// Aviso que hay que mostrar ahora, o `null`.
  AvisoPrevio? get aviso => _aviso;

  void _alCambiarSesion() {
    final id = _sesion.estudiante?.id;
    if (id != _idEstudiante) {
      _idEstudiante = id;
      _revision?.cancel();
      _mostrados.clear();
      _aviso = null;
      if (id != null) {
        _revision = Timer.periodic(intervalo, (_) => unawaited(revisar()));
        unawaited(revisar());
      }
      notifyListeners();
    }
  }

  /// Busca el próximo aviso que toca. Si no se pueden leer las tareas (por
  /// ejemplo, sin conexión), lo intenta en la siguiente revisión.
  Future<void> revisar() async {
    final id = _idEstudiante;
    if (id != null && _aviso == null) {
      final ahora = _reloj();
      final hoy = DateTime(ahora.year, ahora.month, ahora.day);
      try {
        final tareas = await _tareas.obtenerTareas(
          idEstudiante: id,
          desde: hoy,
          hasta: hoy.add(const Duration(days: 1)),
        );
        final pendientes = PlanificadorAvisos.pendientes(
          tareas,
          ahora,
          mostrados: _mostrados,
        );
        if (pendientes.isNotEmpty && id == _idEstudiante) {
          _aviso = pendientes.first;
          notifyListeners();
        }
      } on Exception {
        // Se vuelve a intentar en la próxima revisión.
      }
    }
  }

  /// El estudiante ha visto el aviso: no se vuelve a mostrar.
  void descartar() {
    final aviso = _aviso;
    if (aviso != null) {
      _mostrados.add(aviso.clave);
      _aviso = null;
      notifyListeners();
      unawaited(revisar());
    }
  }

  @override
  void dispose() {
    _revision?.cancel();
    _sesion.removeListener(_alCambiarSesion);
    super.dispose();
  }
}
