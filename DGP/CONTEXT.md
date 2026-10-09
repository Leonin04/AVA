# CONTEXT.md — Base de Conocimiento del Proyecto
> **Proyecto:** Agenda Virtual Accesible — Reto CeRA  
> **Proyecto de Innovación Docente:** *26-175. Aprendizaje-servicio y Software Accesible para la Autonomía y la Transición a la Vida Adulta en Estudiantes NEAE (AUTOVIDA)*  
> **Asignaturas:** Dirección y Gestión de Proyectos (DGP) & Metodologías de Desarrollo Ágil (MDA)  
> **Titulación:** Grado en Ingeniería Informática — Universidad de Granada (UGR) — Curso 2026-2027  

---

## 1. El Equipo de Trabajo

El equipo está formado por **5 integrantes**:

- **David**
- **Paula**
- **Manu**
- **Alberto**
- **Adam**

### Estructura de Roles del Equipo
Para cumplir con los pliegos docentes (ajustado a nuestro equipo de 5 miembros):

| Tipo de Rol | Rol | Responsabilidades Principales | Asignación / Rotación |
|---|---|---|---|
| **Fijo** | **Auditor de Usabilidad y Accesibilidad** | Formación del equipo en pautas de accesibilidad (WCAG, diseño cognitivo, pictogramas), auditoría documental y validación técnica del software accesible. | No rota a lo largo del proyecto |
| **Fijo** | **Gestor de Calidad (QA)** | Formación y seguimiento de buenas prácticas de calidad del proceso y del producto, definición de criterios de aceptación y control de pruebas. | No rota a lo largo del proyecto |
| **Rotatorio** | **Coordinadores (2 miembros)** | Liderazgo de la iteración, interlocución con docentes/cliente, seguimiento diario del tablero y reparto de cargas. | Rotan cada iteración entre los miembros disponibles |
| **Rotatorio** | **Catalogador / Gestor Documental** | Organización del repositorio Git, nomenclaturas, control de versiones de documentación y actas de reuniones. | Rotativo por iteración |
| **Rotatorio** | **Moderador** | Gestión del tiempo en reuniones internas, orden del día y resolución de desacuerdos. | Rotativo por iteración |
| **Rotatorio** | **Presentador** | Exposición y defensa oral ante el profesorado o el cliente en las revisiones de iteración. | Rotativo por iteración |

### Rotación de Funciones Técnicas por Iteración
Los integrantes rotarán periódicamente entre las áreas clave:
1. **Especificación y Diseño:** Historias de usuario, bocetos UI accesible, modelado de arquitectura y BD.
2. **Implementación y Pruebas:** Desarrollo Frontend/Backend, accesibilidad, integración continua y testing.
3. **Planificación, Gestión y Documentación:** Métricas, estimaciones, control de horas, riesgos e informes.

---

## 2. Contexto Institucional y Metodología Docente

- **Metodología de Aprendizaje-Servicio (ApS):** Desarrollo de una solución software real con impacto social directo.
- **Cliente Real:** **Colegio de Educación Especial Fundación Purísima Concepción de Granada** (Fundación Hospitalarias).
- **Colaboraciones:** Interacción con docentes, familias y proyectos complementarios de logopedia con TIC.
- **Autoría:** Compartida al 50% entre los miembros del equipo y los peticionarios (profesorado/centro).
- **Garantía y Mantenimiento:** La licitación no contempla fase de mantenimiento tras la entrega final.

---

## 3. Propósito y Visión del Producto Software

### El Problema
Las personas con discapacidad intelectual y alumnado del **Programa de Transición a la Vida Adulta (PTVAL)** experimentan ansiedad, bloqueo e inseguridad cuando no pueden anticipar qué ocurrirá en su jornada o cuánto tiempo durará una actividad. Las soluciones comerciales existentes son complejas, poco accesibles o excesivamente rígidas y costosas de configurar para las familias y tutores.

