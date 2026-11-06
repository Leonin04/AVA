import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/rutas.dart';
import '../../../core/constantes/dimensiones.dart';
import '../../../core/widgets/boton_grande.dart';
import '../../../core/widgets/mensaje_informativo.dart';
import '../../../core/widgets/vista_carga.dart';
import '../dominio/aula.dart';
import '../dominio/repositorio_aulas.dart';
import '../logica/aulas_controlador.dart';

/// Pantalla de inicio: título de la app y clases del centro. El botón de
/// arriba a la derecha lleva al acceso del profesorado.
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
              Align(
                alignment: Alignment.topRight,
                child: IconButton.filledTonal(
                  tooltip: 'Acceso para profesorado',
                  onPressed: () =>
                      Navigator.pushNamed(context, Rutas.loginAdministrador),
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                ),
              ),
              const _TituloAplicacion(),
              const SizedBox(height: Dimensiones.espaciado * 2),
              Expanded(
                child: VistaCarga<List<Aula>>(
                  controlador: _controlador,
                  constructor: (context, aulas) =>
                      _CuadriculaAulas(aulas: aulas),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TituloAplicacion extends StatelessWidget {
  const _TituloAplicacion();

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Semantics(
      header: true,
      child: Container(
        width: 360,
        padding: const EdgeInsets.symmetric(vertical: Dimensiones.espaciado),
        decoration: BoxDecoration(
          color: esquema.primary,
          borderRadius: BorderRadius.circular(Dimensiones.radioBorde),
        ),
        child: Text(
          'AVA',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: esquema.onPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}

class _CuadriculaAulas extends StatelessWidget {
  const _CuadriculaAulas({required this.aulas});

  final List<Aula> aulas;

  @override
  Widget build(BuildContext context) {
    if (aulas.isEmpty) {
      return const MensajeInformativo(
        icono: Icons.school_outlined,
        texto: 'Todavía no hay clases',
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: Dimensiones.espaciado * 1.5,
            crossAxisSpacing: Dimensiones.espaciado * 3,
            childAspectRatio: 2.2,
          ),
          itemCount: aulas.length,
          itemBuilder: (context, indice) {
            final aula = aulas[indice];
            return BotonGrande(
              texto: aula.nombre,
              alto: null,
              alPulsar: () =>
                  Navigator.pushNamed(context, Rutas.alumnosAula, arguments: aula),
            );
          },
        ),
      ),
    );
  }
}
