import 'package:flutter_test/flutter_test.dart';

import 'package:ava/main.dart';

void main() 
{
    testWidgets('La pantalla de inicio muestra el título del proyecto',
                (WidgetTester tester) async 
        {
            await tester.pumpWidget(const AplicacionAva());
            expect(find.text('Proyecto AUTOVIDA'), findsOneWidget);
        }
    );
}