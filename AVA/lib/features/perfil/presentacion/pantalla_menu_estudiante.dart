import 'package:flutter/material.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/paleta.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/modelos/recurso_visual.dart';
import '../../../core/widgets/boton_accesible.dart';
import '../../../core/widgets/cuadricula_ajustada.dart';
import '../../../core/widgets/dialogo_confirmacion.dart';
import '../../../core/widgets/pantalla_estudiante.dart';
import '../../autenticacion/presentacion/widgets/boton_cerrar_sesion.dart';
import '../dominio/perfil_estudiante.dart';

/// Pantalla principal del estudiante tras iniciar sesión: Agenda y Perfil
/// (y crear tareas si su tutor se lo permite). Pocas opciones, grandes y
/// de colores distintos.
class PantallaMenuEstudiante extends StatelessWidget {
  const PantallaMenuEstudiante({super.key, required this.estudiante});

  final Estudiante estudiante;

  Future<void> _salir(BuildContext context) async {
    final confirmado = await mostrarDialogoConfirmacion(
      context,
      titulo: '¿Quieres salir?',
      mensaje: 'Volverás a la pantalla de las clases.',
      pictograma: Pictogramas.salir,
      textoConfirmar: 'Sí, salir',
    );
    if (confirmado && context.mounted) await cerrarSesion(context);
  }

  @override
  Widget build(BuildContext context) {
    final opciones = <_OpcionMenu>[
      _OpcionMenu(
        'Mi agenda',
        Pictogramas.agenda,
        Icons.calendar_month_rounded,
        ColorPastel.cielo,
        () => Navigator.pushNamed(context, Rutas.seleccionVistaAgenda),
      ),
      _OpcionMenu(
        'Mi perfil',
        Pictogramas.perfil,
        Icons.person_rounded,
        ColorPastel.lavanda,
        () => Navigator.pushNamed(context, Rutas.perfil),
      ),
      if (estudiante.puedeGestionarTareas)
        _OpcionMenu(
          'Crear tarea',
          Pictogramas.lapiz,
          Icons.add_task_rounded,
          ColorPastel.menta,
          () => Navigator.pushNamed(context, Rutas.nuevaTareaEstudiante),
        ),
      _OpcionMenu(
        'Salir',
        Pictogramas.salir,
        Icons.logout_rounded,
        ColorPastel.rosa,
        () => _salir(context),
      ),
    ];

    return PantallaEstudiante(
      titulo: 'Hola, ${estudiante.nombre}',
      pictograma: estudiante.avatar ?? Pictogramas.hola,
      icono: Icons.waving_hand_rounded,
      color: estudiante.color,
      textoVoz: 'Hola, ${estudiante.nombre}. ¿Qué quieres hacer?',
      cuerpo: CuadriculaAjustada<_OpcionMenu>(
        elementos: opciones,
        maxColumnas: 4,
        anchoMinimoCelda: 220,
        altoMinimoCelda: 220,
        altoMaximoCelda: 380,
        constructor: (context, opcion) => BotonAccesible(
          texto: opcion.texto,
          pictograma: opcion.pictograma,
          icono: opcion.icono,
          color: opcion.color,
          textoGrande: true,
          alPulsar: opcion.alPulsar,
        ),
      ),
    );
  }
}

class _OpcionMenu {
  const _OpcionMenu(
    this.texto,
    this.pictograma,
    this.icono,
    this.color,
    this.alPulsar,
  );

  final String texto;
  final RecursoVisual pictograma;
  final IconData icono;
  final ColorPastel color;
  final VoidCallback alPulsar;
}
