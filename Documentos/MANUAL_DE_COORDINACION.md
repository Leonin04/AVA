---
title: "Manual de Coordinación y Plan de Dirección"
subtitle: "Proyecto de Innovación Docente AUTOVIDA (26-175) — Reto CeRA"
author:
  - "David"
  - "Paula"
  - "Manu"
  - "Alberto"
  - "Adam"
date: "Curso Académico 2026-2027 — Grado en Ingeniería Informática (UGR)"
geometry: "top=1.7cm,bottom=1.7cm,left=2.0cm,right=2.0cm"
fontsize: "11pt"
lang: "es"
toc: false
numbersections: true
header-includes:
  - \usepackage{fancyhdr}
  - \pagestyle{fancy}
  - \fancyhead[L]{DGP \& MDA — Curso 2026-2027}
  - \fancyhead[R]{Manual de Coordinación}
  - \fancyfoot[C]{\thepage}
  - \usepackage{booktabs}
  - \usepackage{setspace}
  - \setstretch{1.14}
  - \setlength{\parskip}{0.35em}
  - \renewcommand{\arraystretch}{1.18}
  - \usepackage{titlesec}
  - \titlespacing*{\section}{0pt}{1.4ex plus .2ex minus .1ex}{0.7ex}
  - \titlespacing*{\subsection}{0pt}{1.1ex plus .2ex minus .1ex}{0.5ex}
---

# Introducción y Objeto del Proyecto

El presente **Manual de Coordinación y Plan de Dirección** establece el marco metodológico, organizativo, técnico y normativo que regirá el desarrollo del proyecto en las asignaturas **Dirección y Gestión de Proyectos (DGP)** y **Metodologías de Desarrollo Ágil (MDA)** de la Universidad de Granada durante el curso académico 2026-2027.

El proyecto se desarrolla bajo la metodología de **Aprendizaje-Servicio (ApS)** dentro de la iniciativa *“26-175. AUTOVIDA”*, en colaboración con el **Colegio de Educación Especial Fundación Purísima Concepción de Granada**. 

El objetivo primordial consiste en diseñar y construir una **aplicación móvil accesible y multiplataforma en Flutter y Firebase**, orientada a facilitar la estructuración del tiempo y la anticipación de tareas diarias a estudiantes con discapacidad intelectual del Programa de Transición a la Vida Adulta (PTVAL).

El equipo de trabajo está integrado por 5 miembros: **David**, **Paula**, **Manu**, **Alberto** y **Adam**.

---

# Metodología de Desarrollo y Ciclo de Vida

El equipo adopta un modelo ágil de **prototipado evolutivo basado en Scrum y Kanban**, estructurado en **tres iteraciones (sprints)** de 3 semanas y alineado con los principios y áreas focales del PMI (Inicio, Planificación, Ejecución, Control y Cierre).

\vspace{0.3cm}

| Fase / Iteración | Periodo | Objetivos y Entregables Clave |
|---|---|---|
| **Fase Inicial (P0-P2)** | 25 Sep - 22 Oct 2026 | Requisitos con cliente, Manual de Coordinación, Propuesta Técnica y Product Backlog. |
| **Iteración 1** | 22 Oct - 12 Nov 2026 | Arquitectura base Flutter/Firebase, login accesible, tareas personales y módulo Reprografía. |
| **Iteración 2** | 12 Nov - 03 Dic 2026 | Módulo Comedor (dietas/ausencias), Menú Mensual, temporizador visual y pictogramas ARASAAC. |
| **Iteración 3** | 03 Dic - 21 Dic 2026 | Módulo Embajadores (cámara QR y vídeos), soporte pulsadores, chat y pruebas de usabilidad. |
| **Defensa Final** | 12 Ene 2027 | Exposición oral del equipo y entrega del código final desplegable (.apk y web). |

\vspace{0.3cm}

### Rituales Ágiles de Trabajo
- **Sprint Planning:** Definición del objetivo de la iteración, estimación del esfuerzo y selección de tareas en Jira.
- **Reuniones de Sincronización (Daily):** Dos sesiones telemáticas breves semanales (10-15 minutos) y puesta en común presencial durante la clase de prácticas.
- **Sprint Review:** Demostración del prototipo funcional ante el profesor tutor y los responsables del centro.
- **Sprint Retrospective:** Análisis interno de fortalezas, problemas detectados y compromisos concretos de mejora.

