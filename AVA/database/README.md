# Base de datos de AVA (Iteración 1 — Esquema v2)

La app guarda sus datos en **Firebase** (Google), proyecto **`proyecto-ava-54b58`**, plan Blaze:
- **Authentication**: cuentas (admin, tutores, estudiantes) y la sesión anónima de la tableta.
- **Cloud Firestore**: todos los datos (perfiles, aulas, tareas, registros…), en la región multirregión europea (`eur3`).
- **Cloud Storage**: fotos de perfil de estudiantes e imágenes de apoyo para tareas.

Cubre las **17 historias de usuario** de la Iteración 1 (**HU-01 a HU-12 y HU-15 a HU-19**, con 37 SP completados).

---

## 1. Qué está montado y operativo

| Componente | Estado | Descripción |
|---|---|---|
| **Authentication** | ✅ Completado | Correo/contraseña (admin y tutores) y sesión anónima de la tableta para acceso accesible. |
| **Cloud Firestore** | ✅ Completado | Reglas de seguridad (`firestore.rules`) e índices compuestos (`firestore.indexes.json`) desplegados. |
| **Cloud Storage** | ✅ Completado | Reglas de seguridad (`storage.rules`) para fotos de estudiantes y pasos. |
| **Cuenta de administrador** | ✅ Operativa | Acceso de administración global (`admin.ava@gmail.com`). |
| **Datos de prueba** | ✅ Cargados | Cuentas de tutor, aulas, alumnos con diversos métodos de acceso y tareas de ejemplo. |

> **Firestore no tiene tablas relacionales como SQL.** Cada colección se crea la primera vez que se almacena
> un documento en ella. La estructura la marcan nuestros **modelos en Dart** y repositorios: la app siempre guarda los
> datos con esos campos tipados e inmutables.
>
> **Nota sobre el modelo ER:** La entidad relacional «Asignación» de los diagramas conceptuales no existe como colección separada en Firestore: se resuelve de forma eficiente y no bloqueante mediante la lista `estudiantes` (HU-04) y el campo `aulaId` (HU-08) embebidos dentro de cada documento `tareas/{id}`.

### Cuentas para probar (Entorno de desarrollo)

| Rol | Usuario | Contraseña / Método de acceso |
|---|---|---|
| **Administrador** | `admin.ava@gmail.com` | `AVAadmin` |
| **Tutora del centro** | `tutora.ava@ava-pruebas.test` | `AVAtutor` |
| **Tutor familiar** | `familia.ava@ava-pruebas.test` | `AVAfamilia` |
| **Alumno Pablo (1º A)** | Selección de tarjeta | PIN: `1234` |
| **Alumna Marta (1º A)** | Selección de tarjeta | Pictogramas: Sol ☀️ $\rightarrow$ Perro 🐶 $\rightarrow$ Flor 🌸 |
| **Alumna Lucía (1º B)** | Selección de tarjeta | Contraseña: `lucia123` |
| **Alumno Javier (1º B)** | Selección de tarjeta | PIN: `4321` |

---

## 2. Qué tengo que hacer para programar y probar

```bash
git pull
cd AVA
flutter pub get
flutter run -d chrome      # Ejecución en navegador Web (o en tableta/emulador Android/iOS)
```

La conexión con Firebase ya va configurada en el repositorio (`lib/firebase_options.dart`). **No hay que tocar nada de Firebase.**

La aplicación utiliza la arquitectura de repositorios: para probar, acceded desde la pantalla de inicio con
las credenciales anteriores (pulsando el botón «Profesorado» para tutores y administración).

### Las 5 reglas de oro

1. **Usad siempre los servicios y repositorios** (`BaseDatos`, `Autenticacion`, `Almacenamiento` o las implementaciones `Repositorio*Firebase`). Nunca llaméis a `FirebaseFirestore.instance` ni a `FirebaseAuth.instance` directamente desde una vista o widget.
2. **Un tutor carga a sus estudiantes con `estudiantesDeTutor(uid)`.** Si solicita todos los estudiantes del colegio, las reglas de Firestore lo rechazan por diseño de seguridad (HU-17).
3. **Los nombres de los campos son estrictos**: coinciden exactamente con los modelos en Dart.
4. **Coordinación de cambios:** Cualquier campo nuevo o consulta requiere actualizar modelo, reglas e índices a la vez.
5. **Permisos:** Si recibís un error `permission-denied`, indica que las reglas de seguridad están impidiendo la operación para ese rol. Verificad con qué cuenta habéis iniciado sesión.

