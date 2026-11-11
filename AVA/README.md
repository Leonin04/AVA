# AVA — Agenda Virtual Accesible (Proyecto AUTOVIDA 26-175)

Estructura y código fuente del proyecto Flutter desarrollado para el **Colegio de Educación Especial (CEE) Fundación Purísima Concepción** de Granada, dentro del marco de las asignaturas **Dirección y Gestión de Proyectos (DGP)** y **Metodologías de Desarrollo Ágil (MDA)** (Curso 2026–2027, UGR).

> **Estado actual:** **Iteración 1 Completada con éxito**. Prototipo funcional validado, integrado con Cloud Firebase (Authentication, Firestore v2, Cloud Storage) y con **92 pruebas automáticas superadas**. Se han completado los **37 Puntos de Historia (SP)** comprometidos en el Product Backlog.

---

## 🏛 Arquitectura del Proyecto (Feature-First / Modular)

El proyecto sigue una arquitectura **Feature-First (modular)** en español, conforme a las directrices de codificación del **Manual de Coordinación (DGP0, apartado 1.7)** y el patrón repositorio. Cada módulo funcional agrupa sus entidades de dominio, lógica de control y pantallas de forma desacoplada:

```text
AVA/
├── assets/                       # Recursos multimedia y de accesibilidad
│   ├── fuentes/                  # Tipografía Atkinson Hyperlegible (baja visión)
│   ├── iconos/                   # Logo oficial AVA, icono sol y recursos gráficos
│   ├── pictogramas/              # Pictogramas precargados de ARASAAC
│   └── sonidos/                  # Refuerzos sonoros positivos y melodías
│
├── lib/
│   ├── main.dart                 # Punto de entrada: arranque de Firebase y app accesible
│   ├── firebase_options.dart     # Configuración de Firebase para web y plataformas
│   ├── app/                      # Configuración de rutas por rol y datos simulados
│   ├── dev/                      # Herramientas de desarrollo (carga de datos en Firebase)
│   │
│   ├── core/                     # Elementos transversales compartidos
│   │   ├── constantes/           # Colores accesibles (paleta pastel WCAG AAA), pictogramas clave
│   │   ├── modelos/              # Modelo unificado de RecursoVisual (ARASAAC / FotoPropia)
│   │   ├── servicios/            # Clientes base de Firebase, API ARASAAC y almacenamiento
│   │   ├── tema/                 # Temas Material 3 (claro, oscuro, alto contraste)
│   │   ├── utilidades/           # Filtro antitemblor, formateadores de fecha y hora
│   │   └── widgets/              # Botón accesible grande, diálogo de confirmación, etc.
│   │
│   └── features/                 # MÓDULOS DE LA ITERACIÓN 1 (100% implementados)
│       │
│       ├── autenticacion/        # Login admin/tutor y login adaptado alumno (PIN/pictograma/contraseña)
│       │   ├── dominio/          # Modelos (Usuario, Rol, AccesoEstudiante, PictogramaClave)
│       │   ├── logica/           # Controladores de acceso, gestión de sesiones y recuperación
│       │   └── presentacion/     # Pantallas de login accesible, login profesorado y recuperación
│       │
│       ├── perfil/               # Preferencias de accesibilidad y ficha del estudiante
│       │   ├── dominio/          # Modelo de Estudiante, PreferenciasAccesibilidad y repositorios
│       │   ├── logica/           # Gestión de ajustes visuales y apoyos comunicativos
│       │   └── presentacion/     # Pantallas de configuración de perfil y accesibilidad
│       │
│       ├── agenda/               # Visualización temporal (diaria, semanal, "ahora/después")
│       │   ├── dominio/          # Modelo de RegistroActividad e interfaces
│       │   ├── logica/           # CalculosAgenda (determinación de tarea actual y siguiente)
│       │   └── presentacion/     # Vistas de agenda adaptadas a cada perfil (Hoy, Semana)
│       │
│       ├── tareas/               # Gestión de tareas personales y encargos del centro
│       │   ├── dominio/          # Modelo de Tarea, Paso, TipoTarea y repositorio Firestore
│       │   ├── logica/           # Formulario de tarea, validación y marcado de inicio/fin
│       │   └── presentacion/     # Formularios de creación, editor de pasos, detalle de tarea
│       │
│       └── aulas/                # Gestión de aulas, asignación de alumnos y tutores
│           ├── dominio/          # Modelo de Aula y repositorio de aulas
│           ├── logica/           # Gestión de agrupaciones escolares
│           └── presentacion/     # Pantalla de inicio de la tableta y administración de aulas
│
├── test/                         # 92 pruebas automáticas (unitarias, widgets y accesibilidad)
│   ├── core/                     # Pruebas de utilidades, colores, modelos y temas
│   ├── features/                 # Pruebas de autenticación, agenda, perfil y tareas
│   └── widget_test.dart          # Pruebas de componentes, contraste y accesibilidad visual
│
├── database/                     # Documentación de Firestore v2, reglas de seguridad e índices
├── ACCESIBILIDAD.md              # Cumplimiento WCAG 2.2 AA, W3C COGA y matriz de cobertura HU
├── INTEGRACION_FIREBASE.md       # Arquitectura de repositorios y modelos de Firestore
├── TAREAS_Y_AGENDA.md            # Detalle técnico de tareas y cálculo de agenda
├── analysis_options.yaml         # Reglas de linting y calidad de código (flutter_lints)
└── pubspec.yaml                  # Dependencias del proyecto (Firebase, ARASAAC, Provider)
```

