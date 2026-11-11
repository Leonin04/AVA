# Base de datos de AVA (iteración 1)

La app guarda sus datos en **Firebase** (Google), proyecto **`proyecto-ava-54b58`**, plan Blaze:
- **Authentication**: cuentas (admin, tutores, estudiantes) y la sesión anónima de la tableta.
- **Cloud Firestore**: todos los datos (perfiles, aulas, tareas, registros…), en Europa.
- **Cloud Storage**: fotos de estudiantes e imágenes de tareas.

Cubre las historias HU-01 a HU-12 y HU-15 a HU-19.

---

## 1. Qué está montado

| Qué | Estado |
|---|---|
| Authentication: correo/contraseña y **anónimo** | ✅ |
| Firestore (Europa), reglas e índices | ✅ |
| Cloud Storage y sus reglas | ✅ |
| Cuenta de administrador | ✅ |
| Datos de prueba (tutores, aulas, alumnos, tareas) | ✅ Se cargan con un botón (ver punto 5) |

> **Firestore no tiene tablas como SQL.** Cada colección aparece la primera vez que se guarda
> algo en ella. El "esquema" lo marcan nuestros **modelos en Dart**: la app siempre guarda los
> datos con esos campos.

### Cuentas para probar

| Rol | Usuario | Contraseña |
|---|---|---|
| Administrador | `admin.ava@gmail.com` | Mensaje fijado del grupo de WhatsApp |
| Tutora del centro | `tutora.ava@ava-pruebas.test` | `AVAtutor` |
| Familiar | `familia.ava@ava-pruebas.test` | `AVAfamilia` |
| Alumno Pablo (1º A) | PIN | `1234` |
| Alumna Marta (1º A) | pictogramas | sol → perro → flor |
| Alumna Lucía (1º B) | contraseña | `lucia123` |
| Alumno Javier (1º B) | PIN | `4321` |

(Las de prueba son inventadas; la del admin no se escribe aquí porque da acceso a todo.)

---

## 2. Qué tengo que hacer para programar mi parte

```bash
git pull
cd AVA
flutter pub get
flutter run -d chrome      # o en el móvil / emulador Android
```

La conexión con Firebase ya va en el repositorio. **No hay que tocar nada de Firebase.**

La app completa ya usa estos servicios: para probar, entrad desde la pantalla de inicio con
las cuentas del punto 1 (botón «Profesorado» para tutores y administración).

### Las 5 reglas de oro

1. **Usad siempre los servicios** (`BaseDatos`, `Autenticacion`, `Almacenamiento`). Nunca `FirebaseFirestore.instance` ni `FirebaseAuth.instance` directamente en una pantalla.
2. **Un tutor carga a sus estudiantes con `estudiantesDeTutor(uid)`.** Si pide todos, Firebase lo rechaza a propósito (HU-17).
3. **Los nombres de los campos no se cambian** sin avisar: si uno guarda `nombre` y otro lee `name`, no funciona.
4. Si necesitáis un campo o una consulta nueva, **avisad a Daniel**: hay que tocar modelo, reglas e índices a la vez.
5. Si sale `permission-denied`, no es un fallo vuestro de código: es que **ese rol no puede hacer eso**. Revisad con qué cuenta habéis entrado.

---

## 3. Qué hace cada fichero

### Servicios (`lib/core/servicios/`) — lo que usáis desde las pantallas

| Fichero | Para qué |
|---|---|
| `base_datos.dart` | **Leer y guardar datos** (estudiantes, aulas, tareas, registros…) |
| `autenticacion.dart` | **Entrar, salir y crear cuentas** (admin, tutores y alumnos) |
| `almacenamiento.dart` | **Subir fotos** (perfil del alumno, imágenes de tareas) |
| `servicio_arasaac.dart` | **Buscar pictogramas** de ARASAAC |

### Modelos (`lib/features/*/dominio/`) — un tipo de dato cada uno

| Fichero | Qué representa | Colección |
|---|---|---|
| `autenticacion/dominio/usuario.dart` | Admin o tutor (rol, centro/familiar) | `usuarios` |
| `autenticacion/dominio/acceso.dart` | Ficha mínima del alumno para la pantalla "¿quién eres?" | `acceso` |
| `perfil/dominio/estudiante.dart` | Estudiante con su perfil completo | `estudiantes` |
| `perfil/dominio/preferencias.dart` | Preferencias de comunicación y visuales | dentro de `estudiantes` |
| `aulas/dominio/aula.dart` | Aula y su tutor responsable | `aulas` |
| `tareas/dominio/tarea.dart` | Tarea: nombre, pictograma, horario, días o fecha, a quién va | `tareas` |
| `tareas/dominio/paso.dart` | Un paso de una tarea | `tareas/{id}/pasos` |
| `agenda/dominio/registro.dart` | Cuándo empezó y terminó el alumno una tarea | `estudiantes/{id}/registros` |

### Configuración (en `AVA/`)

