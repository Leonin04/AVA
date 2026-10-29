# AUTOVIDA — Agenda Virtual Accesible (AVA)

[![Asignatura](https://img.shields.io/badge/Asignaturas-DGP%20%7C%20MDA-blue.svg)](file:///home/david/5º/PrimerCuatri/DGP_MDA/DocumentosTeoria)
[![Universidad](https://img.shields.io/badge/Universidad-Granada%20(UGR)-red.svg)](https://www.ugr.es)
[![Curso](https://img.shields.io/badge/Curso-2026--2027-green.svg)](#)
[![Framework](https://img.shields.io/badge/Framework-Flutter-02569B?logo=flutter&logoColor=white)](file:///home/david/5º/PrimerCuatri/DGP_MDA/AVA)
[![Backend](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=black)](#)

Repositorio central del proyecto **AUTOVIDA (código 26-175)**, desarrollado de forma coordinada para las asignaturas **Dirección y Gestión de Proyectos (DGP)** y **Metodologías de Desarrollo Ágil (MDA)** del Grado en Ingeniería Informática de la **Universidad de Granada**.

El proyecto consiste en el diseño, especificación y desarrollo de **AVA (Agenda Virtual Accesible)**, una aplicación para tabletas Android e iOS destinada al **Colegio de Educación Especial (CEE) Fundación Purísima Concepción** de Granada, enfocada en fomentar la autonomía y organización del alumnado del **Programa de Transición a la Vida Adulta (PTVAL)**.

---

## 👥 Equipo de Trabajo

| Integrante | Roles DGP (It. 1 / 2 / 3) | Funciones Técnicas (It. 1 / 2 / 3) | Ámbito MDA |
|---|---|---|---|
| **David Bacas Posadas** | Coordinador $\rightarrow$ Presentador $\rightarrow$ Moderador | Planificación $\rightarrow$ Implementación $\rightarrow$ Especificación | Redactor y firmante |
| **Manuel José Fernández Poyatos** | Moderador $\rightarrow$ Catalogador $\rightarrow$ Coordinador | Especificación $\rightarrow$ Planificación $\rightarrow$ Implementación | Redactor y firmante |
| **Alberto David Gómez Gijón** | Catalogador $\rightarrow$ Coordinador $\rightarrow$ Presentador | Planificación $\rightarrow$ Especificación $\rightarrow$ Implementación | Redactor y firmante |
| **Paula Cobos González** | **Usabilidad y Accesibilidad** *(Fijo)* | Implementación $\rightarrow$ Especificación $\rightarrow$ Planificación | Redactora y firmante |
| **Adam Ben Chacha** | **Gestor de Calidad / QA** *(Fijo)* | Implementación $\rightarrow$ Planificación $\rightarrow$ Especificación | Soporte técnico DGP |
| **Daniel Viloria Prieto** | Presentador $\rightarrow$ Moderador $\rightarrow$ Catalogador | Especificación $\rightarrow$ Implementación $\rightarrow$ Planificación | Soporte técnico DGP |

---

## 📁 Estructura del Repositorio

El repositorio se organiza separando rigurosamente la documentación de ingeniería y gestión del código fuente de la aplicación:

```text
DGP_MDA/
├── DocumentosTeoria/             # 📚 Documentación formal de la entrega inicial
│   ├── DGP0.md                   # Manual de coordinación, propuesta técnica, actas y horas
│   ├── DGP0.pdf                  # PDF original de DGP
│   ├── MDA0.md                   # Fichas de persona DCU, escenarios, Product Backlog (31 HUs)
│   ├── MDA0.pdf                  # PDF original de MDA
│   └── img/                      # Figuras, avatares de personas y capturas extraídas
│
├── AVA/                          # 📱 Código fuente de la aplicación Flutter
│   ├── assets/                   # Pictogramas ARASAAC, sonidos de refuerzo, iconos y fuentes
│   ├── lib/
│   │   ├── main.dart             # Punto de entrada de la aplicación
│   │   ├── core/                 # Elementos transversales (constantes, temas, servicios, widgets)
│   │   └── features/             # Módulos funcionales desacoplados (Feature-First)
│   ├── test/                     # Pruebas unitarias, de widgets y accesibilidad
│   ├── pubspec.yaml              # Dependencias del proyecto (Firebase, ARASAAC, audio, etc.)
│   ├── analysis_options.yaml     # Reglas de calidad y linting (flutter_lints)
│   └── README.md                 # Guía técnica de desarrollo y mapeo de historias de usuario
│
└── README.md                     # Este archivo (visión global del repositorio)
```

---

## 🎯 Estado Actual: Iteración 1 (Mockup e Incremento 1)

Actualmente el equipo se encuentra construyendo el **mockup y la base funcional de la Iteración 1** (planificada en **37 puntos de historia** según MDA0). Para mantener el código limpio y sin elementos distractores, la carpeta de desarrollo (`AVA/lib/features/`) contiene únicamente las **5 funcionalidades correspondientes al alcance de esta primera entrega**:

1. 🔐 **`autenticacion`:** Creación de cuentas, roles de usuario y login accesible adaptado para estudiantes (PIN, foto o color) y tutores (**HU-01, HU-02, HU-08, HU-17**).
2. 👤 **`perfil`:** Configuración de apoyos de accesibilidad del alumno (pictogramas ARASAAC, imágenes reales, colores y tipografía) (**HU-14, HU-18**).
3. 📅 **`agenda`:** Vistas diaria y semanal de actividades, anticipación visual de la "siguiente tarea" y marcado accesible de inicio y fin (**HU-09, HU-10, HU-11**).
4. 📋 **`tareas`:** Gestión de tareas personales y encargos rotativos del colegio (reprografía, comedor, visitas), horarios y apoyos paso a paso (**HU-03 al HU-07**).
5. 🏫 **`aulas`:** Administración de aulas, asignación de docentes y restricción de visibilidad por perfil (**HU-15, HU-16**).

---

## 🔌 Arquitectura Modular: Preparada para Futuras Iteraciones

El proyecto está diseñado bajo una arquitectura **Feature-First (Modular) en 3 capas** (`dominio/`, `logica/`, `presentacion/`). 

Esto asegura que cuando el equipo avance a los siguientes sprints:
- **Iteración 2:** Bastará con crear las carpetas `lib/features/comedor/` (HU-22 a HU-24) y `lib/features/seguimiento/` (HU-25, HU-26, HU-28), y ampliar las tareas con temporizador (HU-13, HU-19 a HU-21). **No habrá que refactorizar ni tocar nada del código ya validado en la Iteración 1.**
- **Iteración 3:** Se incorporarán de forma aislada los módulos de coordinación del hogar y chat accesible condicionado.

---

## 🛠 Tecnologías Principales

- **Framework:** [Flutter](https://flutter.dev) (Dart) orientado a tabletas Android e iOS.
- **Backend Cloud:** [Firebase](https://firebase.google.com) (Authentication, Cloud Firestore en región UE, Cloud Storage y Cloud Messaging).
- **Recursos de Accesibilidad:** Integración con la API de [ARASAAC](https://arasaac.org) (Centro Aragonés de la Comunicación Aumentativa y Alternativa) bajo licencia CC BY-NC-SA.
- **Gestión Ágil y Calidad:** Jira Software (tablero Scrum y seguimiento burndown), GitHub (flujo de ramas `feature/<ticket>-<desc>`) y `flutter_lints` (conforme al estándar *Effective Dart* en español).

---

## 🚀 Inicio Rápido para Desarrolladores

Para ejecutar la aplicación localmente en un emulador de tableta o dispositivo físico:

```bash
# 1. Acceder a la carpeta de la aplicación
cd AVA

# 2. Descargar las dependencias
flutter pub get

# 3. Comprobar que no hay errores de análisis estático
flutter analyze

# 4. Ejecutar la aplicación
flutter run
```

Para más detalles sobre cómo estructurar el código de una tarea o qué modelo crear, consulta la [Guía Técnica de AVA](file:///home/david/5º/PrimerCuatri/DGP_MDA/AVA/README.md).