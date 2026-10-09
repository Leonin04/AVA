# CONTEXT.md — Base de Conocimiento de Metodologías de Desarrollo Ágil (MDA)

> **Asignatura:** Metodologías de Desarrollo Ágil (MDA) — Grado en Ingeniería Informática (Universidad de Granada)  
> **Curso Académico:** 2026-2027  
> **Proyecto:** Agenda Virtual Accesible — Reto CeRA  
> **Proyecto de Innovación Docente:** *26-175. Aprendizaje-servicio y Software Accesible para la Autonomía y la Transición a la Vida Adulta en Estudiantes NEAE (AUTOVIDA)*  
> **Cliente / Entorno Real:** Colegio de Educación Especial Fundación Purísima Concepción de Granada (Fundación Hospitalarias)  
> **Asignatura Hermana / Coordinada:** Dirección y Gestión de Proyectos (DGP)

---

## 1. El Equipo de Trabajo

El equipo de trabajo está compuesto por **5 integrantes**:
- **David**
- **Paula**
- **Manu**
- **Alberto**
- **Adam**

### Estructura de Roles del Equipo (Según Pliego Técnico y Normativa de Prácticas)
| Tipo de Rol | Rol | Responsabilidades en MDA | Asignación / Dinámica |
|---|---|---|---|
| **Fijo** | **Auditor de Usabilidad y Accesibilidad** | Planificar y asegurar la usabilidad y accesibilidad del sistema. Diseñar pautas de diseño cognitivo, pictogramas (ARASAAC), contraste, tamaños y adaptación a movilidad reducida (pulsadores). Validar prototipos con usuarios (DCU). | Fijo durante todo el proyecto (no rota) |
| **Fijo** | **Gestor de Calidad (QA)** | Asegurar la calidad del proceso de desarrollo ágil y de los productos software. Supervisar la definición de hecho (*Definition of Done*), criterios de aceptación de Historias de Usuario y planes de pruebas. | Fijo durante todo el proyecto (no rota) |
| **Rotatorio** | **Coordinadores (2 miembros)** | Liderazgo del Sprint, interlocución con profesorado/cliente, seguimiento diario del tablero (Jira) y dinamización del equipo de trabajo. | Rota en cada iteración |
| **Rotatorio** | **Catalogador / Gestor Documental** | Mantener y clasificar la información y repositorios del proyecto (Git, Google Drive, Jira). Control de versiones de los artefactos de diseño, actas y entregables. | Rota en cada iteración |
| **Rotatorio** | **Moderador** | Guiar y moderar las reuniones ágiles (*Daily*, *Sprint Planning*, *Sprint Review*, *Sprint Retrospective*), gestionar turnos y consensuar decisiones grupales. | Rota en cada iteración |
| **Rotatorio** | **Presentador** | Elaborar y presentar los resúmenes, prototipos e incrementos software ante el cliente y el profesorado en las revisiones de iteración y defensas. | Rota en cada iteración |

### Rotación de Funciones Técnicas por Iteración
Los miembros rotan en cada iteración entre:
1. **Especificación y Diseño:** Modelado de Personas, Escenarios, redacción de Historias de Usuario (HU), diseño de prototipos UI/UX accesibles (wireframes/mockups).
2. **Implementación y Pruebas:** Desarrollo de software (Frontend móvil con Flutter, Backend con Firebase), pruebas unitarias, de integración y validaciones de accesibilidad.
3. **Planificación, Gestión y Documentación:** Mantenimiento del Product Backlog, tableros Jira, métricas de velocidad, actas e informes de retrospectiva.

---

## 2. Marco Metodológico Ágil (MDA)

La asignatura implementa un ciclo de vida de **desarrollo ágil iterativo e incremental** basado en:
- **Prototipado evolutivo en 3 Iteraciones (Sprints):** Cada iteración produce un incremento funcional probado y demostrable.
- **Diseño Centrado en el Usuario (DCU):** Análisis continuo de necesidades de alumnos NEAE, familias y tutores, con validación temprana de prototipos.
- **Técnicas Ágiles Clave:**
  - **Personas y Escenarios:** Caracterización de usuarios prioritarios y descripción contextualizada de su experiencia de interacción.
  - **Visión del Producto (*Elevator Pitch*):** Resumen de valor claro, conciso y diferenciador (formato de Geoffrey Moore).
  - **Product Backlog:** Pila de producto priorizada compuesta por Historias de Usuario con estimación de esfuerzo y criterios de aceptación verificables.
  - **Sprint Planning, Review y Retrospectiva:** Planificación detallada del Sprint, demostración del incremento al cliente y reflexión interna sobre procesos para la mejora continua.
  - **Gestión Visual del Flujo de Trabajo:** Tableros Scrum/Kanban en **Jira** vinculados al repositorio Git.

