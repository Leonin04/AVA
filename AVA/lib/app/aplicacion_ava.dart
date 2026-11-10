import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../core/servicios/almacen_simulado.dart';
import '../core/servicios/servicio_arasaac.dart';
import '../core/servicios/servicio_voz.dart';
import '../core/tema/ajustes_interfaz.dart';
import '../core/tema/tema_app.dart';
import '../features/aulas/dominio/repositorio_aulas.dart';
import '../features/aulas/dominio/repositorio_aulas_firebase.dart';
import '../features/aulas/dominio/repositorio_aulas_simulado.dart';
import '../features/autenticacion/dominio/repositorio_autenticacion.dart';
import '../features/autenticacion/dominio/repositorio_autenticacion_firebase.dart';
import '../features/autenticacion/dominio/repositorio_autenticacion_simulado.dart';
import '../features/autenticacion/dominio/repositorio_cuentas.dart';
import '../features/autenticacion/dominio/repositorio_cuentas_firebase.dart';
import '../features/autenticacion/dominio/repositorio_cuentas_simulado.dart';
import '../features/autenticacion/logica/sesion_controlador.dart';
import '../features/perfil/dominio/repositorio_estudiantes.dart';
import '../features/perfil/dominio/repositorio_estudiantes_firebase.dart';
import '../features/perfil/dominio/repositorio_estudiantes_simulado.dart';
import '../features/perfil/logica/preferencias_controlador.dart';
import '../features/tareas/dominio/repositorio_tareas.dart';
import '../features/tareas/dominio/repositorio_tareas_firebase.dart';
import '../features/tareas/dominio/repositorio_tareas_simulado.dart';
import 'datos_iniciales.dart';
import 'rutas.dart';

/// Aplicación principal AVA (Agenda Virtual Accesible).
/// Proyecto AUTOVIDA (26-175) - CEE Purísima Concepción de Granada.
class AplicacionAva extends StatelessWidget {
  const AplicacionAva({
    super.key,
    this.conFirebase = false,
    this.almacen,
    this.voz,
  });

  /// Usar la base de datos de Firebase. Si es `false` se usan datos
  /// simulados en memoria (pruebas automáticas).
  final bool conFirebase;

  /// Datos simulados de partida. Por defecto, los de `datos_iniciales.dart`.
  final AlmacenSimulado? almacen;

  /// Síntesis de voz. Por defecto, la del dispositivo.
  final ServicioVoz? voz;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // La interfaz solo conoce las interfaces de los repositorios; aquí se
      // elige si leen de Firebase o de los datos simulados.
      providers: [
        ...conFirebase ? _repositoriosFirebase() : _repositoriosSimulados(),
        Provider<ServicioArasaac>(create: (_) => ServicioArasaac()),
        Provider<ServicioVoz>(create: (_) => voz ?? ServicioVozDispositivo()),
        ChangeNotifierProvider(create: (_) => SesionControlador()),
        ChangeNotifierProvider(
          create: (c) =>
              PreferenciasControlador(c.read<RepositorioEstudiantes>()),
        ),
      ],
      child: const _AplicacionConTema(),
    );
  }

  List<SingleChildWidget> _repositoriosFirebase() => [
    Provider<RepositorioAulas>(create: (_) => RepositorioAulasFirebase()),
    Provider<RepositorioEstudiantes>(
      create: (_) => RepositorioEstudiantesFirebase(),
    ),
    Provider<RepositorioCuentas>(create: (_) => RepositorioCuentasFirebase()),
    Provider<RepositorioAutenticacion>(
      create: (c) => RepositorioAutenticacionFirebase(
        estudiantes: c.read<RepositorioEstudiantes>(),
      ),
    ),
    Provider<RepositorioTareas>(create: (_) => RepositorioTareasFirebase()),
  ];

  List<SingleChildWidget> _repositoriosSimulados() => [
    Provider<AlmacenSimulado>(
      create: (_) => almacen ?? _almacenConDatosIniciales(),
    ),
    Provider<RepositorioAulas>(
      create: (c) => RepositorioAulasSimulado(c.read<AlmacenSimulado>()),
    ),
    Provider<RepositorioEstudiantes>(
      create: (c) => RepositorioEstudiantesSimulado(c.read<AlmacenSimulado>()),
    ),
    Provider<RepositorioCuentas>(
      create: (c) => RepositorioCuentasSimulado(c.read<AlmacenSimulado>()),
    ),
    Provider<RepositorioAutenticacion>(
      create: (c) =>
          RepositorioAutenticacionSimulado(c.read<AlmacenSimulado>()),
    ),
    Provider<RepositorioTareas>(
      create: (c) => RepositorioTareasSimulado(c.read<AlmacenSimulado>()),
    ),
  ];
}

AlmacenSimulado _almacenConDatosIniciales() {
  final almacen = AlmacenSimulado();
  cargarDatosIniciales(almacen);
  return almacen;
}

/// Reconstruye el tema cada vez que cambian las preferencias de
/// accesibilidad, para que el cambio afecte a toda la aplicación.
class _AplicacionConTema extends StatelessWidget {
  const _AplicacionConTema();

  @override
  Widget build(BuildContext context) {
    final preferencias = context.watch<PreferenciasControlador>().preferencias;
    final voz = context.read<ServicioVoz>();

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
        color: preferencias.color,
        modoOscuro: preferencias.modoOscuro,
        altoContraste: preferencias.altoContraste,
        letraClara: preferencias.letraClara,
      ),
      builder: (contexto, pantalla) {
        // Se combina la escala elegida en AVA con la del sistema operativo.
        final escalaSistema = MediaQuery.textScalerOf(contexto).scale(1);
        return MediaQuery(
          data: MediaQuery.of(contexto).copyWith(
            textScaler: TextScaler.linear(
              escalaSistema * preferencias.tamanoTexto.escala,
            ),
          ),
          child: AjustesInterfaz(
            voz: voz,
            leerEnVoz: preferencias.leerEnVoz,
            botonEscuchar: preferencias.botonEscuchar,
            filtroAntitemblor: preferencias.filtroAntitemblor,
            mostrarPictogramas: preferencias.mostrarPictogramas,
            mostrarTexto: preferencias.mostrarTexto,
            altoContraste: preferencias.altoContraste,
            modoOscuro: preferencias.modoOscuro,
            menuArriba: preferencias.menuArriba,
            child: pantalla ?? const SizedBox.shrink(),
          ),
        );
      },
      initialRoute: Rutas.inicio,
      onGenerateRoute: Rutas.generar,
    );
  }
}