---

## 🗺 Mapeo de Historias de Usuario (HU) — Iteración 1

En la **Iteración 1** se han completado los **37 puntos de historia** distribuidos en las **17 historias de usuario** del alcance:

> **Numeración unificada del equipo:** Conforme a `database/README.md`, `ACCESIBILIDAD.md` y la memoria del proyecto, la gestión de cuentas de `MDA0.md` se dividió en creación (HU-01) y edición (HU-02). A partir de ahí, las historias de `MDA0.md` se desplazan +1.

| Módulo (`lib/features/`) | Historias de Usuario (Iteración 1) | Requisitos Funcionales (DGP0) | Estado al cierre de la Iteración 1 |
|---|---|---|---|
| **`autenticacion/`** | **HU-01, HU-02, HU-03, HU-09, HU-18** | RF-01, RF-02, RF-03, RF-04, RF-05 | ✅ **Completado:** Creación/edición de cuentas, roles de usuario, login accesible del alumno (PIN, clave de 3 pictogramas o contraseña), login de administración/tutoría con correo, recuperación de contraseña y cierre de sesión. |
| **`perfil/`** | **HU-15, HU-19** | RF-06 al RF-12 | ✅ **Completado:** Configuración del perfil de accesibilidad (pictogramas, imágenes reales, colores de fondo con ratio WCAG AAA, tipografía Atkinson Hyperlegible, botón de voz, antitemblor) y ficha completa de estudiante (apoyos emocionales, intereses y datos de contacto). |
| **`agenda/`** | **HU-10, HU-11, HU-12** | RF-23 al RF-28 | ✅ **Completado:** Consulta de agenda en vista diaria y semanal (7 días), anticipación visual con bloque "Ahora / Después", y registro accesible de inicio y fin de tarea con refuerzo visual/sonoro. |
| **`tareas/`** | **HU-04, HU-05, HU-06, HU-07, HU-08** | RF-13 al RF-22 | ✅ **Completado:** Creación, edición y borrado de tareas personales; validación de horario; apoyos accesibles (fotos propias y pictogramas de ARASAAC); editor de pasos ordenados sin arrastre; encargos asignables a estudiantes o a toda un aula. |
| **`aulas/`** | **HU-16, HU-17** | RF-01, RF-02 | ✅ **Completado:** Administración de aulas del centro, asignación de tutores y restricción estricta de visibilidad de los estudiantes para cada docente/tutor. |

---

## 🧪 Pruebas Automáticas y Verificación de Accesibilidad

El código está respaldado por **92 pruebas automáticas** ejecutadas con `flutter test`:

1. **Pruebas de modelos y lógica de dominio:**
   - Inmutabilidad y clonado (`copyWith`) de entidades `Usuario`, `Estudiante`, `Tarea`, `Paso`, `Aula` y `RegistroActividad`.
   - Lógica de `CalculosAgenda`: cálculo de tarea en curso, siguiente tarea y ordenación cronológica.
   - Manejo de recursos visuales polimórficos (`RecursoVisual`, `PictogramaArasaac`, `FotoPropia`).
