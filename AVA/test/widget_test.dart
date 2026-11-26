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

    testWidgets('T-81: «Escuchar» en Hoy lee las tareas del día', (
      tester,
    ) async {
      final voz = await arrancarApp(tester) as ServicioVozSilencioso;
      await entrarComoDiego(tester);
      await pulsar(tester, 'Mi agenda');
      await pulsar(tester, 'Hoy');

      await pulsar(tester, 'Escuchar');
      expect(voz.dichos.last, contains('Tus tareas son'));
      expect(voz.dichos.last, contains('Asamblea a las 9:00'));
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

    testWidgets('cambiar una preferencia cambia toda la app (HU-15)', (
      tester,
    ) async {
      await arrancarApp(tester);
      await entrarComoDiego(tester);
      await pulsar(tester, 'Mi perfil');

      final antes = Theme.of(tester.element(find.text('Mi perfil'))).brightness;
      await pulsarEnPaginas(tester, 'Modo oscuro');
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
      await pulsarEnPaginas(tester, 'Color rosa');

      expect(
        fondo(),
        TemaApp.construir(color: ColorPastel.rosa).scaffoldBackgroundColor,
      );
      await pulsarEnPaginas(tester, 'Color menta');
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

      await pulsarEnPaginas(tester, 'Botón Escuchar');
      expect(find.text('Escuchar'), findsNothing);

      // El botón ignora un segundo toque seguido (evitar dobles toques).
      await tester.runAsync(() => Future.delayed(Dimensiones.esperaDobleToque));
      await pulsarEnPaginas(tester, 'Botón Escuchar');
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

    testWidgets('la semana enseña los 7 días y 3 tareas de cada uno', (
      tester,
    ) async {
      await arrancarApp(tester);
      await entrarComoDiego(tester);
      await pulsar(tester, 'Mi agenda');
      await pulsar(tester, 'Semana');

      for (final dia in [
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado',
        'Domingo',
      ]) {
        expect(find.text(dia), findsOneWidget, reason: dia);
      }
      // Los días de diario tienen 5 tareas: se ven siempre las 3 primeras
      // (asamblea, taller y recreo) y las últimas quedan para «Ver más».
      expect(find.text('Asamblea'), findsNWidgets(5));
      expect(find.text('Recreo'), findsNWidgets(5));
      expect(find.text('Llevar fotocopias'), findsNothing);
      expect(find.text('Comida'), findsNothing);

      // «Ver más» del lunes avanza hasta sus últimas tareas y entonces
      // pasa a «Volver», que regresa a las primeras.
      while (find.text('Volver').evaluate().isEmpty) {
        await tester.tap(find.text('Ver más').first);
        await tester.pumpAndSettle();
        await tester.runAsync(
          () => Future.delayed(Dimensiones.esperaDobleToque),
        );
      }
      expect(find.text('Comida'), findsOneWidget);
      expect(find.text('Asamblea'), findsNWidgets(4));

      await pulsar(tester, 'Volver');
      expect(find.text('Asamblea'), findsNWidgets(5));
    });

    testWidgets('el perfil reparte sus opciones en páginas legibles', (
      tester,
    ) async {
      await arrancarApp(tester);
      await entrarComoDiego(tester);
      await pulsar(tester, 'Mi perfil');

      expect(find.text('1 de 2'), findsOneWidget);
      expect(find.text('Anterior'), findsNothing);
      await pulsarEnPaginas(tester, 'Botones arriba');
      expect(find.text('2 de 2'), findsOneWidget);
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

  group('Profesorado (HU-03, HU-17, HU-18)', () {
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

    testWidgets('el tutor tiene seguimiento y comedor (iteración 2)', (
      tester,
    ) async {
      await arrancarApp(tester);
      await entrarComoGestion(tester, 'javier', 'tutor1234');
      expect(find.text('Seguimiento de hoy'), findsOneWidget);
      expect(find.text('Comedor'), findsOneWidget);

      await pulsar(tester, 'Seguimiento de hoy');
      expect(find.text('Diego'), findsOneWidget);
      final historial = find.text('Historial').first;
      await tester.ensureVisible(historial);
      await tester.tap(historial);
      await tester.pumpAndSettle();
      expect(find.textContaining('Historial de'), findsOneWidget);
    });
  });

  group('Comedor del estudiante (HU-23)', () {
    testWidgets('marca un día desde el menú, sin desplazarse', (tester) async {
      await arrancarApp(tester);
      await entrarComoDiego(tester);
      // «Salir» va en la barra de abajo, como «Ayuda», no entre las opciones.
      expect(find.text('Salir'), findsOneWidget);
      expect(find.text('Ayuda'), findsOneWidget);
      await pulsar(tester, 'Comedor');

      expect(find.byType(Scrollable), findsNothing);
      expect(find.text('Lunes'), findsOneWidget);
      expect(find.text('Viernes'), findsOneWidget);
      expect(find.text('Sábado'), findsNothing);
      expect(find.text('Toca para elegir'), findsNWidgets(5));

      await pulsar(tester, 'Lunes');
      expect(find.text('Voy al comedor'), findsOneWidget);
      // Nunca se ven dietas.
      expect(find.textContaining('Dieta'), findsNothing);
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