---

## 3. Qué hace cada fichero

### Servicios (`lib/core/servicios/`) — capa base de datos y red

| Fichero | Para qué |
|---|---|
| `base_datos.dart` | **Leer y guardar datos** (estudiantes, aulas, tareas, registros de inicio/fin…) |
| `autenticacion.dart` | **Gestión de sesiones y credenciales** (admin, tutores y alumnos) |
| `almacenamiento.dart` | **Subir imágenes a Cloud Storage** (foto de perfil del alumno, fotos de tareas) |
| `servicio_arasaac.dart` | **Búsqueda y descarga de pictogramas** de la API de ARASAAC |

### Repositorios (`lib/features/*/dominio/`) — abstracción desacoplada

| Fichero | Responsabilidad |
|---|---|
| `autenticacion/dominio/repositorio_autenticacion_firebase.dart` | Inicio de sesión, recuperación y cierre de sesión |
| `autenticacion/dominio/repositorio_cuentas_firebase.dart` | Creación y listado de usuarios de Firebase Auth y Firestore |
| `perfil/dominio/repositorio_estudiantes_firebase.dart` | Lectura, edición de perfil y preferencias de accesibilidad |
| `aulas/dominio/repositorio_aulas_firebase.dart` | Gestión de aulas y asignaciones escolares |
| `tareas/dominio/repositorio_tareas_firebase.dart` | CRUD de tareas, gestión de pasos y registros de actividad (HU-12) |
| `perfil/dominio/conversion_firestore.dart` | Mapeo bidireccional entre documentos Firestore y entidades Dart |

### Modelos de dominio (`lib/features/*/dominio/`)

| Fichero | Qué representa | Colección / Documento |
|---|---|---|
| `autenticacion/dominio/usuario.dart` | Admin o tutor (rol, tipo: centro/familiar) | `usuarios/{uid}` |
| `autenticacion/dominio/acceso.dart` | Ficha mínima del alumno para la pantalla de selección de la tableta | `acceso/{uid}` |
| `perfil/dominio/estudiante.dart` | Estudiante con perfil completo y apoyos | `estudiantes/{uid}` |
| `perfil/dominio/preferencias.dart` | Preferencias de accesibilidad (comunicación, visual, AVA) | campo `preferencias` en `estudiantes/{uid}` |
| `aulas/dominio/aula.dart` | Aula y tutor responsable | `aulas/{id}` |
| `tareas/dominio/tarea.dart` | Tarea: nombre, pictograma, horario, días/fecha, destinatarios, categoría | `tareas/{id}` |
| `tareas/dominio/paso.dart` | Paso individual secuencial de una tarea | `tareas/{id}/pasos/{pasoId}` |
| `agenda/dominio/registro.dart` | Registro de inicio y finalización de tarea | `estudiantes/{uid}/registros/{fecha_tareaId}` |

### Configuración (en la raíz de `AVA/`)

| Fichero | Qué es |
|---|---|
| `firestore.rules` | Reglas de seguridad de la base de datos Firestore |
| `storage.rules` | Reglas de seguridad de almacenamiento de fotos |
| `firestore.indexes.json` | Índices compuestos requeridos para las consultas de la app |
| `firebase.json`, `.firebaserc` | Configuración del proyecto de Firebase CLI |
| `lib/firebase_options.dart` | Configuración de inicialización de Firebase multiplataforma |

### Herramientas de Desarrollo (`lib/dev/`)

| Fichero | Qué es |
|---|---|
| `pantalla_desarrollo.dart` | Vista para entrar como administrador y poblar la base de datos |
| `datos_prueba.dart` | Creación de cuentas, aulas, estudiantes y tareas de prueba |

---

## 4. Qué método usar para cada historia de usuario

### Cuentas e inicio de sesión — `Autenticacion` / Repositorios