---

## 3. Propósito, Visión y Reto del Producto Software

### El Reto CeRA y la Necesidad Psicológica
La aplicación responde a la necesidad de estructurar el tiempo y anticipar rutinas a estudiantes con discapacidad intelectual del **Programa de Transición a la Vida Adulta (PTVAL)**:
- **Sin anticipación:** Incertidumbre $\rightarrow$ Ansiedad $\rightarrow$ Bloqueo o rechazo $\rightarrow$ Dependencia continua del tutor.
- **Con anticipación:** Agenda visible $\rightarrow$ Previsibilidad temporal $\rightarrow$ Calma y confianza $\rightarrow$ Autonomía personal y seguridad.

### Formato Oficial de Visión del Producto (Elevator Pitch — Geoffrey Moore)
- **Para:** Estudiantes con discapacidad cognitiva del centro PTVAL, sus tutores docentes y familias.
- **Qué:** Necesitan anticipar sus rutinas diarias, estructurar el paso del tiempo y ejecutar tareas con autonomía sin sufrir ansiedad o bloqueos.
- **El:** *(Nombre comercial del producto / Agenda CeRA)*
- **Es una:** Aplicación móvil accesible de agenda virtual interactiva y personalizada.
- **Que proporciona:** Una interfaz ultra-simplificada con pictogramas ARASAAC, fotografías reales, guiado paso a paso, temporizador visual y avisos adaptados.
- **A diferencia de:** Las agendas convencionales o aplicaciones comerciales existentes (rígidas, complejas cognitivamente, sin adaptación motora y de configuración costosa para tutores).
- **Nuestro producto:** Ofrece máxima personalización por perfil (login accesible, soporte para pulsadores físicos, chat tutor-alumno de refuerzo y gestión combinada de tareas escolares y del hogar).

---

## 4. Requisitos y Funcionalidades del Sistema

### A. Tareas Específicas del Centro
1. **Reprografía:**
   - *Flujo en 3 pasos:* 1) Recoger material de un aula $\rightarrow$ 2) Acudir al taller para fotocopiar/imprimir/plastificar $\rightarrow$ 3) Repartir el material original y las copias de vuelta al aula.
   - *Gestión:* Petición originada por un tutor de aula; asignación al alumno realizada por el encargado de reprografía o el administrador.
2. **Registro de Comedor:**
   - *Flujo:* El estudiante asignado recorre todas las aulas anotando quién se queda al comedor y su tipo de dieta (basal, hiposódica, triturada, celíaca/sin gluten, etc.).
   - *Gestión:* La app genera automáticamente el listado consolidado para el personal de cocina. Asignación diaria por el administrador.
3. **Reparto de Menú Mensual:**
   - *Flujo:* El estudiante reparte a cada alumno de cada aula el folleto impreso del menú mensual del centro, registrando en la app cada entrega realizada.
   - *Gestión:* Asignación mensual por el administrador.
4. **Guía de Visita (Embajadores del Centro):**
   - *Flujo:* Uno o varios estudiantes actúan como embajadores ante visitas externas. Mediante la cámara escanean **códigos QR** ubicados en los distintos espacios del colegio para reproducir **vídeos explicativos** sobre las actividades que allí se realizan.
   - *Gestión:* Asignación bajo demanda por el administrador.

### B. Tareas Personales y Cotidianas
- **Creación:** Pueden ser creadas por el tutor escolar, la familia (padres) o el propio estudiante.
- **Campos:** Nombre de la tarea, imagen representativa, hora de inicio/fin y días de repetición semanal.
- **Descripción Multiformato Accesible:** Texto en lectura fácil, audio explicativo grabado, vídeo demostrativo o **secuencia guiada de pasos**.
- **Control de Ejecución:** Botones accesibles para marcar *Inicio* y *Finalización* (tanto de la tarea general como de cada subtarea/paso individual).
- **Reloj Visual Accesible:** Temporizador visual configurable (fijo u opcional según el perfil del usuario) que representa el paso del tiempo de forma intuitiva.
- **Ejemplos cotidianos:** Preparar la merienda, jugar al pádel, regar plantas, hacer deberes, aseo personal.

