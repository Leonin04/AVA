# Conexión de la interfaz con Firebase

La interfaz (pantallas del alumno y del profesorado) usa la base de datos de
`database/README.md` **sin cambiar su esquema ni sus reglas**. Esta nota es
para quien mantiene la base de datos.

## Cómo está conectado

Las pantallas solo conocen unos repositorios. En `lib/main.dart` se arranca
Firebase y `AplicacionAva(conFirebase: true)` usa las versiones de Firebase,
que trabajan con los servicios `BaseDatos`, `Autenticacion` y
`Almacenamiento`:

| Repositorio | Fichero |
|---|---|
| Aulas | `features/aulas/dominio/repositorio_aulas_firebase.dart` |
| Estudiantes y preferencias | `features/perfil/dominio/repositorio_estudiantes_firebase.dart` |
| Inicio de sesión | `features/autenticacion/dominio/repositorio_autenticacion_firebase.dart` |
| Cuentas | `features/autenticacion/dominio/repositorio_cuentas_firebase.dart` |
| Tareas, pasos y registros | `features/tareas/dominio/repositorio_tareas_firebase.dart` |

La conversión entre los documentos y los modelos de la interfaz está en
`features/perfil/dominio/conversion_firestore.dart`.

Las pruebas automáticas (`flutter test`) usan versiones simuladas en memoria
de los mismos repositorios, así que no tocan la base de datos real.

## Campos nuevos (opcionales)

Las reglas los permiten tal como están. Si un documento no los tiene, la
interfaz usa un valor por defecto.

| Documento | Campo | Para qué |
|---|---|---|
| `aulas/{id}` | `color`, `pictograma` | Reconocer cada clase en la tableta |
| `estudiantes/{id}` | `color` | Color de su tarjeta |
| `estudiantes/{id}` | `observaciones` | Notas de progreso del tutor (HU-19) |
| `estudiantes/{id}` | `puedeGestionarTareas` | Si puede crear y borrar sus tareas (HU-04) |
| `estudiantes/{id}.preferencias.ava` | `color`, `modoOscuro`, `botonEscuchar`, `filtroAntitemblor`, `vistasAgenda` | Preferencias de accesibilidad que no tenía el esquema (HU-15) |
| `tareas/{id}` | `categoria` | Tipo de tarea con su color: clase, personal, ocio, casa o encargo |

`BaseDatos.actualizarPreferencias` solo cambia `comunicacion` y `visual`, así
que no borra `preferencias.ava`.

## Iteración 2

**Hay que publicar las reglas nuevas** (`firestore.rules`) con
`firebase deploy --only firestore:rules`. Sin ellas, el tutor no puede
confirmar tareas ni nombrar al encargado, y el comedor y las dietas dan
`permission-denied`. Conviene probarlas antes con el emulador de Firebase.

| Documento | Campo o colección | Para qué |
|---|---|---|
| `usuarios/{uid}` | `estado` (`activa` / `desactivada`), `desactivadaEn` | Cuentas desactivadas (HU-13), como pide el entregable |
| `estudiantes/{id}` y `acceso/{id}` | `estado`, `desactivadaEn` | Lo mismo para los alumnos, que no están en `usuarios`; la tableta no muestra a los desactivados |
| `tareas/{id}` | `diasSemana` (ya existía) | Ahora se puede elegir y cambiar al editar (HU-14) |
| `tareas/{id}` | `temporizador`, `avisoMinutos` | Temporizador (HU-22) y antelación del aviso previo (HU-28) |
| `tareas/{id}/pasos/{id}` | `imagenUrl` (ya existía) | Ahora se usa: pictograma o foto de cada paso (HU-20) |
| `estudiantes/{id}/registros/{id}` | `estado`, `pasoActual` | Estado de cada día y paso por el que va (HU-21, HU-26) |
| `estudiantes/{id}/registros/{id}/historial/{id}` | `estadoAnterior`, `estadoNuevo`, `fechaHora`, `actorUid`, `origen` | Historial de cambios, solo se añaden (HU-27), como pide el entregable |
| `aulas/{id}` | `encargadoComedor` | Alumno que pasa la lista del comedor (HU-23) |
| `comedor/{aulaId}_{yyyy-MM-dd}` | `aulaId`, `fecha`, `asistencia.{estudianteId}` | Quién come cada día (HU-23). **Colección nueva** |
| `dietas/{estudianteId}` y `dietas/{id}/cambios/{id}` | `tipo`, `alergias`, `indicaciones` y cada cambio | Dietas protegidas (HU-24) y su registro (T-118). **Colección nueva** |

El estado de los registros sigue usando los valores que ya había
(`pendiente`, `iniciada`, `terminada`), no los del entregable (`pendiente`,
`en curso`, `completada`), para no romper los datos guardados.

## Correspondencias

- **Preferencias:** `comunicacion.pictogramas/texto/voz` ↔ ver dibujos,
  ver palabras, leer en voz alta; `visual.colores` ↔ alto contraste o modo
  oscuro; `visual.tamanoLetra` ↔ letra normal (22), grande (27,5) o muy
  grande (33); `visual.tipografia` ↔ letra clara (Atkinson Hyperlegible);
  `visual.posicionMenus` ↔ botones arriba o abajo.
- **Tareas:** la agenda trabaja con la tarea de cada día. Su identificador
  es `{idTarea}|{yyyy-MM-dd}` y su estado sale de `registros`.
- **Clave de pictogramas:** las mismas seis palabras que
  `Autenticacion.pictogramasClave`. Como la base de datos no guarda cuántos
  pictogramas tiene la clave, el alumno pulsa «Entrar» al terminar.

## Limitaciones (las mismas de `database/README.md`)

- La clave de un alumno no se puede cambiar desde la app: la ficha lo
  explica en pantalla.
- La contraseña de tutores y administradores la cambia cada persona con
  «¿Has olvidado la contraseña?».