2. **Pruebas de repositorios y controladores:**
   - Repositorios simulados en memoria para ejecución autónoma sin conexión de red.
   - Validación de reglas de permisos (un tutor solo puede operar sobre sus estudiantes asignados).
   - Manejo de excepciones con mensajes amigables y comprensibles (`ErrorAcceso`).
3. **Pruebas de widgets y accesibilidad (WCAG 2.2 AA / AAA):**
   - Objetivos táctiles mínimos de 64 px (superando ampliamente los 24 px de la norma WCAG 2.5.8).
   - Ratios de contraste de texto ≥ 7:1 sobre fondos pastel.
   - Ausencia total de scroll o desplazamiento inesperado en las pantallas del alumno (`CuadriculaAjustada`).
   - Etiquetas semánticas descriptivas en botones, logo y controles de audio para lectores de pantalla.
   - Navegación asistida para pulsador o teclado físico (foco visible resaltado).

---

## 🔌 Modularidad: Preparación para Iteraciones 2 y 3

Gracias al patrón **Feature-First** y al desacoplamiento por repositorios abstractos:
- `lib/features/agenda/` interactúa únicamente con interfaces de dominio.
- El código de la **Iteración 1** permanece cerrado a modificaciones regresivas.

### Plan para los siguientes Sprints:
1. **Iteración 2:**
   - Creación de `lib/features/comedor/` (HU-23 a HU-25: registro de comensales, dietas especiales y listado de cocina).
   - Creación de `lib/features/seguimiento/` (HU-26, HU-27, HU-29: monitorización en tiempo real y alertas para el profesorado).
   - Incorporación de temporizadores visuales y avisos previos ampliando `lib/features/tareas/` (HU-13, HU-14, HU-20 a HU-22, HU-28).
2. **Iteración 3:**
   - Creación de `lib/features/hogar/` (coordinación con la familia) y `lib/features/chat/` (comunicación adaptada bidireccional).

---

## 🚀 Inicio Rápido y Comandos de Ejecución

### 1. Instalación de dependencias
```bash
flutter pub get
```

### 2. Comprobación estática de código
```bash
flutter analyze
```

### 3. Ejecución de la suite de pruebas (92 pruebas)
```bash
flutter test
```

### 4. Ejecución de la aplicación
- **En navegador Web (recomendado para desarrollo):**
  ```bash
  flutter run -d chrome
  ```
  O mediante servidor web local:
  ```bash
  flutter run -d web-server --web-port=8080
  ```
- **En tableta / emulador Android o iPad:**
  ```bash
  flutter run
  ```

---

## 🔑 Credenciales de Prueba (Entorno de Desarrollo)

La aplicación viene conectada directamente a Cloud Firebase. Para acceder a las distintas vistas:

- **Profesorado y Administración:** Pulsar el botón **"Profesorado"** en la barra superior:
  - **Administrador:** `admin.ava@gmail.com` / `AVAadmin`
  - **Tutora de centro:** `tutora.ava@ava-pruebas.test` / `AVAtutor`
  - **Tutor familiar:** `familia.ava@ava-pruebas.test` / `AVAfamilia`
- **Alumnado (Pantalla principal de la tableta):**
  - **Pablo (1º A):** Acceso por PIN $\rightarrow$ `1234`
  - **Marta (1º A):** Acceso por Pictogramas $\rightarrow$ Sol ☀️ $\rightarrow$ Perro 🐶 $\rightarrow$ Flor 🌸
  - **Lucía (1º B):** Acceso por contraseña $\rightarrow$ `lucia123`
  - **Javier (1º B):** Acceso por PIN $\rightarrow$ `4321`

---

## 📚 Documentación de Referencia

- [Esquema de Base de Datos y Reglas de Seguridad (database/README.md)](database/README.md)
- [Pautas de Accesibilidad y Matriz de Trazabilidad (ACCESIBILIDAD.md)](ACCESIBILIDAD.md)
- [Integración con Firebase y Repositorios (INTEGRACION_FIREBASE.md)](INTEGRACION_FIREBASE.md)
- [Especificación Técnica de Tareas y Agenda (TAREAS_Y_AGENDA.md)](TAREAS_Y_AGENDA.md)