### C. Perfiles de Usuario y Accesibilidad Cognitiva / Física (UI/UX)
- **Regla de oro de diseño:** *Una pantalla, una sola idea. Botones grandes, texto mínimo, alto apoyo visual mediante imágenes y navegación predictiva.*
- **Perfiles personalizados:**
  - Login accesible adaptado (selección de fotografía, colores o código PIN simplificado, eliminando contraseñas alfanuméricas complejas).
  - Configuración estética individual: paleta de colores preferida, fuentes tipográficas accesibles, tamaño de letra, disposición de menús y botones.
  - Soporte iconográfico dual: **Fotografías reales** de entornos y personas conocidas + **pictogramas de ARASAAC**.
  - Modalidad de vista temporal: Vista diaria (*"Hoy"*) o vista semanal.
  - Capacidad de auto-edición de preferencias para alumnos con mayor grado de autonomía.
- **Roles en la plataforma:**
  - *Administrador:* Alta y gestión de tutores y estudiantes; asignación de tareas del centro.
  - *Tutor (Escolar o Familiar):* Configuración y ajuste continuo del perfil de sus estudiantes, asignación de tareas personales y consulta de estadísticas de progreso.
  - *Estudiante:* Consulta visual de su agenda, confirmación de tareas e interacción sencilla.
- **Chat Accesible:** Canal de comunicación tutor-estudiante para mensajes de ayuda, avisos urgentes y refuerzo emocional.
- **Accesibilidad Física y Motora:** Compatibilidad con periféricos adaptados y pulsadores para alumnado con movilidad reducida.

---

## 5. Arquitectura y Stack Tecnológico Acordado

Para garantizar compatibilidad móvil inmediata en el centro escolar y accesibilidad de gestión web para los tutores:

```
┌─────────────────────────────────────────────────────────────┐
│                 CAPA CLIENTE MULTIPLATAFORMA                │
│            Flutter 3.x (Dart 3.x) — Android (.apk) & Web    │
│  - Interfaz accesible (ARASAAC, audios, fotos)              │
│  - Escaneo QR (mobile_scanner) | Síntesis de voz (TTS)      │
│  - Notificaciones locales (flutter_local_notifications)     │
└──────────────────────────────┬──────────────────────────────┘
                               │ HTTPS / WebSockets
┌──────────────────────────────▼──────────────────────────────┐
│             BACKEND-AS-A-SERVICE (Google Firebase)          │
│  - Cloud Firestore: Base de datos NoSQL reactiva            │
│  - Firebase Auth: Autenticación por perfiles accesibles     │
│  - Firebase Storage: Multimedia (fotos, audios, vídeos)     │
│  - Firebase Security Rules: Control de acceso por roles     │
└─────────────────────────────────────────────────────────────┘
```

- **Frontend:** **Flutter 3.x** con Dart 3.x.
  - Generación de `.apk` nativo para tablets y smartphones Android del colegio.
  - Despliegue Flutter Web para paneles de administración y configuración de tutores.
- **Backend / Cloud:** **Google Firebase**.
  - *Cloud Firestore:* Sincronización en tiempo real de estados de tareas, dietas de comedor y perfiles.
  - *Firebase Authentication:* Mecanismos de login adaptados.
  - *Firebase Storage:* Repositorio en la nube para recursos multimedia (fotos de alumnos/aulas, audios de tutores, vídeos de QR).
- **Librerías principales:**
  - `mobile_scanner`: Lector de códigos QR rápido y accesible.
  - `flutter_tts`: Lectura de textos mediante voz artificial en castellano.
  - `flutter_local_notifications`: Avisos visuales y sonoros al expirar tiempos de tarea.
  - `just_audio` / `video_player`: Reproducción fluida de contenidos multimedia.
  - `cached_network_image`: Caché local de pictogramas para permitir funcionamiento sin conexión.

---

## 6. Guía Detallada de Prácticas de MDA

### Práctica 0: Descripción del Problema y Organización del Grupo
- **Duración:** 1 semana (desde semana del 28 de septiembre de 2026).
- **Objetivos:**
  - Análisis del pliego técnico y planteamiento del problema (agenda accesible PTVAL).
  - Constitución oficial del equipo de 5 integrantes.
  - Asignación formal de roles (Auditor de Usabilidad, Gestor de Calidad, Coordinadores, Catalogador, Moderador, Presentador).
  - Configuración de entornos de trabajo compartidos (repositorio Git, Jira, almacenamiento en la nube).
- **Entrega oficial:** Documento con la lista de asignación de roles del equipo (vía Prado antes de iniciar la Práctica 2).

