import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'pantalla_login.dart';

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

/// Decide qué pantalla mostrar según haya sesión iniciada o no.
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
        if (snapshot.hasData) {
          return PantallaInicio(usuario: snapshot.data!);
        }
        return const PantallaLogin();
      },
    );
  }
}

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
            onPressed: () => FirebaseAuth.instance.signOut(),
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