---

# Recursos Software de Desarrollo

Para garantizar la homogeneidad y compatibilidad en los equipos de los 5 integrantes, se establece la siguiente pila tecnológica oficial:

### Framework Multiplataforma
- **Flutter 3.x con Dart 3.x:**
  - *Despliegue Móvil (Android):* Compilación de paquetes instalables `.apk` para su uso en tablets y dispositivos del colegio.
  - *Despliegue Web:* Versión accesible mediante navegador para que tutores y administradores gestionen el sistema desde ordenadores de escritorio.
  - *Diseño Universal:* Renderizado consistente, componentes accesibles con etiquetas `Semantics` y contrastes de color adaptados.

### Backend-as-a-Service (BaaS) y Datos
- **Google Firebase:**
  - *Cloud Firestore:* Base de datos NoSQL reactiva para actualización y sincronización de tareas en tiempo real.
  - *Firebase Authentication:* Inicio de sesión accesible adaptado a fotografías, colores o iconos gráficos.
  - *Firebase Storage:* Repositorio en la nube para audios explicativos grabados por tutores, fotos de tareas y vídeos de salas.
  - *Security Rules:* Control de acceso y permisos según el rol asignado (Administrador, Tutor escolar, Familia o Alumno).

### Plugins Clave del Proyecto
- `flutter_local_notifications`: Programación de alertas y avisos temporales en el sistema operativo.
- `mobile_scanner`: Lectura ágil de códigos QR mediante la cámara del dispositivo.
- `flutter_tts`: Síntesis de voz en español para facilitar la audiodescripción de tareas.
- `just_audio` y `video_player`: Reproducción fluida de notas de audio y vídeos explicativos.
- `cached_network_image`: Gestión de caché local de pictogramas de ARASAAC para funcionamiento sin conexión.

### Entorno y Herramientas de Gestión
- **Git / GitHub:** Control de versiones del código fuente y documentación.
- **Jira Software:** Gestión del tablero ágil, imputación de horas y seguimiento de incidencias.
- **Figma:** Prototipado y diseño de pantallas con verificación de contraste y accesibilidad.

---

# Organización del Equipo de Trabajo (Estructura y Normas)

## Asignación de Roles del Equipo (5 Miembros)

La estructura organizativa combina **dos roles fijos de especialización** con **roles rotatorios de gestión** por iteración:

- **Auditora de Usabilidad y Accesibilidad (Rol Fijo):** **Paula**. Responsable de velar por las directrices WCAG 2.1 AA, la integración de pictogramas de ARASAAC, la navegación con pulsadores y la redacción del informe final de accesibilidad.
- **Gestor de Calidad / QA (Rol Fijo):** **Alberto**. Responsable de diseñar la estrategia de pruebas automatizadas (`flutter_test`), asegurar el cumplimiento de la definición de hecho (*DoD*) y auditar la trazabilidad de requisitos.

\vspace{0.2cm}

| Iteración | Coordinadores (2 miembros) | Catalogador (Documentación) | Moderador | Presentador |
|---|---|---|---|---|
| **Fase Inicial & Iteración 1** | **David** & **Manu** | **Adam** | **Alberto** | **Paula** |
| **Iteración 2** | **Manu** & **Adam** | **David** | **Paula** | **Alberto** |
| **Iteración 3 & Cierre** | **Adam** & **David** | **Manu** | **Alberto** | **David** |

\vspace{0.2cm}

## Rotación de Funciones Técnicas
A lo largo del proyecto, los 5 miembros participarán de forma rotatoria en las distintas capas del desarrollo:
1. **Interfaz y Accesibilidad:** Pantallas para el estudiante (*una pantalla = una sola idea*), botones grandes de alto contraste, menús adaptados y temporizador visual.
2. **Lógica y Persistencia:** Modelos de datos en Dart, consultas a Firestore (gestión de dietas de comedor, reprografía), reglas de seguridad y almacenamiento.
3. **Hardware y Multimedia:** Notificaciones programadas, escáner de códigos QR, lectura por voz y reproducción de audios.
4. **Calidad y Despliegue:** Pruebas unitarias, pruebas de widgets y compilación de instaladores APK.

