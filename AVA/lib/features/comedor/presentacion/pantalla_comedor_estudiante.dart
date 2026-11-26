import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/dimensiones.dart';
import '../../../core/constantes/paleta.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/utilidades/formato_fecha.dart';
import '../../../core/widgets/boton_accesible.dart';
import '../../../core/widgets/pantalla_estudiante.dart';
import '../../../core/widgets/vista_carga.dart';
import '../../aulas/dominio/ficha_aula.dart';
import '../../aulas/dominio/repositorio_aulas.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../dominio/repositorio_comedor.dart';
import '../logica/comedor_controladores.dart';

/// Comedor del estudiante (HU-23, boceto de la figura 3): los días de la
/// semana, de lunes a viernes, y en cada uno si va al comedor. Tocando un
/// día se cambia. Si es el encargado de su aula, puede pasar la lista de su
/// clase.
class PantallaComedorEstudiante extends StatefulWidget {
  const PantallaComedorEstudiante({super.key, required this.estudiante});

  final Estudiante estudiante;

  @override
  State<PantallaComedorEstudiante> createState() =>
      _PantallaComedorEstudianteState();
}

class _PantallaComedorEstudianteState extends State<PantallaComedorEstudiante> {
  late final ComedorEstudianteControlador _controlador;
  Aula? _aula;

  bool get _esEncargado => _aula?.idEncargadoComedor == widget.estudiante.id;

  @override
  void initState() {
    super.initState();
    _controlador = ComedorEstudianteControlador(
      comedor: context.read<RepositorioComedor>(),
      estudiante: widget.estudiante,
    );
    unawaited(_controlador.cargar());
    unawaited(_cargarAula());
  }

  Future<void> _cargarAula() async {
    final idAula = widget.estudiante.idAula;
    final aula = idAula == null
        ? null
        : await context.read<RepositorioAulas>().obtener(idAula);
    if (mounted) setState(() => _aula = aula);
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  static String _respuesta(bool? come) => switch (come) {
    true => 'Voy al comedor',
    false => 'No voy al comedor',
    null => 'Toca para elegir',
  };

  @override
  Widget build(BuildContext context) {
    return PantallaEstudiante(
      titulo: 'Comedor',
      pictograma: Pictogramas.comer,
      icono: Icons.restaurant_rounded,
      color: ColorPastel.melocoton,
      textoVoz: 'Comedor. Toca cada día para decir si vas al comedor.',
      cuerpo: VistaCarga<List<DiaComedor>>(
        controlador: _controlador,
        constructor: (context, dias) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (indice, dia) in dias.indexed) ...[
                    if (indice > 0)
                      const SizedBox(width: Dimensiones.espaciadoPequeno),
                    Expanded(
                      child: BotonAccesible(
                        texto: FormatoFecha.nombreDia(dia.dia),
                        textoSecundario: _respuesta(dia.come),
                        etiquetaSemantica:
                            '${FormatoFecha.diaCompleto(dia.dia)}: '
                            '${_respuesta(dia.come)}',
                        icono: dia.come == true
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        color: dia.come == true
                            ? ColorPastel.menta
                            : ColorPastel.paraIndice(dia.dia.weekday - 1),
                        seleccionado: dia.come == true,
                        alPulsar: () => _controlador.cambiar(dia),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_esEncargado) ...[
              const SizedBox(height: Dimensiones.espaciado),
              SizedBox(
                height: Dimensiones.altoBotonGrande,
                child: BotonAccesible(
                  texto: 'Lista de mi clase',
                  etiquetaSemantica: 'Pasar la lista del comedor de mi clase',
                  pictograma: Pictogramas.alumno,
                  icono: Icons.checklist_rounded,
                  color: ColorPastel.cielo,
                  disposicion: DisposicionBoton.horizontal,
                  alPulsar: () => Navigator.pushNamed(
                    context,
                    Rutas.listaComedor,
                    arguments: _aula,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
