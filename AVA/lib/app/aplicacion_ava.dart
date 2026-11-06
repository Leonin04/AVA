import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../core/tema/tema_app.dart';
import '../features/aulas/dominio/repositorio_aulas.dart';
import '../features/aulas/dominio/repositorio_aulas_simulado.dart';
import '../features/autenticacion/dominio/repositorio_autenticacion.dart';
import '../features/autenticacion/dominio/repositorio_autenticacion_simulado.dart';
import '../features/autenticacion/logica/sesion_controlador.dart';
import '../features/perfil/dominio/repositorio_estudiantes.dart';
import '../features/perfil/dominio/repositorio_estudiantes_simulado.dart';
import '../features/perfil/logica/preferencias_controlador.dart';
import '../features/tareas/dominio/repositorio_tareas.dart';
import '../features/tareas/dominio/repositorio_tareas_simulado.dart';
import 'rutas.dart';

/// Aplicación principal AVA (Agenda Virtual Accesible).
/// Proyecto AUTOVIDA (26-175) - CEE Purísima Concepción de Granada.
class AplicacionAva extends StatelessWidget {
  const AplicacionAva({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Mientras no se conecta Firebase se usan repositorios con datos
        // simulados. Para pasar a Firestore basta con cambiar estas
        // implementaciones: el resto de la app solo conoce las interfaces.
        Provider<RepositorioAulas>(create: (_) => RepositorioAulasSimulado()),
        Provider<RepositorioEstudiantes>(
          create: (_) => RepositorioEstudiantesSimulado(),
        ),
        Provider<RepositorioAutenticacion>(
          create: (_) => RepositorioAutenticacionSimulado(),
        ),
        Provider<RepositorioTareas>(create: (_) => RepositorioTareasSimulado()),
        ChangeNotifierProvider(create: (_) => SesionControlador()),
        ChangeNotifierProvider(
          create: (contexto) =>
              PreferenciasControlador(contexto.read<RepositorioEstudiantes>()),
        ),
      ],
      child: const _AplicacionConTema(),
    );
  }
}

/// Reconstruye el tema cada vez que cambian las preferencias de
/// accesibilidad, para que el cambio afecte a toda la aplicación.
class _AplicacionConTema extends StatelessWidget {
  const _AplicacionConTema();

  @override
  Widget build(BuildContext context) {
    final preferencias = context.watch<PreferenciasControlador>().preferencias;

    return MaterialApp(
      title: 'AVA - Agenda Virtual Accesible',
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'ES'),
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: TemaApp.construir(
        colorBase: Color(preferencias.color.valorArgb),
        modoOscuro: preferencias.modoOscuro,
        altoContraste: preferencias.altoContraste,
      ),
      builder: (contexto, pantalla) {
        // Se combina la escala elegida en AVA con la del sistema operativo.
        final escalaSistema = MediaQuery.textScalerOf(contexto).scale(1);
        return MediaQuery(
          data: MediaQuery.of(contexto).copyWith(
            textScaler: TextScaler.linear(
              escalaSistema * preferencias.escalaTexto,
            ),
          ),
          child: pantalla ?? const SizedBox.shrink(),
        );
      },
      initialRoute: Rutas.inicio,
      onGenerateRoute: Rutas.generar,
    );
  }
}
