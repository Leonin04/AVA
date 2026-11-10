import '../../../core/modelos/recurso_visual.dart';
import '../../../core/utilidades/controlador_carga.dart';
import '../../autenticacion/dominio/cuenta.dart';
import '../../autenticacion/logica/permisos.dart';
import '../../aulas/dominio/repositorio_aulas.dart';
import '../../perfil/dominio/repositorio_estudiantes.dart';
import '../dominio/repositorio_tareas.dart';
import '../dominio/tarea_agenda.dart';
import 'validacion_tareas.dart';

/// Creación y edición de una tarea por el tutor: nombre, tipo, imagen de
/// apoyo, descripción, horario y pasos (HU-03 a HU-06).
///
/// Antes de guardar comprueba que el tutor tiene asignado al alumno
/// (HU-16).
class FormularioTareaControlador {
  FormularioTareaControlador({
    required RepositorioTareas tareas,
    required RepositorioEstudiantes estudiantes,
    required RepositorioAulas aulas,
    required this.cuenta,
  }) : _tareas = tareas,
       _estudiantes = estudiantes,
       _aulas = aulas;

  final RepositorioTareas _tareas;
  final RepositorioEstudiantes _estudiantes;
  final RepositorioAulas _aulas;
  final Cuenta cuenta;

  /// Guarda la tarea y la devuelve. Lanza [ErrorConMensaje] si los datos no
  /// son válidos o la cuenta no tiene permiso.
  Future<Tarea> guardar({
    required String idEstudiante,
    required String titulo,
    required TipoTarea tipo,
    required DateTime inicio,
    required DateTime fin,
    String descripcion = '',
    List<String> pasos = const [],
    RecursoVisual? pictograma,
    Tarea? existente,
  }) async {
    final error =
        ValidacionTareas.titulo(titulo) ??
        ValidacionTareas.horario(inicio, fin);
    if (error != null) throw ErrorConMensaje(error);

    final estudiante = await _estudiantes.obtener(idEstudiante);
    final aulas = await _aulas.obtenerAulas();
    if (estudiante == null ||
        !Permisos.puedeGestionarEstudiante(cuenta, estudiante, aulas)) {
      throw const ErrorConMensaje(
        'No tienes permiso para gestionar las tareas de este alumno.',
      );
    }

    final tarea = Tarea(
      id: existente?.id ?? _tareas.nuevoId('tarea'),
      idEstudiante: idEstudiante,
      titulo: titulo.trim(),
      descripcion: descripcion.trim(),
      pasos: ValidacionTareas.limpiarPasos(pasos),
      tipo: tipo,
      estado: existente?.estado ?? EstadoTarea.pendiente,
      inicio: inicio,
      fin: fin,
      pictograma: pictograma,
      creadaPor: existente?.creadaPor ?? cuenta.id,
      idEncargo: existente?.idEncargo,
    );
    await _tareas.guardar(tarea);
    return tarea;
  }
}
