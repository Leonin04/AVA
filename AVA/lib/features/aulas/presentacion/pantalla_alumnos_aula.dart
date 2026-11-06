import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/widgets/avatar_usuario.dart';
import '../../../core/widgets/boton_accesible.dart';
import '../../../core/widgets/cuadricula_paginada.dart';
import '../../../core/widgets/mensaje_informativo.dart';
import '../../../core/widgets/pantalla_estudiante.dart';
import '../../../core/widgets/vista_carga.dart';
import '../../perfil/dominio/estudiante.dart';
import '../../perfil/dominio/repositorio_estudiantes.dart';
import '../dominio/aula.dart';
import '../logica/estudiantes_aula_controlador.dart';

/// Alumnos de una clase. Cada alumno toca su foto para ir a su login.
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
    final aula = widget.aula;

    return PantallaEstudiante(
      titulo: 'Clase ${aula.nombre}',
      pictograma: aula.pictograma ?? Pictogramas.aula,
      icono: Icons.groups_rounded,
      color: aula.color,
      textoVoz: 'Clase ${aula.nombre}. Toca tu foto.',
      cuerpo: VistaCarga<List<Estudiante>>(
        controlador: _controlador,
        constructor: (context, estudiantes) => estudiantes.isEmpty
            ? const MensajeInformativo(
                icono: Icons.groups_outlined,
                pictograma: Pictogramas.alumno,
                texto: 'Esta clase todavía no tiene alumnos.',
              )
            : CuadriculaPaginada<Estudiante>(
                elementos: estudiantes,
                anchoMinimoCelda: 210,
                altoMinimoCelda: 200,
                maxColumnas: 5,
                constructor: (context, estudiante) => BotonAccesible(
                  texto: estudiante.nombre,
                  etiquetaSemantica: 'Entrar como ${estudiante.nombre}',
                  color: estudiante.color,
                  imagen: (lado) => AvatarUsuario(
                    nombre: estudiante.nombre,
                    imagen: estudiante.avatar,
                    color: estudiante.color,
                    tamano: lado,
                  ),
                  alPulsar: () => Navigator.pushNamed(
                    context,
                    Rutas.loginEstudiante,
                    arguments: estudiante,
                  ),
                ),
              ),
      ),
    );
  }
}
