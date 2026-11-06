# Base de datos de AVA (iteración 1)

La app guarda sus datos en **Firebase**, el servicio de Google:
- **Authentication**: cuentas y contraseñas (administrador, tutores y estudiantes).
- **Cloud Firestore**: el resto de datos (perfiles, aulas, tareas…), en servidores de Europa.

Proyecto de Firebase: **`proyecto-ava-54b58`**.
Requisitos que cubre: RF-01 a RF-09, RF-15 y RF-22.

---

## 1. Qué hay ya montado en Firebase

| Qué | Estado |
|---|---|
| Proyecto y Authentication (correo y contraseña) | ✅ Hecho |
| Base de datos Firestore (Europa) | ✅ Hecha |
| Reglas de seguridad e índices | ✅ Subidos |
| Cuenta de administrador (colección `usuarios`) | ✅ Creada |
| Colecciones `estudiantes`, `aulas`, `tareas` | ⏳ Se crean solas cuando la app guarde el primer dato |

> **Firestore no tiene tablas como SQL.** No se crean columnas antes: cada colección aparece
> la primera vez que se guarda un documento en ella. El "esquema" lo marcan nuestros
> **modelos en Dart**: la app siempre guarda los datos con esos campos.

---

## 2. Qué hace cada fichero

### En la carpeta `AVA/` (junto a `pubspec.yaml`)

| Fichero | Qué es | ¿Lo tengo que tocar? |
|---|---|---|
| `firebase.json` | Le dice a la herramienta `firebase` dónde están las reglas y los índices. | No |
| `.firebaserc` | Guarda el ID de nuestro proyecto (`proyecto-ava-54b58`). | No |
| `firestore.rules` | **Reglas de seguridad**: quién puede leer o escribir cada cosa. Por ejemplo, un tutor solo ve a sus estudiantes. | Solo si cambian los permisos (y luego hay que subirlas, ver punto 5) |
| `firestore.indexes.json` | **Índices**: Firebase los necesita para consultas que filtran y ordenan a la vez (p. ej. "estudiantes de este tutor ordenados por nombre"). | Solo si se añade una consulta nueva que los pida |
| `lib/firebase_options.dart` | Generado automáticamente. Conecta la app con nuestro proyecto. No tiene contraseñas. | No |
| `lib/main.dart` | Ahora arranca Firebase (`Firebase.initializeApp`) antes de abrir la app. | Lo normal; solo no quitéis esas líneas |
| `android/`, `ios/` | Carpetas de cada plataforma que genera Flutter. | No |

### Los modelos (`lib/features/*/dominio/`)

Cada modelo es una clase Dart que representa **un tipo de dato** guardado en Firestore. Convierten
lo que viene de la base de datos en objetos (`fromDoc`) y al revés (`toMap`).

| Fichero | Qué representa | Colección |
|---|---|---|
| `autenticacion/dominio/usuario.dart` | Administrador o tutor (rol y si es del centro o familiar) | `usuarios` |
| `perfil/dominio/estudiante.dart` | Estudiante: nombre, residencia, foto, qué le calma, qué necesita, aula, tutores, forma de entrar | `estudiantes` |
| `perfil/dominio/preferencias.dart` | Preferencias de comunicación (pictogramas, voz, botones grandes…) y visuales (colores, letra…) | dentro de `estudiantes` |
| `aulas/dominio/aula.dart` | Aula y su tutor responsable | `aulas` |
| `tareas/dominio/tarea.dart` | Tarea: nombre, pictograma, tipo, horario, días y a qué estudiantes va | `tareas` |
| `tareas/dominio/paso.dart` | Un paso de una tarea (orden y texto) | `tareas/{id}/pasos` |

### El servicio (`lib/core/servicios/base_datos.dart`)

Es **la única puerta de entrada a la base de datos**. Las pantallas no hablan con Firestore
directamente: llaman a métodos de `BaseDatos`. Así todos guardamos los datos igual y las
consultas cumplen las reglas de seguridad.

