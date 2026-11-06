import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/dimensiones.dart';
import '../../../core/constantes/paleta.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/tema/ajustes_interfaz.dart';
import '../../../core/widgets/atribucion_arasaac.dart';
import '../../../core/widgets/boton_accesible.dart';
import '../../../core/widgets/cuadricula_paginada.dart';
import '../../../core/widgets/mensaje_informativo.dart';
import '../../../core/widgets/pictograma.dart';
import '../../../core/widgets/vista_carga.dart';
import '../dominio/aula.dart';
import '../dominio/repositorio_aulas.dart';
import '../logica/aulas_controlador.dart';

/// Pantalla de inicio: título de la app y clases del centro, cada una con
/// su color y su pictograma. Arriba a la derecha, el acceso del
/// profesorado.
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  late final AulasControlador _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = AulasControlador(context.read<RepositorioAulas>());
    unawaited(_controlador.cargar());
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voz = AjustesInterfaz.of(context).voz;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Dimensiones.espaciado),
          child: Column(
            children: [
              SizedBox(
                height: Dimensiones.altoBarraNavegacion,
                child: Row(
                  children: [
                    SizedBox(
                      width: 290,
                      child: BotonAccesible(
                        texto: 'Escuchar',
                        pictograma: Pictogramas.escuchar,
                        icono: Icons.volume_up_rounded,
                        color: ColorPastel.amarillo,
                        disposicion: DisposicionBoton.horizontal,
                        alPulsar: () => voz.decir('Hola. Toca tu clase.'),
                      ),
                    ),
                    const Spacer(),
                    const _Logotipo(),
                    const Spacer(),
                    SizedBox(
                      width: 290,
                      child: BotonAccesible(
                        texto: 'Profesorado',
                        etiquetaSemantica: 'Acceso para profesorado',
                        pictograma: Pictogramas.maestro,
                        icono: Icons.admin_panel_settings_rounded,
                        color: ColorPastel.lavanda,
                        disposicion: DisposicionBoton.horizontal,
                        alPulsar: () =>
                            Navigator.pushNamed(context, Rutas.loginGestion),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensiones.espaciado),
              Text(
                'Toca tu clase',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: Dimensiones.espaciado),
              Expanded(
                child: VistaCarga<List<Aula>>(
                  controlador: _controlador,
                  constructor: (context, aulas) => aulas.isEmpty
                      ? const MensajeInformativo(
                          icono: Icons.school_outlined,
                          pictograma: Pictogramas.colegio,
                          texto: 'Todavía no hay clases.',
                        )
                      : Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1000),
                            child: CuadriculaPaginada<Aula>(
                              elementos: aulas,
                              maxColumnas: 2,
                              anchoMinimoCelda: 280,
                              altoMinimoCelda: 160,
                              altoMaximoCelda: 240,
                              espaciado: Dimensiones.espaciado * 1.5,
                              constructor: (context, aula) => BotonAccesible(
                                texto: aula.nombre,
                                etiquetaSemantica: 'Clase ${aula.nombre}',
                                pictograma: aula.pictograma ?? Pictogramas.aula,
                                icono: Icons.groups_rounded,
                                color: aula.color,
                                textoGrande: true,
                                disposicion: DisposicionBoton.horizontal,
                                alPulsar: () => Navigator.pushNamed(
                                  context,
                                  Rutas.alumnosAula,
                                  arguments: aula,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: Dimensiones.espaciadoPequeno),
              const AtribucionArasaac(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logotipo extends StatelessWidget {
  const _Logotipo();

  @override
  Widget build(BuildContext context) {
    final estilo = AjustesInterfaz.of(context).estiloDe(ColorPastel.cielo);

    return Semantics(
      header: true,
      label: 'AVA, Agenda Virtual Accesible',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        decoration: BoxDecoration(
          color: estilo.fondo,
          borderRadius: BorderRadius.circular(Dimensiones.radioBorde),
          border: Border.all(
            color: estilo.borde,
            width: Dimensiones.grosorBorde,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Pictograma(
              recurso: Pictogramas.agenda,
              tamano: 60,
              iconoRespaldo: Icons.calendar_month_rounded,
              colorRespaldo: estilo.acento,
            ),
            const SizedBox(width: 16),
            Text(
              'AVA',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: estilo.texto,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
