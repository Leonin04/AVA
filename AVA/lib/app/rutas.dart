import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/agenda/presentacion/pantalla_agenda_diaria.dart';
import '../features/agenda/presentacion/pantalla_agenda_semanal.dart';
import '../features/agenda/presentacion/pantalla_seleccion_vista_agenda.dart';
import '../features/agenda/presentacion/pantalla_siguiente_tarea.dart';
import '../features/aulas/dominio/aula.dart';
import '../features/aulas/presentacion/pantalla_alumnos_aula.dart';
import '../features/aulas/presentacion/pantalla_gestion_aulas.dart';
import '../features/aulas/presentacion/pantalla_inicio.dart';
import '../features/autenticacion/dominio/cuenta.dart';
import '../features/autenticacion/logica/permisos.dart';
import '../features/autenticacion/logica/sesion_controlador.dart';
import '../features/autenticacion/presentacion/pantalla_cuentas.dart';
import '../features/autenticacion/presentacion/pantalla_login_estudiante.dart';
import '../features/autenticacion/presentacion/pantalla_login_gestion.dart';
import '../features/autenticacion/presentacion/pantalla_panel_gestion.dart';
import '../features/autenticacion/presentacion/pantalla_recuperar_contrasena.dart';
import '../features/perfil/dominio/estudiante.dart';
import '../features/perfil/presentacion/pantalla_ficha_estudiante.dart';
import '../features/perfil/presentacion/pantalla_lista_alumnos.dart';
import '../features/perfil/presentacion/pantalla_menu_estudiante.dart';
import '../features/perfil/presentacion/pantalla_perfil.dart';
import '../features/tareas/dominio/tarea.dart';
import '../features/tareas/presentacion/pantalla_detalle_tarea.dart';
import '../features/tareas/presentacion/pantalla_encargos.dart';
import '../features/tareas/presentacion/pantalla_formulario_tarea.dart';
import '../features/tareas/presentacion/pantalla_nueva_tarea_estudiante.dart';

/// Nombres de las rutas de la aplicación y construcción de cada pantalla.
///
/// Centralizar la navegación evita que las pantallas dependan unas de otras
/// y permite comprobar aquí el rol de quien entra (HU-02).
abstract final class Rutas {
  // Estudiante.
  static const inicio = '/';
  static const alumnosAula = '/aula';
  static const loginEstudiante = '/login-estudiante';
  static const menuEstudiante = '/menu';
  static const perfil = '/perfil';
  static const seleccionVistaAgenda = '/agenda';
  static const agendaSemanal = '/agenda/semana';
  static const agendaDiaria = '/agenda/dia';
  static const siguienteTarea = '/agenda/siguiente';
  static const detalleTarea = '/tarea';
  static const nuevaTareaEstudiante = '/tarea/nueva';

  // Tutores y administración.
  static const loginGestion = '/gestion/login';
  static const recuperarContrasena = '/gestion/recuperar';
  static const panelGestion = '/gestion';
  static const listaAlumnos = '/gestion/alumnos';
  static const fichaEstudiante = '/gestion/alumno';
  static const formularioTarea = '/gestion/tarea';
  static const encargos = '/gestion/encargos';
  static const gestionAulas = '/gestion/aulas';
  static const cuentas = '/gestion/cuentas';

  static Route<Object?> generar(RouteSettings ajustes) {
    final WidgetBuilder constructor = switch ((
      ajustes.name,
      ajustes.arguments,
    )) {
      (Rutas.inicio, _) => (_) => const PantallaInicio(),
      (Rutas.alumnosAula, final Aula aula) => (_) => PantallaAlumnosAula(
        aula: aula,
      ),
      (Rutas.loginEstudiante, final Estudiante estudiante) =>
        (_) => PantallaLoginEstudiante(estudiante: estudiante),
      (Rutas.menuEstudiante, _) => _paraEstudiante(
        (e) => PantallaMenuEstudiante(estudiante: e),
      ),
      (Rutas.perfil, _) => _paraEstudiante(
        (e) => PantallaPerfil(estudiante: e),
      ),
      (Rutas.seleccionVistaAgenda, _) => _paraEstudiante(
        (e) => PantallaSeleccionVistaAgenda(estudiante: e),
      ),
      (Rutas.agendaSemanal, _) => _paraEstudiante(
        (e) => PantallaAgendaSemanal(estudiante: e),
      ),
      (Rutas.agendaDiaria, final DateTime? dia) => _paraEstudiante(
        (e) => PantallaAgendaDiaria(estudiante: e, dia: dia),
      ),
      (Rutas.siguienteTarea, _) => _paraEstudiante(
        (e) => PantallaSiguienteTarea(estudiante: e),
      ),
      (Rutas.detalleTarea, final Tarea tarea) => _paraEstudiante(
        (e) => PantallaDetalleTarea(estudiante: e, tarea: tarea),
      ),
      (Rutas.nuevaTareaEstudiante, final Tarea? tarea) => _paraEstudiante(
        (e) => PantallaNuevaTareaEstudiante(estudiante: e, tarea: tarea),
      ),
      (Rutas.loginGestion, _) => (_) => const PantallaLoginGestion(),
      (Rutas.recuperarContrasena, _) =>
        (_) => const PantallaRecuperarContrasena(),
      (Rutas.panelGestion, _) => _paraGestion(
        (c) => PantallaPanelGestion(cuenta: c),
      ),
      (Rutas.listaAlumnos, _) => _paraGestion(
        (c) => PantallaListaAlumnos(cuenta: c),
      ),
      (Rutas.fichaEstudiante, final String id) => _paraGestion(
        (c) => PantallaFichaEstudiante(cuenta: c, idEstudiante: id),
      ),
      (Rutas.formularioTarea, final ArgumentosFormularioTarea args) =>
        _paraGestion(
          (c) => PantallaFormularioTarea(cuenta: c, argumentos: args),
        ),
      (Rutas.encargos, _) => _paraGestion(
        (c) => PantallaEncargos(cuenta: c),
        permitido: Permisos.puedeCrearEncargos,
      ),
      (Rutas.gestionAulas, _) => _paraGestion(
        (_) => const PantallaGestionAulas(),
        permitido: Permisos.puedeGestionarAulas,
      ),
      (Rutas.cuentas, _) => _paraGestion(
        (_) => const PantallaCuentas(),
        permitido: Permisos.puedeGestionarCuentas,
      ),
      _ => (_) => const PantallaInicio(),
    };

    return MaterialPageRoute<Object?>(settings: ajustes, builder: constructor);
  }

  /// Pantalla que necesita un estudiante con sesión iniciada. Si no lo hay
  /// (por ejemplo, al abrir una URL directa en la web), muestra el inicio.
  static WidgetBuilder _paraEstudiante(
    Widget Function(Estudiante estudiante) constructor,
  ) {
    return (context) {
      final estudiante = context.watch<SesionControlador>().estudiante;
      return estudiante == null
          ? const PantallaInicio()
          : constructor(estudiante);
    };
  }

  /// Pantalla para tutores y administradores. Si la cuenta no tiene el rol
  /// necesario, se muestra el inicio (HU-02).
  static WidgetBuilder _paraGestion(
    Widget Function(Cuenta cuenta) constructor, {
    bool Function(Cuenta? cuenta)? permitido,
  }) {
    return (context) {
      final cuenta = context.read<SesionControlador>().cuenta;
      final autorizado =
          cuenta != null &&
          cuenta.esGestion &&
          (permitido?.call(cuenta) ?? true);
      return autorizado ? constructor(cuenta) : const PantallaInicio();
    };
  }
}
