# AVA — Agenda Virtual Accesible (Proyecto AUTOVIDA 26-175)

Estructura base del proyecto Flutter desarrollada para el **Colegio de Educación Especial (CEE) Fundación Purísima Concepción** de Granada, dentro del marco de las asignaturas **Dirección y Gestión de Proyectos (DGP)** y **Metodologías de Desarrollo Ágil (MDA)** (Curso 2026–2027, UGR).

> **Enfoque actual:** Estructura modular y mockup base enfocado **exclusivamente en la Iteración 1**, diseñado con alta modularidad para permitir la incorporación limpia de futuras funcionalidades (Iteraciones 2 y 3) sin alterar el código existente.

---

## 🏛 Arquitectura del Proyecto (Feature-First / Modular)

El proyecto sigue una arquitectura **Feature-First (modular)** en español, conforme a las directrices de codificación del **Manual de Coordinación (DGP0, apartado 1.7)**. Cada módulo funcional de la Iteración 1 agrupa sus pantallas, su lógica de negocio y sus modelos de datos de forma desacoplada.

```text
AVA/
├── assets/                       # Recursos multimedia y de accesibilidad
│   ├── fuentes/                  # Tipografías legibles y lectura fácil
│   ├── iconos/                   # Iconografía de alta visibilidad
│   ├── pictogramas/              # Pictogramas (ARASAAC)
│   └── sonidos/                  # Refuerzos sonoros positivos y melodías
│
├── lib/
│   ├── main.dart                 # Punto de entrada: arranca Firebase y la app
│   ├── app/                      # Aplicación, rutas por rol y datos simulados de las pruebas
│   ├── dev/                      # Solo desarrollo: carga los datos de prueba en Firebase
│   │
│   ├── core/                     # Elementos transversales compartidos por todas las features
│   │   ├── constantes/           # Colores accesibles (WCAG AA), tamaños mínimos táctiles
│   │   ├── servicios/            # Clientes base de Firebase, API de ARASAAC y red
│   │   ├── tema/                 # Temas Material 3 (claro, oscuro, alto contraste)
│   │   ├── utilidades/           # Filtro antitemblor, formateadores de fecha/hora
│   │   └── widgets/              # Botón grande accesible, diálogo de confirmación, etc.
│   │
│   └── features/                 # MÓDULOS ACTIVOS DE LA ITERACIÓN 1 (Mockup e Incremento 1)
│       │
│       ├── autenticacion/        # Login admin/tutor y login adaptado alumno (PIN/foto/color)
│       │   ├── dominio/          # Modelos (Usuario, Rol, Credenciales)
│       │   ├── logica/           # Controladores y lógica de sesión (FirebaseAuth)
│       │   └── presentacion/     # Pantallas de login y bienvenida
│       │
│       ├── perfil/               # Preferencias de accesibilidad y datos del estudiante
│       │   ├── dominio/          # Modelo de PerfilEstudiante y PreferenciasAccesibilidad
│       │   ├── logica/           # Gestor de ajustes visuales y apoyos comunicativos
│       │   └── presentacion/     # Pantalla de ajustes de perfil y configuración
│       │
│       ├── agenda/               # Visualización temporal (diaria, semanal, "ahora/después")
│       │   ├── dominio/          # Modelo de Agenda y BloqueHorario
│       │   ├── logica/           # Cálculo de tarea actual y siguiente
│       │   └── presentacion/     # Vistas de agenda adaptadas a cada perfil
│       │
│       ├── tareas/               # Gestión de tareas personales y encargos del centro
│       │   ├── dominio/          # Modelo de Tarea, Paso, RecursoApoyo
│       │   ├── logica/           # Estado de ejecución y marcado de inicio/fin
│       │   └── presentacion/     # Pantalla de detalle de tarea y creación de encargos
│       │
│       └── aulas/                # Gestión de aulas, asignación de alumnos y tutores
│           ├── dominio/          # Modelo de Aula y AsignacionTutor
│           ├── logica/           # Gestión de agrupaciones escolares
│           └── presentacion/     # Vistas de administración de aulas
│
├── test/                         # Pruebas unitarias, de widgets y accesibilidad
│   ├── core/
│   └── features/                 # autenticacion, agenda, perfil y tareas
│
├── analysis_options.yaml         # Reglas de linting y calidad de código (flutter_lints)
└── pubspec.yaml                  # Configuración de dependencias (Firebase, ARASAAC, Provider)
```

