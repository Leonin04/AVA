import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/pantalla_gestion.dart';
import '../../../core/widgets/vista_carga.dart';
import '../../autenticacion/dominio/cuenta.dart';
import '../../autenticacion/dominio/repositorio_autenticacion.dart';
import '../../aulas/dominio/repositorio_aulas.dart';
import '../dominio/estudiante.dart';
import '../dominio/repositorio_estudiantes.dart';
import '../logica/ficha_estudiante_controlador.dart';
import 'widgets/pestana_acceso.dart';
import 'widgets/pestana_accesibilidad.dart';
import 'widgets/pestana_datos.dart';
import 'widgets/pestana_tareas.dart';

/// Ficha de un alumno para su tutor, en cuatro pestañas: datos del perfil
/// (HU-18), accesibilidad (HU-14), acceso (HU-08) y tareas (HU-03 a HU-06).
///
/// Si la cuenta no tiene asignado al alumno, se muestra un aviso y no se
/// carga nada (HU-16).
class PantallaFichaEstudiante extends StatefulWidget {
  const PantallaFichaEstudiante({
    super.key,
    required this.cuenta,
    required this.idEstudiante,
  });

  final Cuenta cuenta;
  final String idEstudiante;

  @override
  State<PantallaFichaEstudiante> createState() =>
      _PantallaFichaEstudianteState();
}

class _PantallaFichaEstudianteState extends State<PantallaFichaEstudiante> {
  late final FichaEstudianteControlador _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = FichaEstudianteControlador(
      estudiantes: context.read<RepositorioEstudiantes>(),
      aulas: context.read<RepositorioAulas>(),
      autenticacion: context.read<RepositorioAutenticacion>(),
      cuenta: widget.cuenta,
      idEstudiante: widget.idEstudiante,
    );
    unawaited(_controlador.cargar());
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: ListenableBuilder(
        listenable: _controlador,
        builder: (context, _) => PantallaGestion(
          titulo: _controlador.datos?.nombre ?? 'Alumno',
          desplazable: false,
          inferior: _controlador.datos == null
              ? null
              : const TabBar(
                  isScrollable: true,
                  labelStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  tabs: [
                    Tab(icon: Icon(Icons.badge_rounded), text: 'Perfil'),
                    Tab(
                      icon: Icon(Icons.accessibility_new_rounded),
                      text: 'Accesibilidad',
                    ),
                    Tab(icon: Icon(Icons.key_rounded), text: 'Acceso'),
                    Tab(icon: Icon(Icons.checklist_rounded), text: 'Tareas'),
                  ],
                ),
          cuerpo: VistaCarga<Estudiante>(
            controlador: _controlador,
            constructor: (context, estudiante) => TabBarView(
              children: [
                PestanaDatos(controlador: _controlador),
                PestanaAccesibilidad(controlador: _controlador),
                PestanaAcceso(controlador: _controlador),
                PestanaTareas(cuenta: widget.cuenta, estudiante: estudiante),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
