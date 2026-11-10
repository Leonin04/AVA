import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/aplicacion_ava.dart';
import 'core/servicios/autenticacion.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
    // Sesión anónima de la tableta: permite ver aulas y alumnos antes de
    // que entre nadie (HU-09).
    await Autenticacion().prepararTableta();
  } catch (error) {
    // Si Firebase no arranca, se explica en pantalla en vez de dejarla vacía.
    runApp(ErrorInicio(error: '$error'));
    return;
  }

  runApp(const AplicacionAva(conFirebase: true));
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
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 72),
                const SizedBox(height: 16),
                const Text(
                  'No se ha podido conectar con la base de datos.\n'
                  'Comprueba la conexión a Internet y vuelve a abrir AVA.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 16),
                SelectableText(error, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
