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