| HU / Requisito | Método |
|---|---|
| **HU-18** · Login de tutor/admin | `entrarPersonal(correo, contraseña)` $\rightarrow$ devuelve `Sesion` |
| **HU-18** · Mensajes de error claros | Lanza `ErrorAcceso` con mensaje legible en pantalla |
| **HU-18** · Recuperar contraseña | `recuperarContrasena(correo)` |
| **HU-18** · Cerrar sesión | `salir()` |
| **HU-18** · Redirigir según el rol | `quienSoy()` $\rightarrow$ `sesion.esAdmin / esTutor / esEstudiante` |
| **HU-09** · Tableta antes del login | `prepararTableta()` (sesión anónima) y lectura de `aulas()` y `alumnosParaAcceso(aulaId)` |
| **HU-09** · Login adaptado del alumno | `entrarEstudiante(acceso, entrada)` — `entrada` es PIN (`'1234'`), lista de 3 pictogramas o contraseña |
| **HU-09** · Pictogramas de clave | `Autenticacion.pictogramasClave` (sol, perro, flor, estrella, manzana, luna) |
| **HU-01** · Crear tutor | `crearCuentaPersonal(nombre:, correo:, contrasena:, rol:, tipoTutor:)` |
| **HU-01** · Crear estudiante | `crearCuentaEstudiante(estudiante, entrada)` (asigna correo interno `@alumnos.ava.test`) |
| **HU-01** · Detección de duplicados | Lanza `ErrorAcceso('Ya existe una cuenta…')` |

### Datos y Operaciones — `BaseDatos` / Repositorios

| HU / Requisito | Método |
|---|---|
| **HU-01 / HU-02** · Listar y editar cuentas | `usuarios()`, `guardarUsuario(u)`, `todosLosEstudiantes()`, `actualizarPerfil(e)` |
| **HU-03** · Asignación de roles | `guardarUsuario(u)` modificando el campo `rol` (`admin` o `tutor`) |
| **HU-16** · Gestión de aulas | `aulas()`, `crearAula`, `actualizarAula`, `eliminarAula`, `cambiarAula(estId, aulaId)` |
| **HU-16** · Asignación de tutores | `asignarTutor`, `desasignarTutor`, `tutores()` |
| **HU-17** · Filtro estricto por tutor | `estudiantesDeTutor(uid)` (garantizado por reglas de Firestore) |
| **HU-19** · Perfil del estudiante | `estudiante(id)`, `actualizarPerfil(e.copyWith(...))` |
| **HU-19** · Foto de perfil | `Almacenamiento().subirFotoEstudiante(id, bytes)` y posterior guardado en perfil |
| **HU-15** · Preferencias de accesibilidad | `actualizarPreferencias(id, p.copyWith(...))`, `permitirCambiarPreferencias(id, bool)` |
| **HU-04 / HU-05** · Tareas personales | `tareasDeEstudiante(uid)`, `crearTarea`, `actualizarTarea`, `eliminarTarea`, `tarea(id)` |
| **HU-06 / HU-07** · Horarios y pasos | Formulario de tarea con `horaInicio`, `horaFin`, `diasSemana` o `fecha`, y `pasosDe(tareaId)` |
| **HU-08** · Encargos de aula o compartidos | `Tarea(aulaId: …)` y lectura con `tareasDeAula(aulaId)` |
| **HU-10** · Consulta de agenda diaria/semanal | `tareasParaAgenda(estudiante)` (tareas propias + tareas de aula) y filtro `tarea.esParaDia(dia)` |
| **HU-11** · Siguiente tarea («Ahora/Después») | Clase de dominio `CalculosAgenda.determinar(tareas, ahora)` |
| **HU-12** · Registro de inicio y fin | `marcarInicio(estId, tareaId, dia)`, `marcarFin(...)`, `registrosDelDia(estId, dia)` |

---

## 5. Carga de datos de prueba (Población inicial)

Los datos de prueba ya se encuentran inicializados en el proyecto Firebase. Si fuera necesario repoblarlos desde cero:
1. Configurar temporalmente `home: const PantallaDesarrollo()` en `lib/main.dart`.
2. Ejecutar `flutter run -d chrome`.
3. Iniciar sesión con la cuenta de administrador (`admin.ava@gmail.com` / `AVAadmin`).
4. Pulsar el botón **"Cargar datos de prueba"**. (Se crearán las cuentas, aulas, alumnos y tareas descritas en el punto 1).
5. Restaurar `lib/main.dart` a su estado original.

---