## Normas de Convivencia y Definición de Hecho (DoD)
- **Compromiso y Puntualidad:** Asistencia a sesiones de laboratorio y reuniones internas. Aviso con al menos 12 horas de antelación ante imprevistos justificados.
- **Transparencia:** Actualización diaria del estado de las tareas en Jira (*To Do*, *In Progress*, *In Review*, *Done*).
- **Apoyo Continuo:** Solicitud de asistencia y *pair programming* ante cualquier bloqueo técnico superior a 24 horas.
- **Definición de Hecho (DoD):** Para considerar finalizada una tarea, el código debe compilar sin advertencias en `flutter analyze`, superar las pruebas unitarias, contar con la revisión de código (*Code Review*) aprobada por un compañero y cumplir con los criterios de accesibilidad visual y semántica.

---

# Herramientas de Comunicación del Equipo

- **Discord (Servidor Oficial):** Canales de texto organizados por temáticas (`#general`, `#desarrollo-flutter`, `#servicios-firebase`) y canales de voz para reuniones de coordinación y programación conjunta.
- **WhatsApp:** Canal de contingencia reservado exclusivamente para avisos urgentes o incidencias de última hora.
- **Jira Software:** Registro individual y semanal de horas dedicadas, control de dependencias del sprint y seguimiento de tareas.
- **Google Drive / GitHub:** Repositorio centralizado para borradores de actas, grabaciones y documentos de entrega.

---

# Relaciones con el Cliente (Entrevistas, Reuniones y Revisiones)

- **Cliente y Peticionarios:** Colegio de Educación Especial Fundación Purísima Concepción (dirección, tutores del PTVAL y alumnado).
- **Canal de Interlocución:** La comunicación oficial es liderada por los **Coordinadores de la iteración vigente**, con el apoyo de la Auditora de Accesibilidad y el Gestor de Calidad en sesiones clave.
- **Hitos de Contacto:** Entrevista inicial de requisitos (25 Sep), visita técnica al centro (2 Oct), tutorías semanales en prácticas y pruebas intermedias de los prototipos con alumnos reales para evaluar la usabilidad y comprensión de los pictogramas.
- **Actas de Reunión:** El Catalogador elabora y archiva el acta de cada sesión en `/Documentos/Actas/` en un plazo máximo de 24 horas, recogiendo asistentes, acuerdos y tareas asignadas.

---

# Estándares de Documentación

- **Documentación Interna y Borradores:** Se utilizará formato **Markdown (`.md`)** en el repositorio Git para borradores preliminares, notas técnicas internas, diseño colaborativo rápido y actas de reuniones.
- **Entregables Oficiales al Cliente / Profesorado:** Todos los documentos formales de entrega (Manual de Coordinación, Propuesta Técnica, Memorias de Iteración e Informes de Usabilidad) se maquetarán y compilarán obligatoriamente en **LaTeX utilizando la plantilla/estilo Prism**, generando los correspondientes archivos **PDF** oficiales.
- **Nomenclatura Uniforme:** Ficheros descriptivos sin espacios (`Manual_Coordinacion.tex`, `Propuesta_Tecnica.tex`, `Acta_2026_10_22.md`).
- **Estructura Requerida:** Portada con código institucional (AUTOVIDA 26-175), nombres de los autores, historial de control de cambios, índice numerado y diagramas claros.

---

# Estándares de Código

- **Guía de Estilo Oficial:** Cumplimiento de las recomendaciones de *Effective Dart*, formateo automático mediante `dart format` y validación estática con `flutter analyze`.
- **Estructura Modular del Proyecto (`/lib`):**
  - `models/`: Clases inmutables con métodos de serialización Firestore (`fromMap`, `toMap`).
  - `services/`: Lógica de conexión con Firebase Auth, Firestore y Storage.
  - `screens/`: Vistas completas de la aplicación (alumno, tutor, administrador).
  - `widgets/`: Componentes accesibles reutilizables (`BotonAccesible`, `VisorPictograma`).
  - `utils/`: Paletas de color accesibles, constantes de diseño y soporte de voz.
