import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/widgets/avatar_usuario.dart';
import '../../../core/widgets/boton_accesible.dart';
import '../../../core/widgets/cuadricula_paginada.dart';
import '../../../core/widgets/mensaje_informativo.dart';
import '../../../core/widgets/pantalla_gestion.dart';
import '../../../core/widgets/vista_carga.dart';
import '../../autenticacion/dominio/cuenta.dart';
import '../../autenticacion/logica/permisos.dart';
import '../../aulas/dominio/repositorio_aulas.dart';
import '../dominio/repositorio_estudiantes.dart';
import '../logica/lista_alumnos_controlador.dart';

/// Alumnos que el tutor tiene asignados (todos, para la administración).
class PantallaListaAlumnos extends StatefulWidget {
  const PantallaListaAlumnos({super.key, required this.cuenta});

  final Cuenta cuenta;

  @override
  State<PantallaListaAlumnos> createState() => _PantallaListaAlumnosState();
}

class _PantallaListaAlumnosState extends State<PantallaListaAlumnos> {
  late final ListaAlumnosControlador _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = ListaAlumnosControlador(
      estudiantes: context.read<RepositorioEstudiantes>(),
      aulas: context.read<RepositorioAulas>(),
      cuenta: widget.cuenta,
    );
    unawaited(_controlador.cargar());
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _abrir(String id) async {
    await Navigator.pushNamed(context, Rutas.fichaEstudiante, arguments: id);
    if (mounted) await _controlador.cargar();
  }

  @override
  Widget build(BuildContext context) {
    return PantallaGestion(
      titulo: Permisos.esAdministrador(widget.cuenta)
          ? 'Alumnos'
          : 'Mis alumnos',
      desplazable: false,
      cuerpo: VistaCarga<List<AlumnoConAula>>(
        controlador: _controlador,
        constructor: (context, alumnos) => alumnos.isEmpty
            ? const MensajeInformativo(
                icono: Icons.groups_outlined,
                pictograma: Pictogramas.alumno,
                texto: 'No tienes alumnos asignados todavía.',
              )
            : CuadriculaPaginada<AlumnoConAula>(
                elementos: alumnos,
                maxColumnas: 5,
                anchoMinimoCelda: 180,
                altoMinimoCelda: 190,
                constructor: (context, alumno) {
                  final e = alumno.estudiante;
                  return BotonAccesible(
                    texto: e.nombre,
                    textoSecundario: alumno.aula?.nombre ?? 'Sin aula',
                    color: e.color,
                    imagen: (lado) => AvatarUsuario(
                      nombre: e.nombre,
                      imagen: e.avatar,
                      color: e.color,
                      tamano: lado,
                    ),
                    alPulsar: () => _abrir(e.id),
                  );
                },
              ),
      ),
    );
  }
}
