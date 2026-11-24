# Iteración 2: implementación y verificación

Implementación de las historias y tareas del entregable 2 (12/11/2026 –
03/12/2026). Cada fila indica dónde está el cambio y la prueba automática que
lo comprueba (`flutter test`). Sirve para rellenar los apartados 4
(Implementación) y 5 (Verificación y pruebas) del entregable.

## Tareas retomadas de la iteración 1

| Tarea | Qué fallaba | Cambio | Evidencia |
|---|---|---|---|
| T-60 Tamaño de letra | La letra se veía cambiada aunque no se hubiera guardado (al volver a entrar volvía la anterior), y con letra grande todo se encogía | Si no se puede guardar, el cambio se deshace y se avisa (`preferencias_controlador.dart`); el perfil reparte las opciones en páginas legibles | `perfil_test.dart` › «T-60: tamaño de letra» |
| T-81 Voz con las tareas de hoy | «Escuchar» decía «No tienes tareas» aunque las hubiera: el texto se calculaba antes de cargar la agenda | Las vistas de la agenda se redibujan al cargar (`estado_agenda_mixin.dart`) | `widget_test.dart` › «T-81: Escuchar en Hoy lee las tareas del día» |

## Historias de la iteración 2

| HU | Cambio | Evidencia |
|---|---|---|
| HU-13 Desactivar cuenta (T-97 a T-99) | Panel › Cuentas › Desactivar / Reactivar, con confirmación. Guarda `estado` y `desactivadaEn` sin borrar nada; la cuenta no puede entrar y el alumno desaparece de la tableta. La administración no puede desactivarse a sí misma | `gestion_test.dart` › «HU-13» (4 pruebas) |
| HU-14 Días de repetición (T-100 a T-103) | Formulario de tarea › «Repetir cada semana». Las apariciones futuras cambian al editar; el historial no | `tareas_test.dart` › «HU-14» (4 pruebas) |
| HU-20 Una instrucción cada vez (T-104 a T-106) | Cada paso tiene su pictograma o foto. Mientras se hace la tarea se ve solo el paso actual («Paso 2 de 3») | `tareas_test.dart` › «HU-20 y HU-21» |
| HU-21 Confirmar el paso (T-107 a T-109) | «He terminado este paso» pide confirmación; si se cancela, se queda en el mismo paso; si se confirma, se guarda el paso y se avanza; el último termina la tarea | `tareas_test.dart` › «HU-20 y HU-21» (3 pruebas) |
| HU-22 Temporizador (T-110 a T-112) | Interruptor en el formulario. Barra que se vacía y «Quedan 15 minutos» solo mientras se hace la tarea | `tareas_test.dart` › «HU-22» (2 pruebas) |
| HU-23 Asistencia al comedor (T-113 a T-115) | Botón «Comedor» en el menú del alumno (boceto de la figura 2): marca los días que va (figura 3). El encargado pasa la lista de su aula. El tutor la revisa y corrige y nombra al encargado | `comedor_test.dart` › «HU-23», `widget_test.dart` › «Comedor del estudiante» |
| HU-24 Dietas (T-116 a T-118) | Panel › Comedor › Dieta: tipo de menú, alergias e indicaciones, con su registro de cambios. Solo administración y tutores del centro | `comedor_test.dart` › «HU-24» (2 pruebas) |
| HU-25 Listado para cocina (T-119 a T-121) | Panel › Comedor › Listado para cocina: solo nombre y dieta de quien come; avisa de quién no ha respondido; se puede copiar. No hay comedor en fin de semana | `comedor_test.dart` › «HU-25» (2 pruebas) |
| HU-26 Estado y progreso (T-122 a T-124) | Panel › Seguimiento de hoy: progreso de cada alumno asignado. El tutor del centro puede marcar una tarea como terminada | `seguimiento_test.dart` › «HU-26» (3 pruebas) |
| HU-27 Historial (T-125 a T-127) | Cada cambio de estado se añade al historial (quién y cuándo). Seguimiento › Historial, por día o por semana | `seguimiento_test.dart` › «HU-27» |
| HU-28 Avisos previos (T-128 a T-131) | Antelación en el formulario (5, 10, 15 o 30 min). Banda arriba de la pantalla del alumno, una vez por aviso, leída en voz si la tiene activada | `seguimiento_test.dart` › «HU-28» (2 pruebas) |
| HU-29 Avisar al tutor (T-132 a T-135) | Seguimiento de hoy muestra las tareas sin empezar o sin terminar pasados 10 minutos, con alumno y tarea, sin duplicados; se revisa cada minuto | `seguimiento_test.dart` › «HU-29» (2 pruebas) |