- **Nomenclatura:** Ficheros en `snake_case`, clases y widgets en `UpperCamelCase`, métodos y variables en `lowerCamelCase`.
- **Conventional Commits:** Uso de prefijos normalizados en los mensajes de Git: `feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `test:`, `chore:`.

---

# Plan de Gestión de Cambios

1. **Registro:** Cualquier solicitud de cambio (del cliente o del equipo) se registrará formalmente como *Change Request* en Jira.
2. **Evaluación de Impacto:** En un plazo máximo de 48 horas, los Coordinadores y el Gestor de Calidad valorarán el impacto en el triángulo de restricciones:
   - *Tiempo:* Repercusión en la fecha de cierre de la iteración.
   - *Alcance:* Necesidad de posponer o eliminar historias de usuario planificadas.
   - *Accesibilidad:* Viabilidad y adecuación ergonómica al perfil de los alumnos.
3. **Decisión:** Modificaciones menores ($\le 4$ horas) son autorizadas por los coordinadores; cambios sustanciales se someten a votación del equipo completo.
4. **Preaviso Contractual:** Cualquier desviación que afecte a una entrega oficial se notificará con **3 días de antelación** al profesorado para evitar penalizaciones.

---

# Control de Versiones (Método y Ramas)

- **Repositorio Oficial:** Proyecto privado en GitHub (`Leonin04/DGP_MDA`) con integración continua (**GitHub Actions**) para ejecutar linters y pruebas automáticas.
- **Estrategia de Ramas:** `main` (versiones estables y APKs oficiales), `develop` (integración continua del sprint), `feature/<nombre>` (desarrollo de historias de usuario) y `fix/<nombre>` (resolución de incidencias).
- **Política de Pull Requests (PR):** Prohibido el push directo a `main` o `develop`. Cada PR exige la aprobación obligatoria de **al menos un compañero** y tests en verde antes de fusionar.

---

# Gestión de Calidad (Desarrollo y Pruebas)

- **Pruebas Automatizadas:** Tests con `flutter_test` sobre modelos, asignación de tareas y cálculo de dietas ($\ge 70\%$ cobertura en lógica), y pruebas de widgets validando propiedades semánticas (`Semantics`).
- **Auditoría de Accesibilidad:** Verificación con *Android Accessibility Scanner* garantizando áreas táctiles mínimas de **48x48 dp** y contrastes conformes a WCAG 2.1 AA ($\ge 4.5:1$ texto normal, $\ge 3:1$ botones grandes).
- **Validación con Usuarios:** Pruebas de usabilidad guiadas en el colegio con alumnos y tutores para evaluar la ergonomía y autonomía en el uso real.

---

# Medición del Desempeño y Recompensas

- **Registro de Horas:** Imputación individual en Jira (**6 a 8 horas semanales por miembro**). El Catalogador consolida el informe semanal de seguimiento para DGP.
- **Métricas y Reconocimiento:** Control de cumplimiento del *Sprint Backlog*, mención honorífica al *"MVP del Sprint"* en cada retrospectiva y celebración informal tras cada hito oficial.

---

# Formalización y Firma del Compromiso

Con la firma del presente documento, los 5 integrantes del equipo aprueban el contenido del **Manual de Coordinación y Plan de Dirección**, comprometiéndose a cumplir sus directrices éticas, metodológicas y técnicas durante el desarrollo del proyecto para el curso académico 2026-2027.

\vspace{0.6cm}

\noindent
\begin{tabular}{p{5cm}p{5.2cm}p{5cm}}
\textbf{David} & \textbf{Paula} & \textbf{Manu} \\
Coordinador / Dev & Auditora Accesibilidad / Dev & Coordinador / Dev \\
Firma: & Firma: & Firma: \\
\vspace{0.9cm} & \vspace{0.9cm} & \vspace{0.9cm} \\
\textbf{Alberto} & \textbf{Adam} & \\
Gestor Calidad / Dev & Catalogador / Dev & \\
Firma: & Firma: & \\
\end{tabular}

\vspace{0.4cm}
\begin{center}
\textbf{Granada, a 1 de octubre de 2026}
\end{center}
