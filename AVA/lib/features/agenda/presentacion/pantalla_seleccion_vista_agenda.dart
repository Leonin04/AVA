import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/widgets/boton_accesible.dart';
import '../../../core/widgets/cuadricula_ajustada.dart';
import '../../../core/widgets/pantalla_estudiante.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../../perfil/logica/preferencias_controlador.dart';
import '../dominio/vista_agenda.dart';

/// Elección de cómo ver la agenda: semana, hoy o «ahora y después». Solo
/// aparecen las vistas que el tutor ha habilitado (HU-09).
class PantallaSeleccionVistaAgenda extends StatelessWidget {
  const PantallaSeleccionVistaAgenda({super.key, required this.estudiante});

  final Estudiante estudiante;

  static String _ruta(VistaAgenda vista) => switch (vista) {
    VistaAgenda.semanal => Rutas.agendaSemanal,
    VistaAgenda.diaria => Rutas.agendaDiaria,
    VistaAgenda.siguienteTarea => Rutas.siguienteTarea,
  };

  static IconData _icono(VistaAgenda vista) => switch (vista) {
    VistaAgenda.semanal => Icons.view_week_rounded,
    VistaAgenda.diaria => Icons.today_rounded,
    VistaAgenda.siguienteTarea => Icons.skip_next_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final habilitadas = context
        .watch<PreferenciasControlador>()
        .preferencias
        .vistasAgenda;
    final vistas = [
      for (final vista in VistaAgenda.values)
        if (habilitadas.contains(vista)) vista,
    ];

    return PantallaEstudiante(
      titulo: 'Mi agenda',
      pictograma: Pictogramas.agenda,
      icono: Icons.calendar_month_rounded,
      textoVoz:
          'Mi agenda. ¿Cómo la quieres ver? '
          '${vistas.map((v) => v.nombre).join(', ')}.',
      cuerpo: CuadriculaAjustada<VistaAgenda>(
        elementos: vistas,
        maxColumnas: 3,
        anchoMinimoCelda: 240,
        altoMinimoCelda: 220,
        altoMaximoCelda: 380,
        constructor: (context, vista) => BotonAccesible(
          texto: vista.nombre,
          pictograma: vista.pictograma,
          icono: _icono(vista),
          color: vista.color,
          textoGrande: true,
          alPulsar: () => Navigator.pushNamed(context, _ruta(vista)),
        ),
      ),
    );
  }
}