---

## 🗺 Mapeo de Historias de Usuario (HU) — Iteración 1

En la **Iteración 1** (comprometida con 37 puntos de historia según el documento MDA0) únicamente abordamos estas 5 funcionalidades:

> Numeración del equipo (la misma de `database/README.md` y de la memoria): es la de `MDA0.md` con «editar cuentas» separada como HU-02, así que a partir de HU-02 cada historia de `MDA0.md` tiene un número más.

| Módulo (`lib/features/`) | Historias de Usuario (Iteración 1) | Requisitos Funcionales (DGP0) | Alcance de la Iteración 1 |
|---|---|---|---|
| **`autenticacion/`** | **HU-01, HU-02, HU-03, HU-09, HU-18** | RF-01, RF-02, RF-03, RF-04, RF-05 | Crear/editar cuentas, roles de acceso, login accesible para el estudiante (PIN/foto/color) y login para tutor/admin. |
| **`perfil/`** | **HU-15, HU-19** | RF-06 al RF-12 | Configuración del perfil del estudiante, personalización de apoyos (ARASAAC, fotos propias, colores, tipografía). |
| **`agenda/`** | **HU-10, HU-11, HU-12** | RF-23 al RF-28 | Consulta de agenda diaria o semanal, anticipación visual de la "siguiente tarea" y registro de inicio/fin de actividad. |
| **`tareas/`** | **HU-04, HU-05, HU-06, HU-07, HU-08** | RF-13 al RF-22 | Crear/modificar tareas personales, horarios, apoyos accesibles (fotos/pictogramas), instrucciones/rutas y encargos del centro. |
| **`aulas/`** | **HU-16, HU-17** | RF-01, RF-02 | Gestión de aulas, asignación de estudiantes a tutores y restricción de visibilidad a los alumnos asignados. |

---

## 🔌 Modularidad: ¿Cómo añadiremos futuras features sin romper nada?

Gracias al patrón **Feature-First**, el código de cada funcionalidad está completamente aislado:
- `lib/features/agenda/` no sabe nada interno de cómo está programado `lib/features/aulas/`.
- Cada módulo es autónomo y solo depende de los bloques compartidos en `lib/core/`.

### Plan de incorporación para futuros Sprints:

1. **Iteración 2:**
   - Crearemos la carpeta `lib/features/comedor/` (HU-23, HU-24, HU-25: registro de comensales, dietas y listado de cocina).
   - Crearemos la carpeta `lib/features/seguimiento/` (HU-26, HU-27, HU-29: monitorización en tiempo real y alertas para tutores).
   - Añadiremos los temporizadores visuales y avisos previos ampliando `lib/features/tareas/` (HU-14, HU-20, HU-21, HU-22, HU-28).
   - *Ventaja:* Como son carpetas nuevas o extensiones de modelos existentes, **ningún mockup o código de la Iteración 1 se rompe**.

2. **Iteración 3:**
   - Si se aborda la coordinación del hogar o el chat condicionado, simplemente se crearán `lib/features/hogar/` (HU-31, HU-32) y `lib/features/chat/` (HU-30).

---

## 🚀 Guía práctica para el equipo en la Iteración 1

1. **Elegir ticket en Jira** correspondiente a la Iteración 1 (por ejemplo: `HU-10: Consultar agenda diaria`).
2. **Crear rama propia:**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/AVA-09-agenda-diaria
   ```
3. **Desarrollar en el módulo correspondiente:**
   - `dominio/`: define el modelo de datos.
   - `logica/`: programa el estado y conexión con datos simulados o Firestore.
   - `presentacion/`: maqueta la pantalla utilizando los widgets accesibles de `core/widgets/`.
4. **Verificar calidad:**
   ```bash
   flutter analyze
   ```
5. **Abrir Pull Request** hacia `develop` para revisión de código.
