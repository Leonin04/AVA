import '../../../core/utilidades/controlador_carga.dart';
import '../../autenticacion/dominio/clave_acceso.dart';
import '../../autenticacion/dominio/cuenta.dart';
import '../../autenticacion/dominio/repositorio_autenticacion.dart';
import '../../autenticacion/logica/permisos.dart';
import '../../aulas/dominio/ficha_aula.dart';
import '../../aulas/dominio/repositorio_aulas.dart';
import '../dominio/perfil_estudiante.dart';
import '../dominio/preferencias_accesibilidad.dart';
import '../dominio/repositorio_estudiantes.dart';
import 'preferencias_controlador.dart';

/// Ficha de un estudiante para su tutor: perfil (HU-18), preferencias
/// (HU-14) y método de acceso (HU-08).
///
/// Solo carga si la cuenta tiene permiso sobre el estudiante (HU-16).
class FichaEstudianteControlador extends ControladorCarga<Estudiante> {
  FichaEstudianteControlador({
    required RepositorioEstudiantes estudiantes,
    required RepositorioAulas aulas,
    required RepositorioAutenticacion autenticacion,
    required this.cuenta,
    required this.idEstudiante,
  }) : _estudiantes = estudiantes,
       _aulas = aulas,
       _autenticacion = autenticacion;

  static const mensajeSinPermiso =
      'No tienes permiso para ver a este alumno. Solo puedes ver a los '
      'alumnos de tus aulas.';

  final RepositorioEstudiantes _estudiantes;
  final RepositorioAulas _aulas;
  final RepositorioAutenticacion _autenticacion;
  final Cuenta? cuenta;
  final String idEstudiante;

  List<Aula> _listaAulas = const [];

  List<Aula> get aulas => _listaAulas;

  @override
  Future<Estudiante> obtenerDatos() async {
    final estudiante = await _estudiantes.obtener(idEstudiante);
    if (estudiante == null) {
      throw const ErrorConMensaje('Este alumno no existe.');
    }
    _listaAulas = await _aulas.obtenerAulas();
    if (!Permisos.puedeGestionarEstudiante(cuenta, estudiante, _listaAulas)) {
      throw const ErrorConMensaje(mensajeSinPermiso);
    }
    return estudiante;
  }

  /// Guarda los datos del perfil (foto, intereses, necesidades...).
  Future<void> guardarPerfil(Estudiante actualizado) async {
    _comprobarPermiso(actualizado);
    await _estudiantes.guardar(actualizado);
    actualizarDatos(actualizado);
  }

  /// Guarda las preferencias y los permisos del estudiante. Devuelve el
  /// motivo si las preferencias no son válidas.
  Future<String?> guardarPreferencias(
    PreferenciasAccesibilidad preferencias, {
    required bool puedeModificarPreferencias,
    required bool puedeGestionarTareas,
  }) async {
    final error = validarPreferencias(preferencias);
    if (error != null) return error;

    final actual = datos;
    if (actual == null) return 'El alumno no está cargado.';
    await guardarPerfil(
      actual.copyWith(
        preferencias: preferencias,
        puedeModificarPreferencias: puedeModificarPreferencias,
        puedeGestionarTareas: puedeGestionarTareas,
      ),
    );
    return null;
  }

  /// Cambia el método de acceso y la clave del estudiante.
  Future<void> guardarAcceso(ClaveAcceso clave) async {
    final actual = datos;
    if (actual == null) return;
    _comprobarPermiso(actual);
    await _autenticacion.guardarClave(actual.id, clave);
    await guardarPerfil(actual.copyWith(metodoAcceso: clave.metodo));
  }

  void _comprobarPermiso(Estudiante estudiante) {
    if (!Permisos.puedeGestionarEstudiante(cuenta, estudiante, _listaAulas)) {
      throw const ErrorConMensaje(mensajeSinPermiso);
    }
  }
}