### La Solución
Una **aplicación móvil accesible de agenda virtual personalizada** que:
- Permite **anticipar** las tareas del día y ver el paso del tiempo de forma visual e intuitiva.
- Proporciona **tranquilidad, calma, confianza y autonomía**.
- Es gestionada de forma colaborativa por el **estudiante**, sus **tutores docentes** y sus **familias**.

```
SIN ANTICIPACIÓN:
Incertidumbre ──> Ansiedad ──> Bloqueo / Rechazo ──> Dependencia continua

CON ANTICIPACIÓN:
Agenda visible ──> Previsibilidad temporal ──> Calma y Confianza ──> Autonomía y Seguridad
```

---

## 4. Requisitos y Funcionalidades Principales

### A. Tareas Específicas del Centro
1. **Reprografía:**
   - Flujo: Petición de un tutor de aula -> Asignación al alumno -> Recogida del material en aula -> Impresión/plastificado en el taller -> Devolución de copias y original al aula.
2. **Registro de Comedor:**
   - Flujo: El alumno recorre aula por aula registrando ausencias y dietas especiales (basal, hiposódica, triturada, celíaca, etc.) -> Generación y envío del listado consolidado a cocina.
3. **Reparto del Menú Mensual:**
   - Flujo: El alumno reparte los folletos del menú impreso aula por aula registrando cada entrega realizada.
4. **Embajadores del Centro (Guía de Visitas):**
   - Flujo: Alumnos guían a visitantes externos por los espacios del centro; la app escanea **códigos QR** en cada sala que abren **vídeos explicativos** sobre las actividades que allí se realizan.

### B. Tareas Personales y Cotidianas
- Creadas tanto por el alumno como por su tutor o familia (ej.: merienda, pádel, regar plantas, deberes).
- Programación de días de la semana, hora de inicio y fin.
- **Descripción accesible multiformato:** Texto sencillo, audio grabado, vídeo explicativo o **secuencia de pasos guiada**.
- Botones accesibles de **Iniciar** y **Finalizar** tarea/paso.
- **Temporizador visual adaptable:** Tiempo restante representado de forma visual y comprensible.

### C. Accesibilidad y Adaptabilidad de la Interfaz (UI/UX)
- **Regla de oro:** *Una pantalla, una sola idea. Botones grandes, muchas imágenes y texto mínimo.*
- **Perfiles personalizados:**
  - Login accesible (sin contraseñas complejas: selección por foto, colores o iconos).
  - Tipografía ajustable en tamaño y legibilidad.
  - Paletas de alto contraste y colores favoritos.
  - Doble sistema iconográfico: **Fotografías reales** y **pictogramas de ARASAAC**.
  - Modo de vista: Diario (*Hoy*) o Semanal.
- **Accesibilidad física y motora:** Compatibilidad con pulsadores y periféricos de asistencia.
- **Canal de comunicación / Chat accesible:** Mensajería simplificada entre tutor y estudiante para dudas y refuerzo positivo.
- **Historial de actividad:** Registro de tareas completadas, pendientes e incidencias.

---

## 5. Marco Metodológico y Estándares de Gestión (PMI / PMBOK)

El desarrollo del proyecto combina **Metodologías Ágiles (Scrum/Kanban)** con las directrices de dirección del **PMI**:

### Principios Fundamentales
1. **Visión Holística:** Entender el sistema completo y sus dependencias.
2. **Enfoque en el Valor:** Centrarse en la utilidad real para los alumnos y tutores.
3. **Calidad Integrada:** La calidad se asegura paso a paso, no en una revisión final.
4. **Liderazgo Responsable:** Ética, transparencia y compromiso del equipo.
5. **Sostenibilidad:** Viabilidad a nivel social, económico y técnico.
6. **Cultura Empoderada:** Autonomía y colaboración activa entre los 5 integrantes.