### Práctica 1: Personas y Escenarios. Visión del Producto
- **Duración:** 1 semana (desde semana del 28 de septiembre de 2026).
- **Objetivos:**
  1. **Técnica de Personas (Modelo Teórico Seminario 1):** Definir los usuarios prioritarios del sistema incluyendo rigurosamente los **12 campos canónicos de la teoría** (*ver [InformacionPlantillaPersona.jpeg](file:///home/david/5º/PrimerCuatri/DGP_MDA/MDA/DocumentosTeoria/InformacionPlantillaPersona.jpeg)*):
     - **1. Demographic characteristics:** Age, gender, location, socio-economic status.
     - **2. Occupation experience:** Current job title, years at the company, years of experience at that position, responsibilities, previous jobs and job titles.
     - **3. Company information:** Company size, industry.
     - **4. Education:** Degree, major, courses taken.
     - **5. Computer experience:** Computer skills, years of experience.
     - **6. Specific product experience:** Experience with competitors' products or other domain-specific products, usage trends.
     - **7. Tasks:** Primary tasks, secondary tasks.
     - **8. Domain knowledge:** The users' understanding of the product area.
     - **9. Technology available:** Computer hardware (monitor size, computing speed, etc.), software, other tools typically used.
     - **10. Attitudes and values:** Product preferences, fear of technology, etc.
     - **11. Learning style:** Visual learner, audio learner, etc.
     - **12. Criticality of errors:** Possible consequences of a user's error.
     - *Plantilla oficial generada:* [plantilla_persona.tex](file:///home/david/5º/PrimerCuatri/DGP_MDA/MDA/Realizables/plantilla_persona.tex) y compilada en [plantilla_persona.pdf](file:///home/david/5º/PrimerCuatri/DGP_MDA/MDA/Realizables/plantilla_persona.pdf).
  2. **Técnica de Escenarios:** Describir situaciones representativas de uso que evidencien el contexto, los problemas reales a resolver y los objetivos de los usuarios (no listas mecánicas de pasos de UI, sino valor y vivencia real).
  3. **Visión del Producto (*Elevator Pitch*):** Redactar la declaración de visión del sistema siguiendo estrictamente la plantilla de Geoffrey Moore (*Para... qué... el... es un... que proporciona... a diferencia de... nuestro producto...*).
- **Entrega oficial:** Conjunto de plantillas Persona + Escenarios de uso + Elevator Pitch (Fecha límite: 22–23 de octubre de 2026 en Prado).

### Práctica 2: Plan de Entregas y Product Backlog
- **Objetivos:**
  - Creación de la pila de producto (**Product Backlog**) completa con Historias de Usuario formateadas (*"Como [rol], quiero [funcionalidad] para [beneficio]"*).
  - Definición de criterios de aceptación verificables y escenarios BDD (*Given-When-Then*).
  - Estimación de esfuerzo relativo (puntos de historia) y priorización por valor aportado.
  - **Plan de entregas (Release Plan):** Distribución de Historias de Usuario entre las tres iteraciones previstas.
- **Entrega oficial:** Documento del Plan de Entregas y Product Backlog inicial (Fecha límite: 21–22 de octubre de 2026).

---

## 7. Calendario Oficial de Hitos y Entregas (Curso 2026-2027)

> **Regla de entrega:** Todas las entregas se realizan telemáticamente a través de **Prado** hasta las **23:59 horas** de la fecha indicada.  
> **Fecha límite improrrogable del contrato:** **6 de Febrero de 2027**.

| Fase / Hito | Fechas Oficiales | Entregables Clave de MDA |
|---|---|---|
| **Toma de contacto con cliente** | 25 Sep 2026 (8:30h) | Asistencia a entrevista inicial en clase de teoría de MDA. |
| **Comienzo prácticas laboratorio** | 1–2 Oct 2026 | Constitución del equipo de 5 personas y arranque de P0/P1. |
| **Visita guiada al Colegio** | 2 Oct 2026 | Observación in situ de espacios, talleres y alumnado por representantes. |
| **Entrega Inicial (P0, P1, P2)** | **21–22 Octubre 2026** | • Plantillas Persona de usuarios prioritarios.<br>• Plantillas de Escenarios de uso contextualizados.<br>• Visión del Producto (*Elevator Pitch*).<br>• Plan de entregas y *Product Backlog* inicial.<br>• Asignación de roles del equipo de trabajo. |
| **Iteración 1 (Sprint 1)** | **Inicio:** 22–23 Octubre 2026<br>**Entrega:** **11–12 Noviembre 2026** | • Documento de Plan de Iteración 1.<br>• Evolución del tablero (capturas y métricas de Jira).<br>• Enlace al proyecto Jira activo.<br>• Bocetos UI/UX y wireframes accesibles (enlace a Figma).<br>• Informes de reuniones de Sprint Review y Sprint Retrospective.<br>• Incremento software funcional básico (código en Git). |
| **Iteración 2 (Sprint 2)** | **Inicio:** 12–13 Noviembre 2026<br>**Entrega:** **2–3 Diciembre 2026** | • Documento de Plan de Iteración 2.<br>• Tablero Jira actualizado y seguimiento de velocidad.<br>• Evolución de bocetos y prototipos validados con usuarios.<br>• Informes de revisión y retrospectiva del Sprint 2.<br>• Segundo incremento funcional del software (módulos integrados). |
| **Iteración 3 (Sprint 3)** | **Inicio:** 3–4 Diciembre 2026<br>**Entrega:** **21 Diciembre 2026** | • Documento de Plan de Iteración 3.<br>• Cierre de tablero y métricas finales.<br>• Informes de revisión y retrospectiva final.<br>• Incremento de software final integrado y desplegable. |
| **Defensa y Presentación Final** | **12 Enero 2027** *(Tarde)* | • Documento de presentación del proyecto completo (diapositivas).<br>• Exposición y defensa oral de todo el equipo ante el tribunal. |

---

## 8. Criterios de Evaluación y Calificación en MDA

La parte práctica representa el **75% de la calificación final** de la asignatura (0 a 10 puntos), distribuida equitativamente:

| Bloque Evaluado | Peso Relativo | Aspectos Evaluados en MDA |
|---|---|---|
| **Documentación** | **25%** | Rigor formal, completitud de Personas y Escenarios, calidad del Product Backlog, criterios de aceptación, actas de retrospectiva e informes de Sprint (un 10% se computa en la defensa final). |
| **Desarrollo Software** | **25%** | Calidad del código en Git, modularidad, integración continua, usabilidad, estricto cumplimiento de accesibilidad y funcionamiento real de los incrementos en cada Sprint (un 10% en defensa final). |
| **Organización del Equipo** | **25%** | Ejercicio efectivo de los roles asignados, gestión activa del tablero en Jira, cumplimiento estricto de fechas límite, registro de dedicación y autovaloración reflexiva del grupo (un 10% en defensa final). |

> **Penalizaciones:** Los retrasos no justificados con al menos 3 días de antelación conllevan deducciones directas de la nota. El profesorado se reserva la potestad de modular la calificación individual según el desempeño observado en las sesiones de laboratorio.

---

## 9. Convenciones de Documentación y Artefactos

- **Borradores y Trabajo Colaborativo:** Formato **Markdown (`.md`)** en la carpeta `MDA/Realizables/` para iterar con rapidez, versionar con Git y servir de base de conocimiento.
- **Entregas Formales al Profesorado:** Documentos finales en **PDF** (maquetados con LaTeX o Markdown a PDF cuidando tipografía, márgenes y presentación ejecutiva) en la carpeta `MDA/Entregables/`.
- **Nomenclaturas recomendadas:**
  - `MDA_P0_Roles_[Equipo].pdf`
  - `MDA_P1_Personas_Escenarios_Vision_[Equipo].pdf`
  - `MDA_P2_Product_Backlog_Plan_Entregas_[Equipo].pdf`
  - `MDA_Iteracion[N]_Memoria_[Equipo].pdf`

---

## 10. Referencias Directas a Documentos Teóricos de la Carpeta

Para consultas de detalle, consultar los archivos originales en [MDA/DocumentosTeoria](file:///home/david/5º/PrimerCuatri/DGP_MDA/MDA/DocumentosTeoria):
- [Practica0.md](file:///home/david/5º/PrimerCuatri/DGP_MDA/MDA/DocumentosTeoria/Practica0.md): Guion completo de la Práctica 0 (definición del problema, tareas, roles y entregas).
- [Practica1.md](file:///home/david/5º/PrimerCuatri/DGP_MDA/MDA/DocumentosTeoria/Practica1.md): Guion completo de la Práctica 1 (Personas, Escenarios, Elevator Pitch y recomendaciones).
- [InformacionPlantillaPersona.jpeg](file:///home/david/5º/PrimerCuatri/DGP_MDA/MDA/DocumentosTeoria/InformacionPlantillaPersona.jpeg): Esquema de los 12 atributos canónicos de Persona según la teoría de MDA (Seminario 1).
- [guionGeneralPracticas_2627.md](file:///home/david/5º/PrimerCuatri/DGP_MDA/MDA/DocumentosTeoria/guionGeneralPracticas_2627.md): Normativa académica marco, calendario y matriz de entregables DGP vs. MDA.
- [Pliego_Técnico_2627 (1).md](file:///home/david/5º/PrimerCuatri/DGP_MDA/MDA/DocumentosTeoria/Pliego_T%C3%A9cnico_2627%20%281%29.md): Pliego técnico formal de la licitación y especificación del sistema software accesible.
