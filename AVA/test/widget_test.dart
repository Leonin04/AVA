import 'package:ava/app/aplicacion_ava.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Recorrido completo con los datos simulados: inicio → clase → login con
/// pictogramas → menú → agenda diaria.
void main() {
  testWidgets('Un estudiante entra con pictogramas y abre su agenda del día',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AplicacionAva());
    await tester.pumpAndSettle();

    expect(find.text('AVA'), findsOneWidget);
    expect(find.text('1ºA'), findsOneWidget);

    await tester.tap(find.text('1ºA'));
    await tester.pumpAndSettle();
    expect(find.text('Diego'), findsOneWidget);

    await tester.tap(find.text('Diego'));
    await tester.pumpAndSettle();

    // Diego tiene una clave de 4 pictogramas: sol, luna, estrella, corazón.
    for (final pictograma in ['Sol', 'Luna', 'Estrella', 'Corazón']) {
      await tester.tap(find.text(pictograma));
      await tester.pumpAndSettle();
    }
    expect(find.text('Hola, Diego'), findsOneWidget);

    await tester.tap(find.text('Agenda'));
    await tester.pumpAndSettle();
    expect(find.text('Semana'), findsOneWidget);
    expect(find.text('Siguiente tarea'), findsOneWidget);

    await tester.tap(find.text('Día'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.visibility), findsWidgets);
  });

  testWidgets('Una clave de pictogramas incorrecta no deja entrar',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AplicacionAva());
    await tester.pumpAndSettle();
    await tester.tap(find.text('1ºA'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lucía'));
    await tester.pumpAndSettle();

    for (final pictograma in ['Coche', 'Coche', 'Coche']) {
      await tester.tap(find.text(pictograma));
      await tester.pumpAndSettle();
    }
    expect(find.text('No es correcto. Inténtalo otra vez.'), findsOneWidget);
    expect(find.text('Hola, Lucía'), findsNothing);
  });
}
