import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('sign in validates fields and shows a welcome state', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.ensureVisible(find.text('Iniciar sesión'));
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(
      find.text('Porfavor, ingresa tu correo electrónico'),
      findsOneWidget,
    );
    expect(find.text('Porfavor, ingresa tu contraseña'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'alex@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.ensureVisible(find.text('Iniciar sesión'));
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('You’re signed in!'), findsOneWidget);
    expect(find.text('Welcome, alex@example.com'), findsOneWidget);

    await tester.tap(find.text('Salir de la sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Hola de nuevo!'), findsOneWidget);
  });
}
