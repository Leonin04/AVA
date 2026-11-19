import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/dimensiones.dart';
import '../../../core/constantes/paleta.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/utilidades/formato_fecha.dart';
import '../../../core/utilidades/medida_texto.dart';
import '../../../core/widgets/boton_accesible.dart';
import '../../../core/widgets/pantalla_estudiante.dart';
import '../../../core/widgets/vista_carga.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../../tareas/dominio/tarea_agenda.dart';
import '../logica/calculos_agenda.dart';
import 'widgets/boton_tarea.dart';
import 'widgets/estado_agenda_mixin.dart';

/// Agenda de la semana (HU-10): una columna por día, de lunes a domingo,
/// cada día con su color. Se ven todas las tareas de la semana a la vez:
/// cada día reparte su alto entre sus tareas. Nunca hay que desplazarse.
class PantallaAgendaSemanal extends StatefulWidget {
  const PantallaAgendaSemanal({super.key, required this.estudiante});

  final Estudiante estudiante;

  @override
  State<PantallaAgendaSemanal> createState() => _PantallaAgendaSemanalState();
}

class _PantallaAgendaSemanalState extends State<PantallaAgendaSemanal>
    with EstadoAgendaMixin {
  static const _separacionDias = 8.0;

  @override
  String get idEstudiante => widget.estudiante.id;

  /// Letra común a todas las tarjetas de la semana: la mayor con la que
  /// caben todas. Así ninguna se ve más pequeña que las demás por tener un
  /// nombre más largo; el pictograma usa el espacio que sobre.
  double _tamanoTextoComun(
    BuildContext context, {
    required double ancho,
    required double alto,
    required String? idActual,
    required String? idSiguiente,
  }) {
    final escala = MediaQuery.textScalerOf(context);
    final estilo = Theme.of(context).textTheme.titleLarge ?? const TextStyle();
    final maximo = estilo.fontSize ?? 22;
    const relleno = 2 * Dimensiones.rellenoCompacto;
    final anchoTarjeta = (ancho - _separacionDias * 6) / 7 - relleno;

    var tamano = maximo;
    for (final dia in agenda.diasSemana) {
      final tareas = agenda.tareasDelDia(dia);
      if (tareas.isNotEmpty) {
        final altoTarjeta =
            _ColumnaDia.altoTarjeta(alto, tareas.length, escala.scale(1)) -
            relleno;
        final tamanoDia = MedidaTexto.tamanoComun(
          tarjetas: [
            for (final tarea in tareas)
              BotonTarea.textos(
                tarea,
                destacado: _ColumnaDia.destacadoDe(
                  tarea,
                  idActual,
                  idSiguiente,
                ),
                compacta: true,
              ),
          ],
          estilo: estilo,
          escala: escala,
          ancho: anchoTarjeta,
          alto: altoTarjeta,
          maximo: maximo,
        );
        tamano = math.min(tamano, tamanoDia);
      }
    }
    return tamano;
  }

  Future<void> _abrirDia(DateTime dia) async {
    await Navigator.pushNamed(context, Rutas.agendaDiaria, arguments: dia);
    if (mounted) await agenda.cargar();
  }

  @override
  Widget build(BuildContext context) {
    return PantallaEstudiante(
      titulo: 'Mi semana',
      pictograma: Pictogramas.semana,
      icono: Icons.view_week_rounded,
      textoVoz: 'Mi semana. Toca un día para ver sus tareas.',
      cuerpo: VistaCarga<List<Tarea>>(
        controlador: agenda,
        constructor: (context, _) => LayoutBuilder(
          builder: (context, restricciones) {
            final idActual = agenda.tareaActual?.id;
            final idSiguiente = agenda.siguienteTarea?.id;
            final tamanoTexto = _tamanoTextoComun(
              context,
              ancho: restricciones.maxWidth,
              alto: restricciones.maxHeight,
              idActual: idActual,
              idSiguiente: idSiguiente,
            );

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (indice, dia) in agenda.diasSemana.indexed) ...[
                  if (indice > 0) const SizedBox(width: _separacionDias),
                  Expanded(
                    child: _ColumnaDia(
                      dia: dia,
                      esHoy: CalculosAgenda.esMismoDia(dia, agenda.ahora),
                      tareas: agenda.tareasDelDia(dia),
                      idActual: idActual,
                      idSiguiente: idSiguiente,
                      tamanoTexto: tamanoTexto,
                      altoColumna: restricciones.maxHeight,
                      alPulsarDia: () => _abrirDia(dia),
                      alPulsarTarea: abrirTarea,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ColumnaDia extends StatelessWidget {
  const _ColumnaDia({
    required this.dia,
    required this.esHoy,
    required this.tareas,
    required this.idActual,
    required this.idSiguiente,
    required this.tamanoTexto,
    required this.altoColumna,
    required this.alPulsarDia,
    required this.alPulsarTarea,
  });

  static const _altoCabecera = 112.0;
  static const _altoMaximoTarea = 150.0;
  static const _separacion = 8.0;

  final DateTime dia;
  final bool esHoy;
  final List<Tarea> tareas;
  final String? idActual;
  final String? idSiguiente;
  final double tamanoTexto;
  final double altoColumna;
  final VoidCallback alPulsarDia;
  final void Function(Tarea tarea) alPulsarTarea;

  /// Alto de cada tarea cuando [cantidad] tareas se reparten una columna de
  /// [altoColumna], para verlas todas a la vez sin desplazarse.
  static double altoTarjeta(
    double altoColumna,
    int cantidad,
    double escalaTexto,
  ) {
    final disponible = altoColumna - _altoCabecera - _separacion * cantidad;
    return math.min(
      disponible / cantidad,
      _altoMaximoTarea * escalaTexto.clamp(1.0, 2.0),
    );
  }

  static DestacadoTarea destacadoDe(
    Tarea tarea,
    String? idActual,
    String? idSiguiente,
  ) => tarea.id == idActual
      ? DestacadoTarea.ahora
      : tarea.id == idSiguiente
      ? DestacadoTarea.despues
      : DestacadoTarea.ninguno;

  @override
  Widget build(BuildContext context) {
    final escala = MediaQuery.textScalerOf(context).scale(1);
    final color = ColorPastel.paraIndice(dia.weekday - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _altoCabecera,
          child: BotonAccesible(
            texto: FormatoFecha.nombreDia(dia),
            textoSecundario: esHoy ? 'Hoy' : '${dia.day}',
            etiquetaSemantica:
                'Ver ${esHoy ? 'hoy, ' : ''}${FormatoFecha.diaCompleto(dia)}',
            color: color,
            seleccionado: esHoy,
            alPulsar: alPulsarDia,
          ),
        ),
        const SizedBox(height: _separacion),
        if (tareas.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'Sin tareas',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          )
        else
          for (final (indice, tarea) in tareas.indexed) ...[
            if (indice > 0) const SizedBox(height: _separacion),
            SizedBox(
              height: altoTarjeta(altoColumna, tareas.length, escala),
              child: BotonTarea(
                tarea: tarea,
                compacta: true,
                tamanoTexto: tamanoTexto,
                disposicion: DisposicionBoton.vertical,
                destacado: destacadoDe(tarea, idActual, idSiguiente),
                alPulsar: () => alPulsarTarea(tarea),
              ),
            ),
          ],
      ],
    );
  }
}
