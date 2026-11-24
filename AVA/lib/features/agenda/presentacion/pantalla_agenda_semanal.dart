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

/// Agenda de la semana (HU-10): los 7 días a la vez, una columna por día,
/// cada uno con su color.
///
/// Para que las tareas se vean grandes, cada día enseña como mucho
/// [_ColumnaDia.tareasPorTanda] tareas. Si tiene más, debajo hay un botón
/// «Ver más» para pasar a las siguientes; en la última tanda el botón
/// vuelve a las primeras. Nunca hay que desplazarse.
class PantallaAgendaSemanal extends StatefulWidget {
  const PantallaAgendaSemanal({super.key, required this.estudiante});

  final Estudiante estudiante;

  @override
  State<PantallaAgendaSemanal> createState() => _PantallaAgendaSemanalState();
}

class _PantallaAgendaSemanalState extends State<PantallaAgendaSemanal>
    with EstadoAgendaMixin {
  static const _separacionDias = 8.0;

  /// Tanda de tareas que se ve en cada día (0 = las primeras), por día.
  final Map<DateTime, int> _tandas = {};

  @override
  String get idEstudiante => widget.estudiante.id;

  /// Tareas por tanda y letra común de todas las tarjetas de la semana: la
  /// mayor con la que caben todas, para que ninguna se vea más pequeña por
  /// tener un nombre más largo. Cada día enseña siempre
  /// [_ColumnaDia.tareasPorTanda] tareas (o menos si no tiene tantas); el
  /// resto, con «Ver más».
  ({int porTanda, double tamanoTexto, bool conBoton}) _reparto(
    BuildContext context, {
    required double ancho,
    required double alto,
    required String? idActual,
    required String? idSiguiente,
  }) {
    final maximo = math.max(
      1,
      agenda.diasSemana
          .map((dia) => agenda.tareasDelDia(dia).length)
          .fold(0, math.max),
    );
    final porTanda = math.min(_ColumnaDia.tareasPorTanda, maximo);
    final conBoton = maximo > porTanda;
    return (
      porTanda: porTanda,
      tamanoTexto: _tamanoTextoComun(
        context,
        porTanda: porTanda,
        conBoton: conBoton,
        ancho: ancho,
        alto: alto,
        idActual: idActual,
        idSiguiente: idSiguiente,
      ),
      conBoton: conBoton,
    );
  }

  double _tamanoTextoComun(
    BuildContext context, {
    required int porTanda,
    required bool conBoton,
    required double ancho,
    required double alto,
    required String? idActual,
    required String? idSiguiente,
  }) {
    final escala = MediaQuery.textScalerOf(context);
    final estilo = Theme.of(context).textTheme.titleLarge ?? const TextStyle();
    const relleno = 2 * Dimensiones.rellenoCompacto;
    final anchoTarjeta = (ancho - _separacionDias * 6) / 7 - relleno;
    final altoTarjeta =
        _ColumnaDia.altoTarjeta(
          alto,
          porTanda: porTanda,
          conBoton: conBoton,
          escalaTexto: escala.scale(1),
        ) -
        relleno;

    return MedidaTexto.tamanoComun(
      tarjetas: [
        for (final dia in agenda.diasSemana)
          for (final tarea in agenda.tareasDelDia(dia))
            BotonTarea.textos(
              tarea,
              destacado: _ColumnaDia.destacadoDe(tarea, idActual, idSiguiente),
              compacta: true,
            ),
      ],
      estilo: estilo,
      escala: escala,
      ancho: anchoTarjeta,
      alto: altoTarjeta,
      maximo: estilo.fontSize ?? 22,
    );
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
            final reparto = _reparto(
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
                      tanda: _tandas[dia] ?? 0,
                      porTanda: reparto.porTanda,
                      conBoton: reparto.conBoton,
                      idActual: idActual,
                      idSiguiente: idSiguiente,
                      tamanoTexto: reparto.tamanoTexto,
                      altoColumna: restricciones.maxHeight,
                      alPulsarDia: () => _abrirDia(dia),
                      alPulsarTarea: abrirTarea,
                      alCambiarTanda: (tanda) =>
                          setState(() => _tandas[dia] = tanda),
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

/// Un día de la semana: su nombre, una tanda de sus tareas y, si tiene
/// más, el botón para ver las siguientes.
class _ColumnaDia extends StatelessWidget {
  const _ColumnaDia({
    required this.dia,
    required this.esHoy,
    required this.tareas,
    required this.tanda,
    required this.porTanda,
    required this.conBoton,
    required this.idActual,
    required this.idSiguiente,
    required this.tamanoTexto,
    required this.altoColumna,
    required this.alPulsarDia,
    required this.alPulsarTarea,
    required this.alCambiarTanda,
  });

  /// Tareas que se ven a la vez en cada día.
  static const tareasPorTanda = 3;

  static const _altoCabecera = 112.0;
  static const _altoMaximoTarea = 170.0;
  static const _separacion = 8.0;

  final DateTime dia;
  final bool esHoy;
  final List<Tarea> tareas;

  /// Tanda que se ve: 0 son las primeras [porTanda] tareas.
  final int tanda;
  final int porTanda;

  /// Si se reserva el hueco del botón «Ver más» (algún día lo necesita). Se
  /// reserva en todos los días para que las tarjetas queden alineadas.
  final bool conBoton;
  final String? idActual;
  final String? idSiguiente;
  final double tamanoTexto;
  final double altoColumna;
  final VoidCallback alPulsarDia;
  final void Function(Tarea tarea) alPulsarTarea;
  final ValueChanged<int> alCambiarTanda;

  static double _altoBoton(double escalaTexto) =>
      Dimensiones.objetivoTactilMinimo * escalaTexto.clamp(1.0, 1.5);

  /// Alto de cada tarea cuando [porTanda] tareas se reparten la columna.
  static double altoTarjeta(
    double altoColumna, {
    required int porTanda,
    required bool conBoton,
    required double escalaTexto,
  }) {
    final boton = conBoton ? _altoBoton(escalaTexto) + _separacion : 0.0;
    final disponible =
        altoColumna - _altoCabecera - boton - _separacion * porTanda;
    return math.min(
      disponible / porTanda,
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
    final nombreDia = FormatoFecha.nombreDia(dia).toLowerCase();
    final totalTandas = math.max(1, (tareas.length / porTanda).ceil());
    final tandaActual = tanda.clamp(0, totalTandas - 1);
    final esUltima = tandaActual == totalTandas - 1;
    final visibles = tareas.skip(tandaActual * porTanda).take(porTanda);

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
            color: ColorPastel.paraIndice(dia.weekday - 1),
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
        else ...[
          for (final (indice, tarea) in visibles.indexed) ...[
            if (indice > 0) const SizedBox(height: _separacion),
            SizedBox(
              height: altoTarjeta(
                altoColumna,
                porTanda: porTanda,
                conBoton: conBoton,
                escalaTexto: escala,
              ),
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
          const Spacer(),
          if (totalTandas > 1)
            SizedBox(
              height: _altoBoton(escala),
              child: BotonAccesible(
                texto: esUltima ? 'Volver' : 'Ver más',
                etiquetaSemantica: esUltima
                    ? 'Volver a las primeras tareas del $nombreDia'
                    : 'Ver más tareas del $nombreDia',
                color: ColorPastel.paraIndice(dia.weekday - 1),
                disposicion: DisposicionBoton.vertical,
                alPulsar: () => alCambiarTanda(esUltima ? 0 : tandaActual + 1),
              ),
            ),
        ],
      ],
    );
  }
}