### Las 5 Áreas Focales y el Ciclo Ágil
- **Inicio:** Licitación, *Project Charter*, Manual de Coordinación y reparto de roles.
- **Planificación (Iterativa):** *Sprint Planning*, estimación de esfuerzo y desglose de tareas en Jira.
- **Ejecución:** Construcción de prototipos funcionales y código en Git.
- **Control:** Monitorización continua del tablero, reuniones diarias/semanales, control de riesgos y desviaciones temporales.
- **Cierre:** Retrospectivas por iteración y entrega final con lecciones aprendidas.

### Triángulo de Restricciones del Proyecto
- **Tiempo:** Plazos estrictos fijados en el calendario de la UGR.
- **Coste / Recursos:** Esfuerzo individual de los 5 integrantes (horas invertidas registradas).
- **Producto / Alcance:** Cumplimiento estricto de accesibilidad, seguridad y funcionalidad.
> *Cualquier cambio imprevisto en el alcance debe consensuarse y justificarse con al menos 3 días de antelación.*

---

## 6. Calendario de Hitos y Entregas (Curso 2026-2027)

> **Hora límite oficial de entrega:** **23:59 horas**.  
> **Fecha límite improrrogable del contrato:** **6 de Febrero de 2027**.

| Hito / Entrega | Fecha | Asignatura | Entregables Principales |
|---|---|---|---|
| **Entrevista inicial con el cliente** | 25 Sep 2026 (8:30h) | Ambas | Toma de contacto y levantamiento de requisitos. |
| **Inicio de prácticas en laboratorio** | 1–2 Oct 2026 | Ambas | Constitución de equipos y tecnología inicial. |
| **Visita guiada al centro** | 2 Oct 2026 | Ambas | Representantes de los equipos visitan el colegio. |
| **Entrega Inicial (P0–P2)** | **21–22 Oct 2026** | **DGP:** Manual de Coordinación, Propuesta Técnica, Horas, Actas.<br>**MDA:** Personajes y Escenarios, Visión del Producto, Product Backlog inicial. |
| **Iteración 1 (Desarrollo y entrega)** | **22 Oct – 12 Nov 2026** | Ambas | Primer prototipo funcional, plan de iteración, Jira, actas, revisión y retrospectiva. |
| **Iteración 2 (Desarrollo y entrega)** | **12 Nov – 3 Dic 2026** | Ambas | Segundo incremento funcional, evolución del tablero, actualización de riesgos y diseño. |
| **Iteración 3 (Desarrollo y entrega)** | **3 Dic – 21 Dic 2026** | Ambas | Incremento final, informe de usabilidad/accesibilidad, gestión de calidad, manual de usuario opcional. |
| **Presentación y Defensa Final** | **12 Ene 2027** *(Tarde)* | Ambas | Exposición oral del equipo completo (Día oficial del examen de DGP). |

---

## 7. Criterios de Evaluación y Calificación (75% de la Asignatura)

La nota de prácticas supone el **75% de la calificación final** de la asignatura, dividida en:

| Bloque | Peso | Componente Evaluado |
|---|---|---|
| **Documentación** | **25%** | Rigor, completitud, formato, trazabilidad y estándares (10% evaluado en la defensa final). |
| **Desarrollo Software** | **25%** | Calidad del código, cumplimiento de accesibilidad, pruebas y prototipos funcionales (10% en defensa). |
| **Organización del Equipo** | **25%** | Roles, cumplimiento de plazos, gestión en Jira/Git, actas, registro de horas y autovaloración (10% en defensa). |

---

## 8. Stack Tecnológico Oficial Acordado

- **Framework Multiplataforma Cliente:** **Flutter 3.x con Dart 3.x**.
  - Generación nativa de instaladores **Android (.apk)** para tablets y móviles del colegio.
  - Soporte **Flutter Web** para acceso de tutores y administración desde ordenadores de escritorio.
