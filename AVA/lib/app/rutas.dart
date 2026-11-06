import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/agenda/presentacion/pantalla_agenda_diaria.dart';
import '../features/agenda/presentacion/pantalla_agenda_semanal.dart';
import '../features/agenda/presentacion/pantalla_seleccion_vista_agenda.dart';
import '../features/agenda/presentacion/pantalla_siguiente_tarea.dart';
import '../features/aulas/dominio/aula.dart';
import '../features/aulas/presentacion/pantalla_alumnos_aula.dart';
import '../features/aulas/presentacion/pantalla_inicio.dart';
import '../features/autenticacion/logica/sesion_controlador.dart';
import '../features/autenticacion/presentacion/pantalla_login_administrador.dart';
import '../features/autenticacion/presentacion/pantalla_login_estudiante.dart';
import '../features/autenticacion/presentacion/pantalla_panel_administrador.dart';
import '../features/perfil/dominio/estudiante.dart';
import '../features/perfil/presentacion/pantalla_menu_estudiante.dart';
import '../features/perfil/presentacion/pantalla_perfil.dart';
import '../features/tareas/dominio/tarea.dart';
import '../features/tareas/presentacion/pantalla_detalle_tarea.dart';

/// Nombres de las rutas de la aplicación y construcción de cada pantalla.
///
/// Centralizar la navegación evita que las pantallas dependan unas de otras.
abstract final class Rutas {
  static const inicio = '/';
  static const alumnosAula = '/aula';
  static const loginAdministrador = '/login-administrador';
  static const panelAdministrador = '/administracion';
  static const loginEstudiante = '/login-estudiante';
  static const menuEstudiante = '/menu';
  static const perfil = '/perfil';
  static const seleccionVistaAgenda = '/agenda';
  static const agendaSemanal = '/agenda/semana';
  static const agendaDiaria = '/agenda/dia';
  static const siguienteTarea = '/agenda/siguiente';
  static const detalleTarea = '/tarea';

  static Route<void> generar(RouteSettings ajustes) {
    final WidgetBuilder constructor = switch ((ajustes.name, ajustes.arguments)) {
      (Rutas.inicio, _) => (_) => const PantallaInicio(),
      (Rutas.alumnosAula, final Aula aula) => (_) =>
          PantallaAlumnosAula(aula: aula),
      (Rutas.loginAdministrador, _) => (_) =>
          const PantallaLoginAdministrador(),
      (Rutas.panelAdministrador, _) => _paraAdministrador,
      (Rutas.loginEstudiante, final Estudiante estudiante) => (_) =>
          PantallaLoginEstudiante(estudiante: estudiante),
      (Rutas.menuEstudiante, _) => _paraEstudiante(
          (estudiante) => PantallaMenuEstudiante(estudiante: estudiante),
        ),
      (Rutas.perfil, _) => _paraEstudiante(
          (estudiante) => PantallaPerfil(estudiante: estudiante),
        ),
      (Rutas.seleccionVistaAgenda, _) => _paraEstudiante(
          (estudiante) => PantallaSeleccionVistaAgenda(estudiante: estudiante),
        ),
      (Rutas.agendaSemanal, _) => _paraEstudiante(
          (estudiante) => PantallaAgendaSemanal(estudiante: estudiante),
        ),
      (Rutas.agendaDiaria, final DateTime? dia) => _paraEstudiante(
          (estudiante) => PantallaAgendaDiaria(estudiante: estudiante, dia: dia),
        ),
      (Rutas.siguienteTarea, _) => _paraEstudiante(
          (estudiante) => PantallaSiguienteTarea(estudiante: estudiante),
        ),
      (Rutas.detalleTarea, final Tarea tarea) => (_) =>
          PantallaDetalleTarea(tarea: tarea),
      _ => (_) => const PantallaInicio(),
    };

    return MaterialPageRoute<void>(settings: ajustes, builder: constructor);
  }

  /// Construye una pantalla que necesita un estudiante con sesión iniciada.
  /// Si no lo hay (por ejemplo, al abrir una URL directa en la web), muestra
  /// la pantalla de inicio.
  static WidgetBuilder _paraEstudiante(
    Widget Function(Estudiante estudiante) constructor,
  ) {
    return (context) {
      final estudiante = context.read<SesionControlador>().estudiante;
      return estudiante == null ? const PantallaInicio() : constructor(estudiante);
    };
  }

  static Widget _paraAdministrador(BuildContext context) {
    final usuario = context.read<SesionControlador>().usuarioAdministrador;
    return usuario == null
        ? const PantallaInicio()
        : PantallaPanelAdministrador(usuario: usuario);
  }
}
