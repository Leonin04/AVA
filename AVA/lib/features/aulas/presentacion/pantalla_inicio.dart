import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/dimensiones.dart';
import '../../../core/constantes/paleta.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/tema/ajustes_interfaz.dart';
import '../../../core/widgets/atribucion_arasaac.dart';
import '../../../core/widgets/boton_accesible.dart';
import '../../../core/widgets/cuadricula_ajustada.dart';
import '../../../core/widgets/mensaje_informativo.dart';
import '../../../core/widgets/pantalla_estudiante.dart';
import '../../../core/widgets/vista_carga.dart';
import '../dominio/ficha_aula.dart';
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
                    _HuecoBoton(
                      alineacion: Alignment.centerLeft,
                      child: AjustesInterfaz.of(context).botonEscuchar
                          ? BotonAccesible(
                              texto: 'Escuchar',
                              pictograma: Pictogramas.escuchar,
                              icono: Icons.volume_up_rounded,
                              color: ColorPastel.amarillo,
                              disposicion: DisposicionBoton.horizontal,
                              alPulsar: () =>
                                  escuchar(context, 'Hola. Toca tu clase.'),
                            )
                          : null,
                    ),
                    const SizedBox(width: Dimensiones.espaciado),
                    const _Logotipo(),
                    const SizedBox(width: Dimensiones.espaciado),
                    _HuecoBoton(
                      alineacion: Alignment.centerRight,
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
                            child: CuadriculaAjustada<Aula>(
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
    return Semantics(
      header: true,
      label: 'AVA, Agenda Virtual Accesible',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensiones.radioBorde),
        child: Image.asset(
          'assets/iconos/logo_AVA.jpg',
          height: Dimensiones.altoBarraNavegacion,
          fit: BoxFit.contain,
          semanticLabel: 'AVA, Agenda Virtual Accesible',
        ),
      ),
    );
  }
}

/// Hueco lateral de la barra superior. El botón mide como mucho 290 px y
/// se estrecha si la pantalla no da para más; si no hay botón, el hueco se
/// mantiene para que el logotipo quede exactamente centrado.
class _HuecoBoton extends StatelessWidget {
  const _HuecoBoton({required this.alineacion, required this.child});

  final Alignment alineacion;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final boton = child;
    return Expanded(
      child: LayoutBuilder(
        builder: (context, restricciones) {
          final ancho = math.min(290.0, restricciones.maxWidth);
          return Align(
            alignment: alineacion,
            child: boton != null
                ? SizedBox(
                    width: ancho,
                    height: double.infinity,
                    child: boton,
                  )
                : const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
