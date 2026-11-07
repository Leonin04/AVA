import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/servicios/autenticacion.dart';
import 'features/aulas/presentacion/pantalla_clase.dart';
import 'features/aulas/presentacion/pantalla_seleccion_aula.dart';
import 'features/autenticacion/presentacion/pantalla_login_admin.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
  } catch (e) {
    // Si Firebase falla, mostramos el error en pantalla en vez de dejarla en blanco.
    runApp(ErrorInicio(error: e.toString()));
    return;
  }

  runApp(const AplicacionAva());
}

/// Aplicación principal AVA (Agenda Virtual Accesible)
/// Proyecto AUTOVIDA (26-175) - CEE Purísima Concepción de Granada
class AplicacionAva extends StatelessWidget {
  const AplicacionAva({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AVA - Agenda Virtual Accesible',
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'ES'),
      supportedLocales: const [
        Locale('es', 'ES'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1), // Azul institucional accesible
          brightness: Brightness.light,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

/// Decide qué pantalla mostrar según la sesión:
/// - sin sesión: prepara la tableta (sesión anónima);
/// - sesión anónima: pantalla de inicio con las aulas;
/// - sesión de admin, tutor o alumno: su pantalla (de momento, [PantallaInicio]).
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // userChanges también avisa cuando se actualiza el nombre del usuario.
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final usuario = snapshot.data;
        if (usuario == null) return const PreparandoTableta();
        if (usuario.isAnonymous) return const PantallaTableta();
        return PantallaInicio(usuario: usuario);
      },
    );
  }
}

/// Abre la sesión anónima de la tableta. Se ve solo un instante.
class PreparandoTableta extends StatefulWidget {
  const PreparandoTableta({super.key});

  @override
  State<PreparandoTableta> createState() => _PreparandoTabletaState();
}

class _PreparandoTabletaState extends State<PreparandoTableta> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _preparar();
  }

  Future<void> _preparar() async {
    setState(() => _error = null);
    try {
      await Autenticacion().prepararTableta();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _error == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'No se pudo preparar la tableta.',
                      style: TextStyle(fontSize: 22),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _preparar,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Pantalla de inicio de la tableta: AVA, aulas y acceso de administración.
class PantallaTableta extends StatelessWidget {
  const PantallaTableta({super.key});

  @override
  Widget build(BuildContext context) {
    return PantallaSeleccionAula(
      alAbrirAva: () {
        // Pendiente: aún no está definido qué abre el botón AVA.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AVA estará disponible pronto.')),
        );
      },
      alElegirAula: (aula) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PantallaClase(aula: aula)),
      ),
      alAbrirAdmin: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PantallaLoginAdmin()),
      ),
    );
  }
}

/// Pantalla provisional para quien ya ha iniciado sesión (admin, tutor o alumno).
class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key, required this.usuario});

  final User usuario;

  @override
  Widget build(BuildContext context) {
    final nombre = (usuario.displayName?.isNotEmpty ?? false)
        ? usuario.displayName!
        : (usuario.email ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('AVA - Agenda Virtual Accesible'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => Autenticacion().salir(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.accessibility_new_rounded,
                size: 80,
                color: Color(0xFF0D47A1),
              ),
              const SizedBox(height: 24),
              Text(
                'Hola, $nombre',
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Proyecto AUTOVIDA\nAgenda Virtual Accesible para el CEE Purísima Concepción',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Se muestra solo si Firebase no consigue arrancar.
class ErrorInicio extends StatelessWidget {
  const ErrorInicio({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'No se pudo iniciar Firebase',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SelectableText(error),
                  const SizedBox(height: 16),
                  const Text(
                    'Ejecuta "flutterfire configure", selecciona la plataforma '
                    'web y reinicia la app.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}