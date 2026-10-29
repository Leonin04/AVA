import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AplicacionAda());
}

/// Aplicación principal ADA (Agenda Digital Accesible)
/// Proyecto AUTOVIDA (26-175) - CEE Purísima Concepción de Granada
class AplicacionAda extends StatelessWidget {
  const AplicacionAda({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADA - Agenda Accesible',
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
      home: const PantallaInicio(),
    );
  }
}

class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADA - Agenda Accesible'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.accessibility_new_rounded,
                size: 80,
                color: Color(0xFF0D47A1),
              ),
              SizedBox(height: 24),
              Text(
                'Proyecto AUTOVIDA',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'Agenda Digital Accesible para el CEE Purísima Concepción',
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