| Fichero | Qué es |
|---|---|
| `firestore.rules` | Reglas de seguridad de la base de datos |
| `storage.rules` | Reglas de seguridad de las fotos |
| `firestore.indexes.json` | Índices que necesitan las consultas |
| `firebase.json`, `.firebaserc` | Configuración del proyecto para la herramienta `firebase` |
| `lib/firebase_options.dart` | Conexión de la app con el proyecto (generado) |

### Desarrollo (`lib/dev/`) — no forma parte de la app

| Fichero | Qué es |
|---|---|
| `pantalla_desarrollo.dart` | Entrar como admin y cargar los datos de prueba |
| `datos_prueba.dart` | Crea los tutores, aulas, alumnos y tareas de prueba |

---

## 4. Qué método usar para cada historia

### Cuentas e inicio de sesión — `Autenticacion`

| HU / tarea | Método |
|---|---|
| HU-18 · Login de tutor/admin (T-14) | `entrarPersonal(correo, contraseña)` → devuelve `Sesion` |
| HU-18 · Error claro (T-15) | los métodos lanzan `ErrorAcceso` con el `mensaje` para enseñar |
| HU-18 · Recuperar contraseña (T-16) | `recuperarContrasena(correo)` |
| HU-18 · Cerrar sesión (T-17) | `salir()` |
| HU-18 · Redirigir según el rol (T-18) | `quienSoy()` → `sesion.esAdmin / esTutor / esEstudiante` |
| HU-09 · Tableta antes del login (T-19) | `prepararTableta()` (sesión anónima) y después `BaseDatos.aulas()` y `alumnosParaAcceso(aulaId)` |
| HU-09 · Login del alumno (T-21 a T-23) | `entrarEstudiante(acceso, entrada)` — `entrada` es el PIN (`'1234'`), la lista de pictogramas (`['sol','perro','flor']`) o la contraseña |
| HU-09 · Pictogramas de la clave (T-22) | `Autenticacion.pictogramasClave` (6 palabras; su pictograma está en `Pictogramas` de `core/constantes/pictogramas.dart`) |
| HU-01 · Crear tutor (T-25) | `crearCuentaPersonal(nombre:, correo:, contrasena:, rol:, tipoTutor:)` |
| HU-01 · Crear estudiante (T-26, T-31, T-32) | `crearCuentaEstudiante(estudiante, entrada)` |
| HU-01 · Cuenta duplicada (T-30) | lanza `ErrorAcceso('Ya existe una cuenta…')` |

El administrador **no pierde su sesión** al crear cuentas.

### Datos — `BaseDatos`

| HU / tarea | Método |
|---|---|
| HU-01/02 · Listar y editar cuentas (T-24, T-27) | `usuarios()`, `guardarUsuario(u)`, `todosLosEstudiantes()`, `actualizarPerfil(e)` |
| HU-03 · Rol (T-29) | `guardarUsuario(u)` con otro `rol` |
| HU-16 · Aulas (T-37 a T-43) | `aulas()`, `crearAula`, `actualizarAula`, `eliminarAula`, `cambiarAula(estId, aulaId)`, `estudiantesDeAula` |
| HU-16 · Tutores de un alumno (T-33 a T-36) | `asignarTutor`, `desasignarTutor`, `tutores()` |
| HU-17 · Solo mis alumnos (T-44) | `estudiantesDeTutor(uid)` |
| HU-19 · Perfil (T-48 a T-53) | `estudiante(id)`, `actualizarPerfil(e.copyWith(...))` |
| HU-19 · Foto (T-51) | `Almacenamiento().subirFotoEstudiante(id, bytes)` y luego `actualizarPerfil` |
| HU-15 · Preferencias (T-54 a T-62) | `actualizarPreferencias(id, p.copyWith(...))` (cambia `comunicacion` y `visual` y conserva el resto, como `preferencias.ava`), `permitirCambiarPreferencias(id, bool)` |
| T-31 · Método de acceso | `cambiarMetodoLogin(id, metodo)` |
| HU-04 a HU-08 · Tareas | `tareasDeEstudiante`, `crearTarea`, `actualizarTarea`, `eliminarTarea`, `pasosDe`, `tarea(id)` |
| HU-08 · Encargo para un aula | `Tarea(aulaId: …)` y `tareasDeAula(aulaId)` |
| HU-10 · Agenda (T-81 a T-88) | `tareasParaAgenda(estudiante)` (las suyas + las de su aula) y `tarea.esParaDia(dia)` |
| HU-11 · Siguiente tarea (T-95) | `CalculosAgenda` de `features/agenda/logica/calculos_agenda.dart` |
| HU-12 · Inicio y fin (T-96) | `marcarInicio(estId, tareaId, dia)`, `marcarFin(...)`, `registrosDelDia(estId, dia)` |

Los métodos que devuelven `Stream` se actualizan solos: con un `StreamBuilder`, la pantalla
cambia en cuanto cambian los datos (T-88).

### Ejemplo: pantalla de login del alumno (HU-09)

