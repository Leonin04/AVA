import '../../aulas/dominio/ficha_aula.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../dominio/cuenta.dart';
import '../dominio/rol.dart';

/// Reglas de acceso según el rol (HU-03) y la asignación de alumnos a
/// tutores (HU-17).
///
/// Son funciones puras para poder probarlas sin interfaz. Con Firebase,
/// estas mismas reglas se repetirán en las reglas de seguridad de Firestore.
abstract final class Permisos {
  static bool esAdministrador(Cuenta? cuenta) =>
      cuenta?.rol == Rol.administrador;

  /// Crear y editar cuentas y roles (HU-01 a HU-03).
  static bool puedeGestionarCuentas(Cuenta? cuenta) => esAdministrador(cuenta);

  /// Crear aulas y asignar alumnos y tutores (HU-16).
  static bool puedeGestionarAulas(Cuenta? cuenta) => esAdministrador(cuenta);

  /// Crear encargos del centro (HU-08).
  static bool puedeCrearEncargos(Cuenta? cuenta) => cuenta?.esGestion ?? false;

  static bool _esTutorDelCentro(Cuenta? cuenta) =>
      cuenta?.rol == Rol.tutor && !cuenta!.esFamiliar;

  /// Consultar el estado, el progreso y el historial de las tareas de sus
  /// estudiantes (HU-26, HU-27): administración y tutores.
  static bool puedeVerSeguimiento(Cuenta? cuenta) => cuenta?.esGestion ?? false;

  /// Confirmar que una tarea se ha completado (T-124): administración y
  /// tutores del centro. El tutor familiar solo consulta (matriz de
  /// permisos del entregable 2).
  static bool puedeConfirmarTareas(Cuenta? cuenta) =>
      esAdministrador(cuenta) || _esTutorDelCentro(cuenta);

  /// Revisar y corregir la asistencia al comedor (HU-23, T-115) y generar el
  /// listado para cocina (HU-25): administración y tutores del centro.
  static bool puedeGestionarComedor(Cuenta? cuenta) =>
      esAdministrador(cuenta) || _esTutorDelCentro(cuenta);

  /// Ver y cambiar la información de dietas (HU-24, T-116, T-117): solo
  /// administración y tutores del centro. Nunca el estudiante, ni el
  /// encargado del comedor, ni el tutor familiar.
  static bool puedeGestionarDietas(Cuenta? cuenta) =>
      esAdministrador(cuenta) || _esTutorDelCentro(cuenta);

  /// Si [cuenta] puede ver y gestionar el perfil y las tareas de
  /// [estudiante] (HU-17).
  static bool puedeGestionarEstudiante(
    Cuenta? cuenta,
    Estudiante estudiante,
    List<Aula> aulas,
  ) {
    if (cuenta == null) return false;
    return switch (cuenta.rol) {
      Rol.administrador => true,
      // Es su tutor (del centro o familiar) o el responsable de su aula.
      Rol.tutor =>
        estudiante.tutores.contains(cuenta.id) ||
            aulas.any(
              (aula) =>
                  aula.id == estudiante.idAula && aula.idTutor == cuenta.id,
            ),
      Rol.estudiante => cuenta.id == estudiante.id,
    };
  }

  /// Aulas que [cuenta] puede gestionar: todas para el administrador y las
  /// suyas para un tutor.
  static List<Aula> aulasVisibles(Cuenta? cuenta, List<Aula> aulas) {
    if (cuenta == null) return const [];
    return switch (cuenta.rol) {
      Rol.administrador => aulas,
      Rol.tutor => [
        for (final a in aulas)
          if (a.idTutor == cuenta.id) a,
      ],
      Rol.estudiante => const [],
    };
  }

  static List<Estudiante> estudiantesVisibles(
    Cuenta? cuenta,
    List<Estudiante> estudiantes,
    List<Aula> aulas,
  ) => [
    for (final e in estudiantes)
      if (puedeGestionarEstudiante(cuenta, e, aulas)) e,
  ];
}