## Arreglos del código de `main`

| Problema | Arreglo |
|---|---|
| `logo_AVA.jpg:Zone.Identifier`: «:» no es válido en Windows y **nadie con Windows podía descargar `main`** | Quitado (con la carpeta `build/`, 200 MB generados, y las copias del logo y el sol en la raíz) |
| El logo nuevo se anunciaba dos veces al lector de pantalla | Una sola etiqueta |
| Al alumno le salían errores técnicos («Error al guardar: FirebaseException…») | Mensajes claros y tranquilos |
| `catch (_)` en las tareas: si fallaba la lectura al editar, se creaba una tarea duplicada | Se sabe si es nueva por su identificador, sin tragarse errores |
| El pictograma 2798 de ARASAAC se cambiaba por la imagen propia del sol en cualquier tarea o aula | La imagen propia solo se usa en la clave de acceso |
| La barra de progreso del seguimiento daba al lector de pantalla un valor no numérico | Corregido (lo detectó una prueba) |

## Incongruencias del entregable 2

1. **Comedor: boceto y historias no coinciden.** En la figura 3 cada alumno marca
   sus días (lunes a viernes); HU-23 y T-113 dicen que un *estudiante encargado*
   registra a toda el aula en una fecha. Se han hecho las dos cosas, guardando
   en el mismo registro.
2. **El modelo de datos no tiene dónde guardar el comedor.** El apartado 3.2 dice
   que no se crean colecciones nuevas, pero ni la asistencia ni las dietas
   caben en las existentes. Se han creado `comedor` y `dietas`.
3. **El estado de cuenta solo se prevé en `usuarios`**, pero los estudiantes
   (que también se pueden desactivar) están en `estudiantes`. Se ha añadido
   también allí y en `acceso`.
4. **Valores del estado del registro.** El entregable pide `pendiente / en curso
   / completada`; la base de datos ya usa `pendiente / iniciada / terminada`.
   Se mantienen los existentes para no romper datos.
5. **«Cocina autorizada» y «encargado del comedor» no son roles** del modelo
   (solo admin, tutor y estudiante). El encargado se guarda en el aula
   (`encargadoComedor`); el listado lo genera el tutor y se entrega a cocina.
6. **T-130 «avisos aunque la aplicación esté cerrada»** no se puede cumplir con
   la app web: hace falta un servidor (Cloud Functions + mensajería, que
   requiere el plan de pago de Firebase) o notificaciones locales en Android.
   Los avisos funcionan con la app abierta. Lo mismo para avisar al tutor
   (HU-29): se le muestran al abrir el seguimiento.
7. **Desactivar en Firebase Authentication** también necesita un servidor. La
   app y las reglas bloquean el acceso de las cuentas desactivadas.
8. **«Generar el listado a partir de la asistencia revisada»**: no se dice qué
   pasa si el tutor no la ha revisado. El listado usa la asistencia registrada
   y avisa de cuántos faltan por responder.
9. **El tutor familiar en la matriz de permisos** solo consulta el estado y el
   historial; no puede confirmar tareas ni ver dietas. Así se ha aplicado.

## Pendiente

- Publicar `firestore.rules` y probarlas con el emulador (no se ha podido
  desde aquí: no hay Firebase CLI).
- Probar el inicio de sesión, el comedor y las dietas contra la base de datos
  real con las cuentas de prueba.
- Notificaciones con la app cerrada (punto 6).