## 6. Esquema detallado de Cloud Firestore (v2)

### Colección `usuarios/{uid}` — Administradores y Tutores
| Campo | Tipo | Ejemplo | Descripción |
|---|---|---|---|
| `nombre` | string | "Laura Martín" | Nombre completo del tutor o administrador |
| `email` | string | "tutora.ava@ava-pruebas.test" | Correo de inicio de sesión |
| `rol` | string | `admin` \| `tutor` | Rol en el sistema |
| `tipoTutor` | string \| null | `centro` \| `familiar` | Ámbito del tutor (null si es administrador) |

### Colección `estudiantes/{uid}` — Estudiante y perfil completo
El `uid` corresponde a su identificador de cuenta en Firebase Authentication (con correo interno `<usuario>@alumnos.ava.test`).

| Campo | Tipo | Ejemplo / Valores | Descripción |
|---|---|---|---|
| `nombre` | string | "Pablo R." | Nombre de pila o representativo |
| `usuario` | string | "pablo" | Identificador único de usuario |
| `lugarResidencia` | string | "Granada" | Datos informativos del entorno |
| `fotoUrl` | string | URL de Cloud Storage o ARASAAC | Imagen de perfil |
| `color` | string \| null | "azul", "verde", "amarillo" | Color personal de su tarjeta |
| `queLeCalma` | string | "Escuchar música clásica" | Apoyo emocional documentado (HU-19) |
| `queNecesita` | string | "Apoyo en transiciones" | Pautas de asistencia para el tutor |
| `intereses` | array de string | `["fútbol", "música"]` | Gustos y motivaciones del alumno |
| `observaciones` | string \| null | "Muy participativo hoy" | Notas pedagógicas de seguimiento (HU-19) |
| `metodoLogin` | string | `pin` \| `pictograma` \| `contrasena` | Modalidad de acceso a la tableta |
| `aulaId` | string \| null | `id` del documento del aula | Aula a la que pertenece |
| `tutores` | array de string | `[uid_tutora, uid_familiar]` | Lista de UIDs de tutores asignados |
| `puedeCambiarPreferencias` | bool | `false` | Autorización para modificar sus ajustes |
| `puedeGestionarTareas` | bool | `true` | Autorización para crear/borrar sus tareas (HU-04) |
| `preferencias` | map | (Ver desglose inferior) | Ajustes sensoriales y de comunicación |

#### Estructura del mapa `preferencias`:
```text
comunicacion: {
  pictogramas: bool,
  imagenes: bool,
  texto: bool,
  sonido: bool,
  voz: bool,
  botonesGrandes: bool
}
visual: {
  colores: "alto_contraste" | "claro" | "oscuro",
  tipografia: string,
  tamanoLetra: "normal" | "grande" | "muy_grande",
  posicionMenus: "arriba" | "abajo",
  posicionBotones: "izquierda" | "derecha"
}
ava: {
  color: string,
  modoOscuro: bool,
  botonEscuchar: bool,
  filtroAntitemblor: bool,
  vistasAgenda: array de string
}
```

### Subcolección `estudiantes/{uid}/registros/{fecha_tareaId}` — Registro de inicio y fin (HU-12)
| Campo | Tipo | Ejemplo | Descripción |
|---|---|---|---|
| `tareaId` | string | "tarea_123" | Identificador de la tarea |
| `fecha` | string | "2026-11-11" | Fecha en formato ISO (`yyyy-MM-dd`) |
| `estado` | string | `pendiente` \| `iniciada` \| `terminada` | Estado del alumno en la actividad |
| `inicio` | timestamp \| null | `2026-11-11 09:05:00` | Momento en el que pulsa «Empezar» |
| `fin` | timestamp \| null | `2026-11-11 09:45:00` | Momento en el que pulsa «He terminado» |

### Colección `acceso/{uid}` — Ficha mínima para la tableta (HU-09)
Contiene `nombre`, `fotoUrl`, `aulaId`, `metodoLogin` y `usuario`. Es generada automáticamente por los repositorios al crear o editar el estudiante. Es la única colección que la tableta lee de forma anónima antes del inicio de sesión del estudiante.