| Para… | Método |
|---|---|
| Saber quién ha entrado (admin, tutor o estudiante) | `obtenerUsuario(uid)`, `obtenerEstudiante(uid)` |
| Lista de estudiantes de un tutor (RF-06) | `estudiantesDeTutor(uid)` |
| Crear / borrar estudiante (RF-01) | `crearEstudiante`, `eliminarEstudiante` |
| Asignar / quitar tutor (RF-04) | `asignarTutor`, `desasignarTutor` |
| Aulas (RF-05) | `aulas`, `crearAula`, `actualizarAula`, `cambiarAula`, `eliminarAula` |
| Perfil y preferencias (RF-07 a RF-09) | `actualizarPerfil`, `actualizarPreferencias` |
| Tareas (RF-15) | `crearTarea`, `actualizarTarea`, `eliminarTarea`, `pasosDe` |
| Tareas de hoy del estudiante (RF-22) | `tareasDelDia(uid)` |

Los métodos que devuelven `Stream` se actualizan solos: si se usan con un `StreamBuilder`,
la pantalla cambia en cuanto cambian los datos. Ejemplos de código en `MODELOS.md`.

### En esta carpeta (`database/`)

| Fichero | Qué es |
|---|---|
| `README.md` | Este documento |
| `MODELOS.md` | Ejemplos de código para usar los modelos y el servicio |
| `seed/` | Script que mete datos de prueba en el **emulador local** (no en la base de datos real) |

---

## 3. Qué tengo que hacer para trabajar con esto

```bash
git pull
cd AVA
flutter pub get
flutter run
```

Nada más: la conexión con Firebase ya va en el repositorio.
Para **ver los datos** en la consola web (console.firebase.google.com) hay que estar invitado
al proyecto: pasad vuestro Gmail a Daniel.

### Reglas importantes al programar

1. **Usad siempre `BaseDatos`**, no `FirebaseFirestore.instance` directamente en las pantallas.
2. **Un tutor carga a sus estudiantes con `estudiantesDeTutor(uid)`.** Si pide todos los estudiantes, Firebase lo rechaza (es a propósito: RF-06).
3. **Los nombres de los campos no se cambian** sin avisar: si uno guarda `nombre` y otro lee `name`, no funciona.
4. Si necesitáis un campo nuevo, añadidlo al modelo (`fromDoc` y `toMap`) y a este README.

---

## 4. Esquema detallado

#### `usuarios/{uid}` — administradores y tutores (RF-01, RF-02)
El id del documento es el `uid` de Firebase Authentication.

| Campo | Tipo | Ejemplo |
|---|---|---|
| nombre | string | "Laura Martín" |
| email | string | "tutor.centro@agenda.test" |
| rol | string | `admin` \| `tutor` |
| tipoTutor | string \| null | `centro` \| `familiar` (null si es admin) |
| creadoEn | timestamp | |

#### `estudiantes/{uid}` — estudiantes y su perfil (RF-01, RF-03, RF-04, RF-06 a RF-09)
El id del documento es el `uid` de la cuenta de Authentication del estudiante.

| Campo | Tipo | Ejemplo |
|---|---|---|
| nombre | string | "Pablo R." |
| usuario | string | "pablo.r" (lo que escribe o elige para entrar) |
| lugarResidencia | string | "Granada" |
| fotoUrl | string | URL de Cloud Storage |
| queLeCalma | string | |
| queNecesita | string | |
| metodoLogin | string | `pin` \| `pictograma` \| `contrasena` |
| aulaId | string | "aula-ptval-1" |
| tutores | array de uid | [uidTutor, uidFamiliar] |
| preferencias | map | ver abajo |
| creadoEn | timestamp | |

`preferencias`:
```
comunicacion: { pictogramas, imagenes, texto, sonido, voz, botonesGrandes }   // booleanos
visual: {
  colores: "alto_contraste" | "claro" | "oscuro",
  tipografia: "Atkinson Hyperlegible",
  tamanoLetra: 22,
  posicionMenus: "arriba" | "abajo",
  posicionBotones: "izquierda" | "derecha"
}
```

