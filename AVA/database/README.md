# Base de datos — Agenda accesible (iteración 1)

Base de datos en **Cloud Firestore** (Firebase), región UE.
Requisitos cubiertos: RF-01 a RF-09, RF-15 y RF-22.

## Archivos

| Archivo | Para qué sirve |
|---|---|
| `firebase.json` | Configuración del proyecto Firebase y de los emuladores |
| `.firebaserc` | ID del proyecto de Firebase (hay que cambiarlo) |
| `firestore.rules` | Reglas de seguridad: quién puede leer y escribir cada colección |
| `firestore.indexes.json` | Índices para las consultas de la app |
| `database/README.md` | Este archivo: esquema de las colecciones |
| `database/seed/` | Script que carga datos de ejemplo en el emulador |

Los cuatro primeros van en la **raíz del repositorio**, junto a `pubspec.yaml`.

---

## Colecciones

### `usuarios/{uid}` — administradores y tutores (RF-01, RF-02)
El id del documento es el `uid` de Firebase Authentication.

| Campo | Tipo | Ejemplo |
|---|---|---|
| nombre | string | "Laura Martín" |
| email | string | "tutor.centro@agenda.test" |
| rol | string | `admin` \| `tutor` |
| tipoTutor | string \| null | `centro` \| `familiar` (null si es admin) |
| creadoEn | timestamp | |

### `estudiantes/{uid}` — estudiantes y su perfil (RF-01, RF-03, RF-04, RF-06 a RF-09)
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

### `aulas/{aulaId}` — aulas (RF-05)

| Campo | Tipo |
|---|---|
| nombre | string |
| tutorResponsable | uid |
| creadoEn | timestamp |

Los estudiantes de un aula se consultan con `where('aulaId', isEqualTo: id)`.

### `tareas/{tareaId}` — tareas (RF-15, RF-22)

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

### `tareas/{tareaId}/pasos/{pasoId}` — pasos de una tarea

| Campo | Tipo |
|---|---|
| orden | int |
| texto | string |
| imagenUrl | string |

---

## Consultas que usará la app

| Pantalla | Consulta |
|---|---|
| Lista de estudiantes del tutor (RF-06) | `estudiantes.where('tutores', arrayContains: uid).orderBy('nombre')` |
| Estudiantes de un aula (RF-05) | `estudiantes.where('aulaId', isEqualTo: id).orderBy('nombre')` |
| Tareas del estudiante (RF-22) | `tareas.where('estudiantes', arrayContains: uid).orderBy('horaInicio')` y en la app quedarse con las que tienen el día de hoy en `diasSemana` |
| Tareas creadas por un tutor | `tareas.where('creadaPor', isEqualTo: uid).orderBy('nombre')` |

**Importante (RF-06):** el tutor tiene que consultar siempre con el filtro `arrayContains: uid`. Si pide toda la colección, las reglas rechazan la consulta.

---

## Notas para quien programe

- **Inicio de sesión del estudiante (RF-03):** el estudiante tiene una cuenta normal de Authentication con correo interno `<usuario>@alumnos.agenda.local`. El PIN o la secuencia de pictogramas **es la contraseña**, así que no se guarda en Firestore. Authentication exige al menos 6 caracteres: para un PIN de 4 cifras, la app debe añadir un sufijo fijo antes de enviarlo (por ejemplo `1234` → `1234-pin`).
- **Crear cuentas desde la app (RF-01):** si el administrador crea una cuenta con `createUserWithEmailAndPassword`, Firebase cierra su sesión y entra con la nueva. Para evitarlo, usad una segunda instancia de `FirebaseApp` solo para crear cuentas.
- **Lo que hacen las reglas:**
  - El administrador lo puede todo.
  - El tutor solo lee y edita a sus estudiantes, y no puede cambiarles los tutores ni el aula.
  - El tutor crea tareas y solo edita las suyas.
  - El estudiante solo lee su documento y sus tareas.

---

## Cómo crearla

### 1. Crear el proyecto en Firebase (una persona, una sola vez)
1. Entrar en <https://console.firebase.google.com> con una cuenta de Google → **Crear proyecto** (por ejemplo `agenda-ptval`). Analytics no hace falta.
2. **Compilación → Authentication → Comenzar**, y activar **Correo electrónico/contraseña**.
3. **Compilación → Firestore Database → Crear base de datos**:
   - Ubicación: `eur3 (europe-west)` o `europe-southwest1 (Madrid)`. **No se puede cambiar después.**
   - Modo: **producción** (las reglas de este repositorio lo abren lo justo).
4. **Configuración del proyecto → Usuarios y permisos**: añadir al resto del equipo como editores.

### 2. Conectar el repositorio
```bash
npm install -g firebase-tools
firebase login
# en .firebaserc, cambiar ID-DEL-PROYECTO-FIREBASE por el ID real
firebase deploy --only firestore:rules,firestore:indexes
```

### 3. Conectar la app Flutter
```bash
dart pub global activate flutterfire_cli
flutterfire configure            # genera lib/firebase_options.dart
flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage
```

### 4. Probar en local con datos de ejemplo (opcional)
Hace falta Java 11 o superior.
```bash
firebase emulators:start --project demo-agenda     # interfaz web en http://localhost:4000
# en otra terminal:
cd database/seed && npm install && npm run seed
```
El script solo escribe en el emulador. Crea un administrador, dos tutores (centro y familiar), un aula, dos estudiantes y dos tareas con pasos. Todos los datos son inventados.

Cuentas de prueba (solo en el emulador):

| Rol | Usuario | Contraseña |
|---|---|---|
| Administrador | `admin@agenda.test` | `admin123` |
| Tutor del centro | `tutor.centro@agenda.test` | `tutor123` |
| Tutor familiar | `familia.ruiz@agenda.test` | `familia123` |
