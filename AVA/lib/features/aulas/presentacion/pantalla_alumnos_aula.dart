import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/dimensiones.dart';
import '../../../core/widgets/mensaje_informativo.dart';
import '../../../core/widgets/vista_carga.dart';
import '../../perfil/dominio/estudiante.dart';
import '../../perfil/dominio/repositorio_estudiantes.dart';
import '../dominio/aula.dart';
import '../logica/estudiantes_aula_controlador.dart';
import 'widgets/tarjeta_estudiante.dart';

/// Alumnos de una clase. Cada alumno pulsa su avatar para ir a su login.
class PantallaAlumnosAula extends StatefulWidget {
  const PantallaAlumnosAula({super.key, required this.aula});

  final Aula aula;

  @override
  State<PantallaAlumnosAula> createState() => _PantallaAlumnosAulaState();
}

class _PantallaAlumnosAulaState extends State<PantallaAlumnosAula> {
  late final EstudiantesAulaControlador _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = EstudiantesAulaControlador(
      repositorio: context.read<RepositorioEstudiantes>(),
      aula: widget.aula,
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.aula.nombre)),
      body: VistaCarga<List<Estudiante>>(
        controlador: _controlador,
        constructor: (context, estudiantes) => estudiantes.isEmpty
            ? const MensajeInformativo(
                icono: Icons.groups_outlined,
                texto: 'Esta clase todavía no tiene alumnos',
              )
            : _ListaEstudiantes(estudiantes: estudiantes),
      ),
    );
  }
}

class _ListaEstudiantes extends StatelessWidget {
  const _ListaEstudiantes({required this.estudiantes});

  final List<Estudiante> estudiantes;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensiones.espaciado),
      child: Center(
        child: Wrap(
          spacing: Dimensiones.espaciado * 2,
          runSpacing: Dimensiones.espaciado,
          alignment: WrapAlignment.center,
          children: [
            for (final estudiante in estudiantes)
              TarjetaEstudiante(
                estudiante: estudiante,
                alPulsar: () => Navigator.pushNamed(
                  context,
                  Rutas.loginEstudiante,
                  arguments: estudiante,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