- **Backend-as-a-Service (BaaS) & Persistencia:** **Google Firebase**.
  - **Cloud Firestore:** Base de datos NoSQL en tiempo real para sincronización inmediata de tareas, dietas de comedor y estados.
  - **Firebase Authentication:** Login accesible para estudiantes (por fotos, colores o PIN simplificado).
  - **Firebase Storage:** Almacenamiento multimedia en la nube (fotografías de tareas, audios grabados por tutores y vídeos para los códigos QR).
  - **Firebase Security Rules:** Control granular de acceso por roles.
- **Librerías Clave de Flutter (pub.dev):**
  - `flutter_local_notifications`: Avisos y alarmas programadas en el sistema Android.
  - `mobile_scanner`: Escaneo fluido de códigos QR con la cámara trasera.
  - `flutter_tts`: Lectura por voz en español accesible para alumnos con dificultades de lectoescritura.
  - `just_audio` / `video_player`: Reproducción de audios de instrucciones y vídeos demostrativos.
  - `cached_network_image`: Caché de pictogramas de ARASAAC para uso offline.

---

### Estándar Oficial de Documentación
- **Borradores y Documentación Interna:** Formato **Markdown (`.md`)** en el repositorio Git para diseño ágil, notas técnicas colaborativas y actas de reuniones.
- **Entregables Oficiales al Cliente / Evaluación:** Formato **LaTeX utilizando la plantilla/estilo Prism**, generando los correspondientes archivos **PDF** oficiales maquetados profesionalmente.

### Entregables Oficiales del Equipo
- **[MANUAL_DE_COORDINACION.pdf](file:///home/david/5º/PrimerCuatri/DGP_MDA/Documentos/MANUAL_DE_COORDINACION.pdf):** Documento oficial cumplimentado y maquetado en PDF (6 páginas exactas, maquetación equilibrada y legible) con la arquitectura oficial **Flutter + Firebase**, listo para entrega y firma de los 5 integrantes.
- **[MANUAL_DE_COORDINACION.md](file:///home/david/5º/PrimerCuatri/DGP_MDA/Documentos/MANUAL_DE_COORDINACION.md):** Código fuente en Markdown del Manual de Coordinación y Plan de Dirección (versión borrador/fuente interna).

### Documentos Teóricos y Pliegos de Referencia
Disponibles en [DocumentosTeoria](file:///home/david/5º/PrimerCuatri/DGP_MDA/DocumentosTeoria):
1. [MANUAL DE COORDINACIÓN.md](file:///home/david/5º/PrimerCuatri/DGP_MDA/DocumentosTeoria/MANUAL%20DE%20COORDINACI%C3%93N.md): Plantilla base original.
2. [guionGeneralPracticas_2627.md](file:///home/david/5º/PrimerCuatri/DGP_MDA/DocumentosTeoria/guionGeneralPracticas_2627.md): Normativa académica, entregas y calendario.
3. [Pliego_Técnico_2627 (1).md](file:///home/david/5º/PrimerCuatri/DGP_MDA/DocumentosTeoria/Pliego_T%C3%A9cnico_2627%20%281%29.md): Pliego técnico formal y anexo funcional.
4. [APPS AGENDA VIRTUAL  (1).md](file:///home/david/5º/PrimerCuatri/DGP_MDA/DocumentosTeoria/APPS%20AGENDA%20VIRTUAL%20%20%281%29.md): Reto CeRA, psicología del usuario y diseño UI/UX.
5. [Tema1_Conceptos.md](file:///home/david/5º/PrimerCuatri/DGP_MDA/DocumentosTeoria/Tema1_Conceptos.md): Teoría tema 1 (proyectos, roles, stakeholders, PMI).
6. [Tema2_Principios_Areas_Dominios.md](file:///home/david/5º/PrimerCuatri/DGP_MDA/DocumentosTeoria/Tema2_Principios_Areas_Dominios.md): Teoría tema 2 (principios, dominios y áreas PMI).

