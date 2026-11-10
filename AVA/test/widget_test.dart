import 'package:ava/core/constantes/dimensiones.dart';
import 'package:ava/core/constantes/paleta.dart';
import 'package:ava/core/servicios/servicio_voz.dart';
import 'package:ava/core/tema/tema_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas_prueba.dart';

/// Pruebas de la app completa con los datos de prueba, en una tableta
/// horizontal de 1280 × 800.
void main() {
  group('Flujo del estudiante', () {
    testWidgets('Diego entra con pictogramas y abre su agenda del día', (
      tester,
    ) async {
      await arrancarApp(tester);
      expect(find.text('AVA'), findsOneWidget);
      expect(find.text('1ºA'), findsOneWidget);

      await entrarComoDiego(tester);
      expect(find.text('Hola, Diego'), findsOneWidget);

      await pulsar(tester, 'Mi agenda');
      expect(find.text('Semana'), findsOneWidget);
      expect(find.text('Ahora y después'), findsOneWidget);

      await pulsar(tester, 'Hoy');
      expect(find.text('Ver'), findsWidgets);
    });

    testWidgets('una clave incorrecta muestra un aviso y no deja entrar', (
      tester,
    ) async {
      await arrancarApp(tester);
      await pulsar(tester, '1ºA');
      await pulsar(tester, 'Lucía');

      for (final pictograma in ['Coche', 'Perro', 'Flor']) {
        await pulsar(tester, pictograma);
      }
      expect(find.text('No es correcto. Prueba otra vez.'), findsOneWidget);
      expect(find.text('Hola, Lucía'), findsOneWidget); // Sigue en el login.
      expect(find.text('Mi agenda'), findsNothing);
    });

    testWidgets('Marta entra con su número', (tester) async {
      await arrancarApp(tester);
      await pulsar(tester, '1ºA');
      await pulsar(tester, 'Marta');
      for (final cifra in [1, 2, 3, 4]) {
        await tester.tap(find.bySemanticsLabel('$cifra'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Mi agenda'), findsOneWidget);
    });

    testWidgets('el botón Ayuda está en todas las pantallas y la lee en voz', (
      tester,
    ) async {
      final voz = await arrancarApp(tester) as ServicioVozSilencioso;
      // Álex tiene activado «Leer en voz alta».
      await entrarConPictogramas(tester, 'Álex', ['Sol', 'Casa', 'Perro']);

      await pulsar(tester, 'Ayuda');
      expect(find.textContaining('Levanta la mano'), findsOneWidget);
      expect(voz.dichos.last, contains('Levanta la mano'));
      await pulsar(tester, 'Volver');

      await pulsar(tester, 'Escuchar');
      expect(voz.dichos.last, contains('Hola, Álex'));
    });

    testWidgets('sin voz activada, Ayuda no habla pero «Escuchar» sí', (
      tester,
    ) async {
      final voz = await arrancarApp(tester) as ServicioVozSilencioso;
      await entrarComoDiego(tester);

      await pulsar(tester, 'Ayuda');
      expect(voz.dichos, isEmpty);
      await pulsar(tester, 'Volver');

      await pulsar(tester, 'Escuchar');
      expect(voz.dichos.last, contains('Hola, Diego'));
    });

    testWidgets('cambiar una preferencia cambia toda la app (HU-14)', (
      tester,
    ) async {
      await arrancarApp(tester);
      await entrarComoDiego(tester);
      await pulsar(tester, 'Mi perfil');

      final antes = Theme.of(tester.element(find.text('Mi perfil'))).brightness;
      await pulsar(tester, 'Modo oscuro');
      final despues = Theme.of(
        tester.element(find.text('Mi perfil')),
      ).brightness;

      expect(antes, Brightness.light);
      expect(despues, Brightness.dark);
    });

    testWidgets('el color elegido en el perfil cambia el fondo de la app', (
      tester,
    ) async {
      await arrancarApp(tester);
      await entrarComoDiego(tester);
      await pulsar(tester, 'Mi perfil');

      Color fondo() => Theme.of(
        tester.element(find.text('Mi perfil')),
      ).scaffoldBackgroundColor;
      await pulsar(tester, 'Color rosa');

      expect(
        fondo(),
        TemaApp.construir(color: ColorPastel.rosa).scaffoldBackgroundColor,
      );
      await pulsar(tester, 'Color menta');
      expect(
        fondo(),
        TemaApp.construir(color: ColorPastel.menta).scaffoldBackgroundColor,
      );
    });

    testWidgets('«Escuchar» avisa si el dispositivo no tiene voz', (
      tester,
    ) async {
      await arrancarApp(tester, conVoz: VozNoDisponible());
      await pulsar(tester, 'Escuchar');
      expect(find.textContaining('no tiene voz instalada'), findsOneWidget);
    });

    testWidgets('el botón «Escuchar» se puede quitar y volver a poner', (
      tester,
    ) async {
      await arrancarApp(tester);
      await entrarComoDiego(tester);
      await pulsar(tester, 'Mi perfil');
      expect(find.text('Escuchar'), findsOneWidget);

      await pulsar(tester, 'Botón Escuchar');
      expect(find.text('Escuchar'), findsNothing);

      // El botón ignora un segundo toque seguido (evitar dobles toques).
      await tester.runAsync(() => Future.delayed(Dimensiones.esperaDobleToque));
      await pulsar(tester, 'Botón Escuchar');
      expect(find.text('Escuchar'), findsOneWidget);
    });

    testWidgets('sin permiso del tutor el perfil no se puede cambiar', (
      tester,
    ) async {
      await arrancarApp(tester);
      await entrarConPictogramas(tester, 'Lucía', ['Sol', 'Casa', 'Perro']);
      await pulsar(tester, 'Mi perfil');

      expect(
        find.text('Tu profesor elige cómo ves la agenda.'),
        findsOneWidget,
      );
      expect(find.text('Modo oscuro'), findsNothing);
    });
  });

  group('Sin desplazamiento (pantallas del estudiante)', () {
    testWidgets('ninguna pantalla del recorrido necesita scroll', (
      tester,
    ) async {
      await arrancarApp(tester);
      expect(find.byType(Scrollable), findsNothing, reason: 'Inicio');

      await pulsar(tester, '1ºA');
      expect(find.byType(Scrollable), findsNothing, reason: 'Clase');

      await pulsar(tester, 'Diego');
      expect(find.byType(Scrollable), findsNothing, reason: 'Login');

      for (final pictograma in ['Sol', 'Casa', 'Perro', 'Coche']) {
        await pulsar(tester, pictograma);
      }
      expect(find.byType(Scrollable), findsNothing, reason: 'Menú');

      await pulsar(tester, 'Mi perfil');
      expect(find.byType(Scrollable), findsNothing, reason: 'Perfil');
      await pulsar(tester, 'Atrás');

      await pulsar(tester, 'Mi agenda');
      expect(find.byType(Scrollable), findsNothing, reason: 'Agenda');

      await pulsar(tester, 'Semana');
      expect(find.byType(Scrollable), findsNothing, reason: 'Semana');
      await pulsar(tester, 'Atrás');

      await pulsar(tester, 'Ahora y después');
      expect(find.byType(Scrollable), findsNothing, reason: 'Ahora/después');
      await pulsar(tester, 'Atrás');

      await pulsar(tester, 'Hoy');
      expect(find.byType(Scrollable), findsNothing, reason: 'Día');

      await tester.tap(find.text('Ver').first);
      await tester.pumpAndSettle();
      expect(find.byType(Scrollable), findsNothing, reason: 'Detalle');
      expect(find.text('Empezar'), findsOneWidget);
    });

    testWidgets('con la letra muy grande todo sigue cabiendo (Samuel)', (
      tester,
    ) async {
      await arrancarApp(tester);
      await entrarConPictogramas(tester, 'Samuel', [
        'Sol',
        'Casa',
        'Perro',
      ], aula: '2ºB');
      // Cualquier desbordamiento haría fallar la prueba.
      await pulsar(tester, 'Mi agenda');
      await pulsar(tester, 'Semana');
      await pulsar(tester, 'Atrás');
      await pulsar(tester, 'Hoy');
      expect(find.byType(Scrollable), findsNothing);
    });
  });

  group('Pautas de accesibilidad de Flutter', () {
    testWidgets('inicio, clase y menú cumplen tamaño táctil y etiquetas', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await arrancarApp(tester);

      Future<void> comprobar() async {
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      }

      await comprobar();
      await pulsar(tester, '1ºA');
      await comprobar();
      await pulsar(tester, 'Diego');
      await comprobar();
      for (final pictograma in ['Sol', 'Casa', 'Perro', 'Coche']) {
        await pulsar(tester, pictograma);
      }
      await comprobar();
      await pulsar(tester, 'Mi agenda');
      await pulsar(tester, 'Hoy');
      await comprobar();
      semantica.dispose();
    });
  });

  group('Profesorado (HU-02, HU-16, HU-17)', () {
    testWidgets('un tutor solo ve sus funciones y sus alumnos', (tester) async {
      await arrancarApp(tester);
      await entrarComoGestion(tester, 'javier', 'tutor1234');

      expect(find.text('Hola, Javier Morales'), findsOneWidget);
      expect(find.text('Mis alumnos'), findsOneWidget);
      expect(find.text('Encargos del colegio'), findsOneWidget);
      expect(find.text('Cuentas'), findsNothing);
      expect(find.text('Aulas'), findsNothing);

      await pulsar(tester, 'Mis alumnos');
      expect(find.text('Diego'), findsOneWidget);
      expect(find.text('Iván'), findsNothing); // De 2ºA, de otra tutora.
    });

    testWidgets('la administración ve cuentas y aulas', (tester) async {
      await arrancarApp(tester);
      await entrarComoGestion(tester, 'admin', 'admin1234');

      expect(find.text('Cuentas'), findsOneWidget);
      expect(find.text('Aulas'), findsOneWidget);
    });

    testWidgets('credenciales incorrectas muestran un mensaje claro', (
      tester,
    ) async {
      await arrancarApp(tester);
      await entrarComoGestion(tester, 'javier', 'mal');
      expect(
        find.text('El correo o la contraseña no son correctos.'),
        findsOneWidget,
      );
    });
  });
}