#### `aulas/{aulaId}` — aulas (RF-05)

| Campo | Tipo |
|---|---|
| nombre | string |
| tutorResponsable | uid |
| creadoEn | timestamp |

Los estudiantes de un aula se consultan con `where('aulaId', isEqualTo: id)`.

#### `tareas/{tareaId}` — tareas (RF-15, RF-22)

| Campo | Tipo | Ejemplo |
|---|---|---|
| nombre | string | "Preparar la mochila" |
| pictogramaUrl | string | `https://static.arasaac.org/pictograms/<id>/<id>_300.png` |
| descripcion | string | |
| tipo | string | `colegio` \| `personal` |
| horaInicio / horaFin | string "HH:mm" | "10:00" |
| diasSemana | array de int | [1, 3] (1 = lunes … 7 = domingo) |
| creadaPor | uid | |
| estudiantes | array de uid | a quién va la tarea |
| creadoEn | timestamp | |

#### `tareas/{tareaId}/pasos/{pasoId}` — pasos de una tarea

| Campo | Tipo |
|---|---|
| orden | int |
| texto | string |
| imagenUrl | string |

---

### Consultas que usará la app

| Pantalla | Consulta |
|---|---|
| Lista de estudiantes del tutor (RF-06) | `estudiantes.where('tutores', arrayContains: uid).orderBy('nombre')` |
| Estudiantes de un aula (RF-05) | `estudiantes.where('aulaId', isEqualTo: id).orderBy('nombre')` |
| Tareas del estudiante (RF-22) | `tareas.where('estudiantes', arrayContains: uid).orderBy('horaInicio')` y en la app quedarse con las que tienen el día de hoy en `diasSemana` |
| Tareas creadas por un tutor | `tareas.where('creadaPor', isEqualTo: uid).orderBy('nombre')` |

**Importante (RF-06):** el tutor tiene que consultar siempre con el filtro `arrayContains: uid`. Si pide toda la colección, las reglas rechazan la consulta.

---

### Notas para quien programe

- **Inicio de sesión del estudiante (RF-03):** el estudiante tiene una cuenta normal de Authentication con correo interno `<usuario>@alumnos.agenda.local`. El PIN o la secuencia de pictogramas **es la contraseña**, así que no se guarda en Firestore. Authentication exige al menos 6 caracteres: para un PIN de 4 cifras, la app debe añadir un sufijo fijo antes de enviarlo (por ejemplo `1234` → `1234-pin`).
- **Crear cuentas desde la app (RF-01):** si el administrador crea una cuenta con `createUserWithEmailAndPassword`, Firebase cierra su sesión y entra con la nueva. Para evitarlo, usad una segunda instancia de `FirebaseApp` solo para crear cuentas.
- **Lo que hacen las reglas:**
  - El administrador lo puede todo.
  - El tutor solo lee y edita a sus estudiantes, y no puede cambiarles los tutores ni el aula.
  - El tutor crea tareas y solo edita las suyas.
  - El estudiante solo lee su documento y sus tareas.

---

---

## 5. Tareas de mantenimiento (normalmente solo Daniel)

**Cambiar las reglas o los índices** (tras editar `firestore.rules` o `firestore.indexes.json`), desde `AVA/`:
```bash
firebase login
firebase deploy --only firestore:rules,firestore:indexes
```

**Probar con datos falsos en local** (sin tocar la base de datos real; hace falta Java):
```bash
firebase emulators:start --project demo-agenda      # web en http://localhost:4000
# en otra terminal:
cd database/seed && npm install && npm run seed
```
Crea un administrador, dos tutores, un aula, dos estudiantes y dos tareas, todos inventados.

| Rol (solo emulador) | Usuario | Contraseña |
|---|---|---|
| Administrador | `admin@agenda.test` | `admin123` |
| Tutor del centro | `tutor.centro@agenda.test` | `tutor123` |
| Tutor familiar | `familia.ruiz@agenda.test` | `familia123` |