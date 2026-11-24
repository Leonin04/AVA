import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constantes/paleta.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/utilidades/formato_fecha.dart';
import '../../../core/widgets/avatar_usuario.dart';
import '../../../core/widgets/boton_accesible.dart';
import '../../../core/widgets/cuadricula_ajustada.dart';
import '../../../core/widgets/pantalla_estudiante.dart';
import '../../../core/widgets/vista_carga.dart';
import '../../aulas/dominio/ficha_aula.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../../perfil/dominio/repositorio_estudiantes.dart';
import '../dominio/comedor.dart';
import '../dominio/repositorio_comedor.dart';
import '../logica/comedor_controladores.dart';
import '../logica/listado_cocina.dart';

/// El estudiante encargado pasa la lista del comedor de su aula para hoy
/// (HU-23, T-113, T-114): cada compañero con su nombre y si come. Solo ve
/// «come / no come», nunca las dietas (T-117).
class PantallaListaComedor extends StatefulWidget {
  const PantallaListaComedor({
    super.key,
    required this.encargado,
    required this.aula,
  });

  final Estudiante encargado;
  final Aula aula;

  @override
  State<PantallaListaComedor> createState() => _PantallaListaComedorState();
}

class _PantallaListaComedorState extends State<PantallaListaComedor> {
  late final ListaComedorControlador _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = ListaComedorControlador(
      comedor: context.read<RepositorioComedor>(),
      estudiantes: context.read<RepositorioEstudiantes>(),
      aula: widget.aula,
      // Hoy, o el lunes si es fin de semana.
      fecha: CalculosComedor.proximoDiaDeComedor(DateTime.now()),
      origen: OrigenAsistencia.encargado,
      idActor: widget.encargado.id,
    );
    unawaited(_controlador.cargar());
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  static String _respuesta(AsistenciaComedor? asistencia) =>
      switch (asistencia?.come) {
        true => 'Come',
        false => 'No come',
        null => 'Sin responder',
      };

  @override
  Widget build(BuildContext context) {
    final dia = FormatoFecha.diaCompleto(_controlador.fecha);
    return PantallaEstudiante(
      titulo: 'Comedor de ${widget.aula.nombre}',
      pictograma: Pictogramas.comer,
      icono: Icons.restaurant_rounded,
      color: ColorPastel.melocoton,
      textoVoz:
          'Comedor de ${widget.aula.nombre}, $dia. Toca a cada compañero '
          'para decir si come.',
      cuerpo: VistaCarga<List<FilaComedor>>(
        controlador: _controlador,
        constructor: (context, filas) => CuadriculaAjustada<FilaComedor>(
          elementos: filas,
          maxColumnas: 5,
          anchoMinimoCelda: 200,
          altoMinimoCelda: 170,
          constructor: (context, fila) => BotonAccesible(
            texto: fila.estudiante.nombre,
            textoSecundario: _respuesta(fila.asistencia),
            etiquetaSemantica:
                '${fila.estudiante.nombre}: ${_respuesta(fila.asistencia)}',
            imagen: (lado) => AvatarUsuario(
              nombre: fila.estudiante.nombre,
              imagen: fila.estudiante.avatar,
              color: fila.estudiante.color,
              tamano: lado,
            ),
            color: fila.asistencia?.come == true
                ? ColorPastel.menta
                : fila.estudiante.color,
            seleccionado: fila.asistencia?.come == true,
            alPulsar: () => _controlador.marcar(
              fila.estudiante,
              come: !(fila.asistencia?.come ?? false),
            ),
          ),
        ),
      ),
    );
  }
}
