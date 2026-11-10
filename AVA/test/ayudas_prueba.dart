import 'package:ava/app/aplicacion_ava.dart';
import 'package:ava/app/datos_iniciales.dart';
import 'package:ava/core/servicios/almacen_simulado.dart';
import 'package:ava/core/servicios/servicio_voz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Almacén con los mismos datos de prueba que la app.
AlmacenSimulado almacenDePrueba() {
  final almacen = AlmacenSimulado();
  cargarDatosIniciales(almacen);
  return almacen;
}

/// Arranca la app en una tableta horizontal de 1280 × 800.
Future<ServicioVoz> arrancarApp(
  WidgetTester tester, {
  AlmacenSimulado? almacen,
  ServicioVoz? conVoz,
  Size tamano = const Size(1280, 800),
}) async {
  tester.view.physicalSize = tamano;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final voz = conVoz ?? ServicioVozSilencioso();
  await tester.pumpWidget(
    AplicacionAva(almacen: almacen ?? almacenDePrueba(), voz: voz),
  );
  await tester.pumpAndSettle();
  return voz;
}

/// Voz de un dispositivo que no tiene ninguna voz instalada.
class VozNoDisponible implements ServicioVoz {
  @override
  Future<bool> decir(String texto) async => false;

  @override
  Future<void> parar() async {}
}

/// Pulsa el texto indicado y espera a que la pantalla se estabilice.
Future<void> pulsar(WidgetTester tester, String texto) async {
  await tester.tap(find.text(texto).first);
  await tester.pumpAndSettle();
}

/// Entra como Diego (1ºA, clave de 4 pictogramas).
Future<void> entrarComoDiego(WidgetTester tester) async {
  await pulsar(tester, '1ºA');
  await pulsar(tester, 'Diego');
  for (final pictograma in ['Sol', 'Casa', 'Perro', 'Coche']) {
    await pulsar(tester, pictograma);
  }
}

/// Entra en el panel de gestión con las credenciales dadas.
Future<void> entrarComoGestion(
  WidgetTester tester,
  String usuario,
  String contrasena,
) async {
  await pulsar(tester, 'Profesorado');
  await tester.enterText(find.byType(TextFormField).at(0), usuario);
  await tester.enterText(find.byType(TextFormField).at(1), contrasena);
  await pulsar(tester, 'Entrar');
}