```dart
final auth = Autenticacion();
final bd = BaseDatos();

await auth.prepararTableta();                 // al abrir la pantalla
// 1) StreamBuilder con bd.aulas()                       → botones de aulas
// 2) StreamBuilder con bd.alumnosParaAcceso(aula.id)    → avatares (acceso.fotoUrl, acceso.nombre)
// 3) según acceso.metodoLogin, pedir PIN / pictogramas / contraseña
try {
  final sesion = await auth.entrarEstudiante(acceso, '1234');
  // sesion.estudiante → abrir su agenda
} on ErrorAcceso catch (e) {
  // enseñar e.mensaje
}
```

---

## 5. Cargar datos de prueba (una sola vez, ya hecho)

1. `home: const PantallaDesarrollo()` temporalmente en `main.dart` (import `dev/pantalla_desarrollo.dart`; no subáis ese cambio).
2. `flutter run -d chrome`, entrar como **admin**.
3. Pulsar **"Cargar datos de prueba"**. Crea las cuentas de la tabla del punto 1.

Si se pulsa otra vez, falla con "Ya existe una cuenta…": es normal.

---

## 6. Esquema detallado

### `usuarios/{uid}` — admin y tutores
| Campo | Tipo | Ejemplo |
|---|---|---|
| nombre | string | "Laura Martín" |
| email | string | "tutora.ava@ava-pruebas.test" |
| rol | string | `admin` \| `tutor` |
| tipoTutor | string \| null | `centro` \| `familiar` (null si es admin) |

### `estudiantes/{uid}` — estudiante y perfil
El id es el uid de su cuenta (correo interno `<usuario>@alumnos.ava.test`).

| Campo | Tipo | Ejemplo |
|---|---|---|
| nombre | string | "Pablo R." |
| usuario | string | "pablo" |
| lugarResidencia | string | "Granada" |
| fotoUrl | string | URL de Storage o de ARASAAC |
| queLeCalma, queNecesita | string | |
| intereses | array de string | ["fútbol", "música"] |
| metodoLogin | string | `pin` \| `pictograma` \| `contrasena` |
| aulaId | string \| null | id del aula |
| tutores | array de uid | [tutora, familiar] |
| puedeCambiarPreferencias | bool | false |
| preferencias | map | ver abajo |

`preferencias`:
```
comunicacion: { pictogramas, imagenes, texto, sonido, voz, botonesGrandes }   // booleanos
visual: { colores: "alto_contraste"|"claro"|"oscuro", tipografia, tamanoLetra,
          posicionMenus: "arriba"|"abajo", posicionBotones: "izquierda"|"derecha" }
```

### `estudiantes/{uid}/registros/{fecha_tareaId}` — inicio y fin (HU-12)
| Campo | Tipo |
|---|---|
| tareaId | string |
| fecha | string "yyyy-MM-dd" |
| estado | `pendiente` \| `iniciada` \| `terminada` |
| inicio, fin | timestamp |

### `acceso/{uid}` — ficha mínima para la tableta (HU-09)
`nombre` (de pila), `fotoUrl`, `aulaId`, `metodoLogin`, `usuario`. Se rellena sola al crear o
editar el estudiante. Es lo único (junto a `aulas`) que ve la tableta antes de que entre un alumno.

### `aulas/{id}`
`nombre`, `tutorResponsable` (uid).

### `tareas/{id}` y `tareas/{id}/pasos/{id}`
| Campo | Tipo | Notas |
|---|---|---|
| nombre, descripcion | string | |
| pictogramaUrl | string | ARASAAC o Storage |
| tipo | string | `colegio` \| `personal` |
| horaInicio, horaFin | string "HH:mm" | |
| diasSemana | array de int | 1 = lunes … 7 = domingo; vacío si es de un solo día |
| fecha | string "yyyy-MM-dd" \| null | día concreto si no se repite |
| creadaPor | uid | |
| estudiantes | array de uid | a quién va |
| aulaId | string \| null | encargo para toda un aula (HU-08) |

Pasos: `orden` (int), `texto`, `imagenUrl`.

### Quién puede hacer qué (resumen de las reglas)

| | Admin | Tutor | Estudiante | Tableta (anónima) |
|---|---|---|---|---|
| Cuentas y aulas | todo | ver aulas | — | ver aulas |
| Estudiantes | todo | sus alumnos: ver, perfil y preferencias | ver su ficha; preferencias si está autorizado | ficha `acceso` |
| Tareas | todo | crear; editar/borrar las suyas | ver las suyas y las de su aula; crear personales | — |
| Registros | ver | ver los de sus alumnos | crear/actualizar los suyos | — |
| Fotos | todo | de sus alumnos | — | ver |

---

## 7. Limitaciones conocidas

- **Cambiar el PIN o la clave de un alumno, o borrar su cuenta de acceso,** no se puede hacer desde
  la app sin un servidor (Cloud Functions). Por ahora: borrar sus datos y crear la cuenta de nuevo,
  o borrarla a mano en la consola (Authentication). Queda para la iteración 2.
- **Desactivar cuentas** (HU-13) es de la iteración 2.

---

## 8. Mantenimiento (Daniel)

```bash
conda activate nodejs
cd AVA
firebase deploy --only firestore:rules,firestore:indexes,storage
```
