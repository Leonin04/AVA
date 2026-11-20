# AUTOVIDA — Agenda Virtual Accesible (AVA)

[![Asignatura](https://img.shields.io/badge/Asignaturas-DGP%20%7C%20MDA-blue.svg)](DocumentosTeoria/)
[![Universidad](https://img.shields.io/badge/Universidad-Granada%20(UGR)-red.svg)](https://www.ugr.es)
[![Curso](https://img.shields.io/badge/Curso-2026--2027-green.svg)](#)
[![Framework](https://img.shields.io/badge/Framework-Flutter-02569B?logo=flutter&logoColor=white)](AVA/)
[![Backend](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=black)](#)
[![Tests](https://img.shields.io/badge/Tests-92%20passed-brightgreen.svg)](#)
[![Iteración](https://img.shields.io/badge/Iteración%201-Completada%20(37%20SP)-success.svg)](#)

Repositorio central del proyecto **AUTOVIDA (código 26-175)**, desarrollado de forma coordinada para las asignaturas **Dirección y Gestión de Proyectos (DGP)** y **Metodologías de Desarrollo Ágil (MDA)** del Grado en Ingeniería Informática de la **Universidad de Granada**.

El proyecto consiste en el diseño, especificación y desarrollo de **AVA (Agenda Virtual Accesible)**, una aplicación multiplataforma (Web y tabletas Android/iOS) destinada al **Colegio de Educación Especial (CEE) Fundación Purísima Concepción** de Granada, enfocada en fomentar la autonomía y organización del alumnado del **Programa de Transición a la Vida Adulta (PTVAL)**.

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
.
├── DocumentosTeoria/             # 📚 Documentación formal de la entrega inicial
│   ├── DGP0.md                   # Manual de coordinación, propuesta técnica, actas y horas
│   ├── DGP0.pdf                  # PDF original de DGP
│   ├── MDA0.md                   # Fichas de persona DCU, escenarios, Product Backlog (31 HUs)
│   ├── MDA0.pdf                  # PDF original de MDA
│   └── img/                      # Figuras, avatares de personas y capturas extraídas
│
├── AVA/                          # 📱 Código fuente de la aplicación Flutter
│   ├── assets/                   # Pictogramas ARASAAC, sonidos de refuerzo, iconos y fuentes
│   │   ├── fuentes/              # Tipografía Atkinson Hyperlegible
│   │   ├── iconos/               # Logo oficial AVA, sol y elementos de apoyo visual
│   │   ├── pictogramas/          # Pictogramas de ARASAAC precargados
│   │   └── sonidos/              # Refuerzos sonoros positivos y melodías
│   ├── lib/
│   │   ├── main.dart             # Punto de entrada de la aplicación
│   │   ├── app/                  # Aplicación, rutas por rol y datos simulados de pruebas
│   │   ├── dev/                  # Carga de datos de prueba en Firebase
│   │   ├── core/                 # Elementos transversales (constantes, temas, servicios, widgets)
│   │   └── features/             # Módulos funcionales desacoplados (Feature-First)
│   ├── test/                     # 92 pruebas automáticas (unitarias, widgets y accesibilidad)
│   ├── database/                 # Especificación de esquema Cloud Firestore v2 y reglas
│   ├── ACCESIBILIDAD.md          # Pautas WCAG 2.2 AA, W3C COGA y matriz de cobertura HU
│   ├── INTEGRACION_FIREBASE.md   # Conexión arquitectura-repositorios con Cloud Firestore
│   ├── TAREAS_Y_AGENDA.md        # Especificación de pantallas y lógica de tareas y agenda
│   ├── pubspec.yaml              # Dependencias del proyecto (Firebase, ARASAAC, Provider, etc.)
│   ├── analysis_options.yaml     # Reglas de calidad y linting (flutter_lints)
│   └── README.md                 # Guía técnica de desarrollo y arquitectura de la app
│
├── plan_iteracion_1.md           # Plan de trabajo, cronograma y entregables de la Iteración 1
└── README.md                     # Este archivo (visión global del repositorio)
```

---

## 🎯 Estado Actual: Iteración 1 Completada (Incremento 1 y Prototipo Funcional)

La **Iteración 1 (Sprint 1)** ha concluido con éxito, completando los **37 Puntos de Historia (SP)** planificados en el Product Backlog. Se ha implementado el **prototipo funcional completo** conectado a backend Cloud Firebase y validado con una batería de pruebas automatizadas.

Para mantener el código rigurosamente modular y sin elementos distractores, la carpeta de desarrollo (`AVA/lib/features/`) contiene los **5 módulos funcionales** correspondientes al alcance de esta primera entrega, abarcando **17 Historias de Usuario**:

> **Nota sobre la numeración de Historias de Usuario:** El equipo utiliza la numeración unificada reflejada en `AVA/ACCESIBILIDAD.md`, `AVA/database/README.md` y en la memoria técnica. En dicha numeración, la gestión de cuentas de `MDA0.md` se dividió en creación (HU-01) y edición (HU-02), por lo que a partir de HU-02 cada historia tiene una unidad más que en el documento inicial `MDA0.md`.

1. 🔐 **`autenticacion`:** Creación de cuentas, roles de usuario, login accesible adaptado para estudiantes (PIN numérico, clave por pictogramas, contraseña o color), login de administración y tutoría (correo y contraseña), recuperación de contraseña y cierre de sesión (**HU-01, HU-02, HU-03, HU-09, HU-18**).
2. 👤 **`perfil`:** Configuración de apoyos de accesibilidad del alumno (pictogramas ARASAAC, imágenes reales, colores pastel de fondo con contraste garantizado, tamaño de texto y tipografía Atkinson Hyperlegible, botón de voz, filtro antitemblor) y ficha completa de estudiante con intereses, necesidades y apoyos que le calman (**HU-15, HU-19**).
3. 📅 **`agenda`:** Vistas de agenda diaria y semanal, anticipación visual temporal en formato accesible «Ahora / Después» y registro de inicio y fin de actividad con confirmación y refuerzo positivo (**HU-10, HU-11, HU-12**).
4. 📋 **`tareas`:** Gestión integral de tareas personales y encargos rotativos del colegio (reprografía, comedor, visitas), horarios con validación temporal, apoyos paso a paso con imágenes/pictogramas e instrucciones reordenables (**HU-04, HU-05, HU-06, HU-07, HU-08**).
5. 🏫 **`aulas`:** Administración de aulas, asignación de docentes/tutores responsables y restricción estricta de visibilidad de estudiantes por tutor asignado (**HU-16, HU-17**).

---

## 🧪 Calidad del Software y Batería de Pruebas

El repositorio cuenta con una cobertura integral de **92 pruebas automáticas superadas** (`flutter test`), estructuradas en:

- **Pruebas unitarias y de dominio:** Validación de modelos inmutables, repositorios, cálculo temporal de agenda (`CalculosAgenda`), resolución de recursos visuales y control de permisos por rol.
- **Pruebas de lógica y controladores:** Flujo de autenticación accesible por pictogramas y PIN, validación de formularios de tareas y gestión de preferencias.
- **Pruebas de widgets e interfaz:** Renderizado de barras de navegación accesibles centradas con logo oficial, paneles de administración, cuadrículas autoajustables sin desbordamiento ni scroll involuntario.
- **Pruebas de accesibilidad:** Verificación estricta de contraste cromático WCAG 2.2 AA (≥ 4.5:1 / ≥ 7:1 en fondos pastel), tamaños de objetivo táctil (≥ 64 px), soporte de navegación con pulsador/teclado y etiquetas semánticas (`Semantics`) para lectores de pantalla.
- **Análisis estático:** Código 100% libre de advertencias con `flutter analyze` conforme a las reglas oficiales de `flutter_lints` y *Effective Dart*.

---

## 🔌 Arquitectura Modular: Preparada para Futuras Iteraciones

El proyecto está diseñado bajo una arquitectura **Feature-First (Modular) en 3 capas** (`dominio/`, `logica/`, `presentacion/`), desacoplada mediante el patrón repositorio y contratos abstractos. 

Esto asegura la extensibilidad para los siguientes sprints sin alterar el código ya consolidado:
- **Iteración 2:** Incorporación de `lib/features/comedor/` (registro de comensales, dietas y listado de cocina) y `lib/features/seguimiento/` (monitorización en tiempo real y alertas para tutores), ampliando el módulo de tareas con temporizadores visuales y avisos previos (HU-13, HU-14, HU-20 a HU-22).
- **Iteración 3:** Integración modular de coordinación con el entorno familiar/hogar y chat accesible condicionado.

---

## 🛠 Tecnologías Principales

- **Framework:** [Flutter](https://flutter.dev) (Dart 3) orientado a tabletas Android, iOS y navegadores Web.
- **Backend Cloud:** [Firebase](https://firebase.google.com) (Authentication con cuentas anónimas y correo, Cloud Firestore v2 en multirregión europea `eur3`, Cloud Storage y reglas de seguridad granulares).
- **Recursos de Accesibilidad:** Integración con la API y catálogo de [ARASAAC](https://arasaac.org) (licencia CC BY-NC-SA) y tipografía de baja visión [Atkinson Hyperlegible](https://brailleinstitute.org/freefont).
- **Gestión Ágil y Calidad:** Jira Software (tablero Scrum, estimación en Story Points y burndown), GitHub (flujo de ramas `feature/*` e integración continua) y `flutter_lints`.

---

## 🚀 Inicio Rápido para Desarrolladores

### 1. Requisitos previos
- Flutter SDK (versión 3.x o superior) con Dart habilitado.
- Google Chrome (para ejecución web) o emulador/tableta Android o iPad.

### 2. Puesta en marcha

```bash
# 1. Acceder a la carpeta del proyecto Flutter
cd AVA

# 2. Descargar e instalar las dependencias
flutter pub get

# 3. Comprobar la calidad del código mediante análisis estático
flutter analyze

# 4. Ejecutar la suite completa de pruebas automáticas (92 pruebas)
flutter test

# 5. Ejecutar la aplicación en modo Web (recomendado para desarrollo rápido)
flutter run -d chrome

# O bien ejecutar en emulador/dispositivo móvil:
flutter run
```

### 3. Cuentas de acceso para pruebas

| Rol | Correo / Identificador | Método de acceso | Credencial |
|---|---|---|---|
| **Administrador** | `admin.ava@gmail.com` | Correo y contraseña | `AVAadmin` |
| **Tutora del centro** | `tutora.ava@ava-pruebas.test` | Correo y contraseña | `AVAtutor` |
| **Familiar** | `familia.ava@ava-pruebas.test` | Correo y contraseña | `AVAfamilia` |
| **Alumno Pablo (1º A)** | Selección de tarjeta | PIN numérico | `1234` |
| **Alumna Marta (1º A)** | Selección de tarjeta | Pictogramas ARASAAC | Sol ☀️ $\rightarrow$ Perro 🐶 $\rightarrow$ Flor 🌸 |
| **Alumna Lucía (1º B)** | Selección de tarjeta | Contraseña | `lucia123` |
| **Alumno Javier (1º B)** | Selección de tarjeta | PIN numérico | `4321` |

Para más detalles técnicos sobre el esquema de datos, las reglas de Firestore o la arquitectura de pantallas, consulta:
- [Guía Técnica de la Aplicación (AVA/README.md)](AVA/README.md)
- [Esquema de Base de Datos y Reglas (AVA/database/README.md)](AVA/database/README.md)
- [Pautas de Accesibilidad y Cobertura (AVA/ACCESIBILIDAD.md)](AVA/ACCESIBILIDAD.md)
- [Conexión con Firebase y Repositorios (AVA/INTEGRACION_FIREBASE.md)](AVA/INTEGRACION_FIREBASE.md)