### Colección `aulas/{id}` — Agrupaciones escolares (HU-16)
| Campo | Tipo | Ejemplo | Descripción |
|---|---|---|---|
| `nombre` | string | "Aula PTVAL 1º A" | Denominación del aula |
| `tutorResponsable` | string (uid) | UID de la tutora | Tutor principal del aula |
| `color` | string \| null | "verde" | Color temático para la interfaz |
| `pictograma` | string \| null | URL o nombre del pictograma | Icono representativo del aula |

### Colección `tareas/{id}` y Subcolección `tareas/{id}/pasos/{id}`
| Campo | Tipo | Ejemplo / Valores | Descripción |
|---|---|---|---|
| `nombre` | string | "Poner la mesa del comedor" | Título breve de la actividad |
| `descripcion` | string | "Colocar bandejas y cubiertos" | Detalle de la tarea |
| `pictogramaUrl` | string | URL de ARASAAC o Storage | Apoyo visual principal |
| `tipo` | string | `colegio` \| `personal` | Ámbito de la tarea |
| `categoria` | string \| null | `clase` \| `personal` \| `ocio` \| `casa` \| `encargo` | Clasificación con color distintivo |
| `horaInicio` | string | "09:00" | Hora de inicio en formato `HH:mm` |
| `horaFin` | string | "09:45" | Hora de conclusión en formato `HH:mm` |
| `diasSemana` | array de int | `[1, 2, 3, 4, 5]` | Días lectivos (1 = lunes ... 7 = domingo) |
| `fecha` | string \| null | "2026-11-12" | Fecha específica si es tarea puntual de un solo día |
| `creadaPor` | string (uid) | UID del creador | Docente o alumno creador |
| `estudiantes` | array de uid | `[uid1, uid2]` | Lista de estudiantes a los que aplica |
| `aulaId` | string \| null | `id_aula` | Identificador de aula para encargos de grupo (HU-08) |

**Subcolección `pasos/{pasoId}`:**
- `orden` (int): Posición secuencial del paso (1, 2, 3...).
- `texto` (string): Instrucción en lectura fácil.
- `imagenUrl` (string): Fotografía o pictograma del paso.

---

## 7. Matriz de Seguridad y Reglas de Firestore

| Colección / Recurso | Administrador | Tutor | Estudiante | Tableta (Sesión Anónima) |
|---|---|---|---|---|
| **`usuarios`** | Lectura y escritura total | Lectura de su propio perfil | Sin acceso | Sin acceso |
| **`aulas`** | Lectura y escritura total | Lectura de aulas | Sin acceso | Lectura de aulas públicas |
| **`acceso`** | Lectura y escritura total | Lectura total | Lectura | Lectura (para selector de alumnos) |
| **`estudiantes`** | Lectura y escritura total | Lectura y edición de **sus alumnos asignados** | Lectura de su perfil; edición de preferencias si está autorizado | Sin acceso |
| **`tareas`** | Lectura y escritura total | Crear; editar y borrar las que ha creado | Ver sus tareas asignadas y las de su aula; crear personales si tiene permiso | Sin acceso |
| **`registros`** | Lectura total | Ver registros de sus alumnos | Crear y actualizar sus propios registros (HU-12) | Sin acceso |
| **Cloud Storage** | Lectura y subida total | Subir fotos para sus alumnos y tareas | Sin permisos de subida | Lectura de recursos públicos |

---

## 8. Limitaciones conocidas y próximos pasos (Iteración 2)

- **Gestión avanzada de credenciales sin servidor:** La modificación del PIN/clave o la eliminación física de la cuenta de Firebase Auth requiere Cloud Functions o la consola de Firebase. Queda planificada para la Iteración 2.
- **Desactivación temporal de cuentas (HU-13):** Mecanismo de deshabilitación sin borrado físico de datos planificado para el siguiente sprint.
- **Repetición semanal y recurrencia avanzada (HU-14):** Ampliación del motor de periodicidad de tareas.
- **Módulo de Comedor (HU-23 a HU-25) y Seguimiento en tiempo real (HU-26, HU-27, HU-29):** Próximas funcionalidades a conectar con la base de datos en la Iteración 2.

---

## 9. Mantenimiento y despliegue de reglas (Daniel)

Para desplegar actualizaciones en las reglas de seguridad o índices compuestos de Firestore:

```bash
cd AVA
firebase deploy --only firestore:rules,firestore:indexes,storage
```
