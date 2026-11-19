import 'package:flutter/material.dart';

import '../app/aplicacion_ava.dart';

/// SOLO DESARROLLO: la app con los datos simulados de
/// `app/datos_iniciales.dart`, sin Firebase. Sirve para enseñarla o probarla
/// sin conexión:
///
/// `flutter run -t lib/dev/main_sin_conexion.dart`
void main() => runApp(const AplicacionAva());
