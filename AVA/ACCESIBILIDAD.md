# Accesibilidad y requisitos de la Iteración 1

Este documento resume las pautas de accesibilidad aplicadas en AVA y dónde
se cumple cada historia de usuario de la Iteración 1. Todo lo indicado está
comprobado con pruebas automáticas (`flutter test`).

## Pautas de referencia

| Referencia | Qué se ha aplicado |
|---|---|
| **WCAG 2.2 AA** (RNF-02) | Contraste de texto ≥ 7:1 (AAA) y de bordes ≥ 3:1; objetivos táctiles ≥ 64 px (2.5.8 pide 24 px); foco visible con borde grueso (2.4.7); sin gestos de arrastre (2.5.7); navegación siempre en el mismo sitio (3.2.3); el color nunca es la única pista (1.4.1); avisos anunciados a lectores de pantalla (4.1.3). |
| **W3C COGA** (accesibilidad cognitiva) | Una idea por pantalla, pocas opciones, iconos conocidos, ayuda siempre visible, confirmación antes de cambios, sin errores bruscos ni bloqueos. |
| **UNE 153101 EX** (lectura fácil, RNF-10) | Letra grande (≥ 20 px), interlineado amplio, frases cortas, fondos lisos. |
| **RNF-11** | Sin animaciones de transición ni sonidos bruscos. |
| **ARASAAC** (RNF-04, RNF-12) | Pictogramas en toda la interfaz del alumno y atribución de la licencia CC BY-NC-SA en la pantalla de inicio y en el panel del profesorado. |

## Decisiones de diseño para el alumnado

- **Todo a la vista, sin desplazamiento ni páginas.** Ninguna pantalla del
  alumno tiene scroll ni botones de pasar página: todos los elementos se
  reparten el espacio y, si hay muchos, se hacen más pequeños
  (`CuadriculaAjustada`). Los botones «Anterior» y «Siguiente» solo
  aparecen en los pasos de una tarea, para verlos de uno en uno. Hay una
  prueba que lo comprueba en todo el recorrido, también con letra muy grande.
- **Color elegido visible.** El color que elige el alumno en su perfil tiñe
  el fondo de toda la app, manteniendo el contraste del texto por encima de
  7:1.
- **Voz.** «Escuchar» usa la voz del navegador o de la tableta; si el
  dispositivo no tiene ninguna instalada, lo dice en pantalla.
- **Colores pastel diferenciables.** Ocho familias de color repartidas por el
  círculo cromático (`core/constantes/paleta.dart`). El texto siempre va en
  tinta oscura sobre pastel. Cada clase, alumno, tipo de tarea y día de la
  semana tiene su color, siempre acompañado de pictograma y texto.
- **Estructura fija.** Arriba: pictograma, título y «Escuchar». Abajo (o
  arriba, según preferencias): «Atrás», «Inicio» y «Ayuda». Los huecos se
  mantienen aunque un botón no aparezca, para que nada cambie de sitio.
- **Ayuda permanente** (personas Álex y Diego): pantalla tranquila que pide
  levantar la mano, con pictograma y voz.
- **Ahora / después** (HU-10): formato habitual en agendas visuales, con la
  parte del día en pictograma para quien no lee el reloj (persona Álex).
- **Pasos de uno en uno** en el detalle de la tarea (persona Diego).
- **Filtro antitemblor** (persona Carlos): ignora pulsaciones repetidas.
- **Voz** (personas Álex y Samuel): lectura en voz alta de botones y
  pantallas, a ritmo pausado.
- **Pulsador o teclado** (persona Samuel): todos los botones se activan con
  Intro o Espacio y muestran el foco.
- **Tipografía Atkinson Hyperlegible**, diseñada para baja visión e incluida
  en la app para funcionar sin conexión.
- **Errores sin castigo**: avisos en tono tranquilo («No es correcto. Prueba
  otra vez.»), sin rojo intenso ni pitidos.

## Preferencias configurables (HU-14, RF-08, RNF-05)

Tamaño de letra (normal, grande, muy grande), letra clara, alto contraste,
modo oscuro, color principal, ver pictogramas, ver palabras, leer en voz
alta, evitar toques dobles, posición de los botones y vistas de agenda
habilitadas. El alumno solo las cambia si su tutor se lo permite.

## Cobertura de las historias de usuario

| HU | Dónde | Prueba |
|---|---|---|
| HU-01 Crear y editar cuentas | Panel › Cuentas | `gestion_test.dart` |
| HU-02 Roles | `Permisos` y rutas protegidas por rol | `gestion_test.dart`, `widget_test.dart` |
| HU-03 Tareas personales | Ficha › Tareas (tutor) y «Crear tarea» (alumno, si está autorizado) | `tareas_test.dart` |
| HU-04 Horario | Formulario de tarea (fin posterior al inicio) | `tareas_test.dart` |
| HU-05 Información accesible | Pictograma de ARASAAC o foto propia y descripción | `tareas_test.dart` |
| HU-06 Instrucciones | Pasos ordenados, reordenables sin arrastrar | `tareas_test.dart` |
| HU-07 Encargos del centro | Panel › Encargos (a un aula o a varios alumnos) | `tareas_test.dart` |
| HU-08 Login accesible | Pictogramas, número o contraseña | `login_estudiante_controlador_test.dart`, `widget_test.dart` |
| HU-09 Agenda diaria o semanal | Semana (7 días) y Hoy | `calculos_agenda_test.dart`, `widget_test.dart` |
| HU-10 Siguiente tarea | «Ahora y después» y etiquetas AHORA/DESPUÉS | `calculos_agenda_test.dart` |
| HU-11 Inicio y fin | Detalle › Empezar / He terminado, con confirmación y refuerzo | `tareas_test.dart` |
| HU-14 Preferencias | Mi perfil (alumno) y Ficha › Accesibilidad (tutor) | `perfil_test.dart`, `widget_test.dart` |
| HU-15 Aulas y tutores | Panel › Aulas | `perfil_test.dart` |
| HU-16 Solo alumnos asignados | Lista y ficha filtradas; acceso denegado con aviso | `perfil_test.dart`, `tareas_test.dart`, `widget_test.dart` |
| HU-17 Login de tutores y recuperación | Profesorado › Entrar / ¿Has olvidado la contraseña? | `gestion_test.dart`, `widget_test.dart` |
| HU-18 Perfil del estudiante | Ficha › Perfil (foto, intereses, necesidades, calma, progreso) | `perfil_test.dart` |

## Pendiente para próximas iteraciones

- Conectar Firebase (los repositorios simulados ya usan el formato de
  Firestore con `toMap`/`fromMap`).
- Probar con TalkBack, VoiceOver y Accessibility Scanner en tabletas reales.
- Validar los textos con personas usuarias (lectura fácil).
