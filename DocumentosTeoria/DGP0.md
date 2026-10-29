# DGP1_Jueves 8,30_5 — Documentación inicial

![Portada](./img/DGP0_p1_1.jpeg)

**Asignatura:** Dirección y Gestión de Proyectos (DGP)  
**Grupo:** DGP1_Jueves 8,30_5  
**Fecha de entrega:** 29 de octubre de 2026  

### Equipo de trabajo
- **David Bacas Posadas**
- **Adam Ben Chacha**
- **Paula Cobos González**
- **Manuel José Fernández Poyatos**
- **Alberto David Gómez Gijón**
- **Daniel Viloria Prieto**

---

## Índice

1. [Manual de coordinación](#1-manual-de-coordinación) (pág. 2)
2. [Propuesta técnica](#2-propuesta-técnica) (pág. 10)
3. [Propuesta de solución](#3-propuesta-de-solución) (pág. 23)
4. [Registro de horas](#4-registro-de-horas) (pág. 26)
5. [Actas de reuniones](#5-actas-de-reuniones) (pág. 28)

---

## 1 Manual de coordinación

### 1.1 Propósito y alcance
Este manual establece una referencia común para organizar el trabajo, coordinar al equipo y revisar el avance del proyecto. Reúne la metodología, las herramientas y los criterios de calidad y evaluación descritos para el equipo.

Todas las personas del equipo han revisado este manual. Su firma en el apartado de aprobación indica que lo aceptan y se comprometen a cumplirlo. Cualquier cambio posterior se tramitará según el plan de gestión de cambios (apartado 1.8).

### 1.2 Metodología de desarrollo y ciclo de vida
El proyecto seguirá la metodología **Scrum** y utilizará Jira como soporte para la planificación y el seguimiento. El trabajo se organizará en iteraciones; al comienzo de cada una se identificarán las tareas previstas y, al cierre, se contrastará lo planificado con lo completado.

El tablero permitirá consultar el estado de los tickets y visualizar el trabajo pendiente mediante un gráfico burndown. La revisión de cada iteración se realizará en la retrospectiva, junto con la evaluación de las métricas recogidas en este documento.

El ciclo de vida es **iterativo e incremental (prototipado evolutivo)**: el proyecto se divide en tres sprints, que coinciden con las iteraciones de la asignatura, y en cada uno se entrega un incremento funcional del producto sobre la base del trabajo anterior.

#### Fases e hitos del proyecto

| Fase | Inicio | Entrega |
| --- | --- | --- |
| Entrega inicial | 25/09/2026 (entrevista) | 21–22/10/2026 |
| Sprint 1 | 22/10/2026 | 11–12/11/2026 |
| Sprint 2 | 12/11/2026 | 2–3/12/2026 |
| Sprint 3 | 3/12/2026 | 21/12/2026 |
| Presentación final | — | 12/01/2027 (tarde) |


### 1.3 Recursos de software
Para el desarrollo, gestión y documentación del proyecto se emplearán los siguientes recursos:

| Recurso | Uso previsto en el proyecto |
|---|---|
| **Flutter (Dart)** | Desarrollo de la aplicación para Android e iOS. |
| **Visual Studio Code** | Editor de código, con las extensiones de Flutter y Dart. |
| **Android Studio** | SDK de Android y emulador para probar en tabletas. |
| **Firebase** | Autenticación (Authentication), almacenamiento de imágenes, audio y vídeo (Cloud Storage) y notificaciones (Cloud Messaging). |
| **Cloud Firestore** | Base de datos de perfiles, tareas, preferencias y progreso, alojada en una región de la Unión Europea. |
| **API de ARASAAC** | Búsqueda y descarga de pictogramas. |
| **Jira** | Tablero Scrum, backlog y gráfico burndown. |
| **GitHub** | Repositorio de código y control de versiones. |
| **LaTeX** | Documentación entregable. |

### 1.4 Organización del equipo de trabajo
El trabajo del equipo se distribuye en dos dimensiones complementarias: cada integrante asume un rol organizativo para el funcionamiento del grupo y una función técnica en el desarrollo del software.

Para que todas las personas conozcan las distintas responsabilidades del proyecto, los roles organizativos rotan entre iteraciones según la primera matriz, y las funciones técnicas rotan entre las áreas técnicas según la segunda matriz.

#### 1.4.1. Rotación de roles organizativos
La asignación de los roles organizativos para cada iteración es la siguiente:

| Miembro | Iteración 1 | Iteración 2 | Iteración 3 |
| --- | --- | --- | --- |
| David | Coordinador | Presentador | Moderador |
| Alberto | Catalogador | Coordinador | Presentador |
| Manu | Moderador | Catalogador | Coordinador |
| Daniel | Presentador | Moderador | Catalogador |
| Paula | Usabilidad / Accesibilidad | Usabilidad / Accesibilidad | Usabilidad / Accesibilidad |
| Adam | Calidad | Calidad | Calidad |


#### 1.4.2. Responsabilidades de los roles
Las responsabilidades asociadas a cada rol permiten que la coordinación y el seguimiento de cada iteración tengan responsables claros:

- **Coordinador:** organiza el trabajo de la iteración, revisa el avance general en Jira y ayuda al equipo a resolver o comunicar impedimentos.
- **Catalogador:** redacta las actas, registra acuerdos y decisiones, y mantiene la trazabilidad de los cambios y de la documentación de seguimiento.
- **Presentador:** prepara y expone el trabajo completado al cierre de la iteración, destacando los resultados y las tareas que continúan pendientes.
- **Moderador:** facilita las reuniones, ayuda a seguir los temas previstos y procura que todas las personas puedan participar.
- **Usabilidad / Accesibilidad:** revisa la facilidad de uso y la accesibilidad de la aplicación, registra observaciones y propone mejoras.
- **Calidad:** da seguimiento a las pruebas, incidencias y comprobaciones de estándares antes de integrar cambios.

#### 1.4.3. Rotación de funciones técnicas
En cada iteración, los integrantes rotan entre Planificación y Documentación, Implementación y Pruebas, y Especificación y Diseño. La persona asignada lidera el trabajo de su área y coordina sus entregables con el resto del equipo.

| Miembro | Iteración 1 | Iteración 2 | Iteración 3 |
| --- | --- | --- | --- |
| David | Planificación y Doc. | Implementación y Pruebas | Especificación y Diseño |
| Alberto | Planificación y Doc. | Especificación y Diseño | Implementación y Pruebas |
| Manu | Especificación y Diseño | Planificación y Doc. | Implementación y Pruebas |
| Daniel | Especificación y Diseño | Implementación y Pruebas | Planificación y Doc. |
| Paula | Implementación y Pruebas | Especificación y Diseño | Planificación y Doc. |
| Adam | Implementación y Pruebas | Planificación y Doc. | Especificación y Diseño |


Las tres áreas técnicas tienen los siguientes alcances principales:
- **Especificación y Diseño:** organiza y aclara las necesidades recogidas, define el comportamiento esperado y documenta las decisiones de diseño necesarias para iniciar el desarrollo.
- **Planificación y Documentación:** prepara y actualiza la planificación de tareas, registra estimaciones y resultados, y mantiene al día la documentación del proyecto.
- **Implementación y Pruebas:** desarrolla las tareas asignadas, ejecuta las pruebas pertinentes y registra los defectos y su resolución.

#### 1.4.4. Traspaso entre iteraciones
Al cierre de cada iteración, las personas responsables dejarán actualizados en Jira el estado de sus tareas, los resultados obtenidos y los asuntos pendientes. El Catalogador recogerá los acuerdos en el acta y el Coordinador comprobará que el equipo entrante pueda continuar el trabajo con la información disponible. En la siguiente iteración se revisará el tablero y se confirmará la nueva asignación de roles y funciones técnicas.

### 1.5 Comunicación y relación con el cliente

#### 1.5.1. Comunicación del equipo
El equipo dispone de los siguientes canales de comunicación:
- **WhatsApp:** avisos rápidos y coordinación del equipo.
- **Discord:** trabajo conjunto y resolución de dudas.
- **Google Meet:** reuniones de coordinación por videoconferencia.

#### 1.5.2. Relación con el cliente
El cliente es la dirección del Colegio de Educación Especial de la Fundación Purísima Concepción. El profesorado realiza el seguimiento académico y sirve como cauce para trasladar consultas, sin sustituir la validación del Colegio. La relación se organiza así:
- **Entrevistas y visitas:** entrevista inicial (25/09/2026) y visita al centro (02/10/2026) para recoger requisitos. No se prevén nuevos encuentros con el Colegio antes de la presentación final; las dudas se agruparán y canalizarán a través del profesorado.
- **Seguimiento semanal:** reunión con el profesor en la sesión de prácticas.
- **Revisiones:** demostración del incremento al profesor al final de cada iteración y presentación final al Colegio.
- **Registro:** cada reunión tiene un acta redactada por el Catalogador, y los acuerdos se trasladan a tickets de Jira.

### 1.6 Estándares de documentación
Se utilizará la herramienta adecuada según el tipo de documentación:
- **Markdown:** notas y documentación de apoyo asociadas al control de versiones y al trabajo con Git.
- **LaTeX:** elaboración de la documentación final.
- **Generador de Dart (dart doc):** genera documentación HTML de referencia para las bibliotecas públicas del proyecto a partir de sus comentarios de documentación.

La documentación debe mantenerse comprensible y coherente con la versión del proyecto a la que hace referencia.

### 1.7 Estándares de código

#### 1.7.1. Nombres e idioma
Todo el código —incluidos nombres de variables, funciones, clases y mensajes de commit— se redactará en español. Para facilitar la lectura y mantener una convención uniforme, se aplicarán las reglas de la guía *Effective Dart*:
- **Variables, funciones y constantes:** `lowerCamelCase`.
- **Clases y componentes:** `UpperCamelCase` (PascalCase).
- **Archivos y carpetas:** `snake_case` (por ejemplo, `pantalla_agenda.dart`).

#### 1.7.2. Organización del código
El código se estructurará siguiendo el patrón BLoC o Provider para separar la lógica de negocio de la interfaz de usuario. Las carpetas principales serán:
- `lib/models/`: modelos de datos.
- `lib/views/` o `lib/screens/`: pantallas y componentes visuales.
- `lib/controllers/` o `lib/blocs/`: lógica y gestión de estado.
- `lib/services/`: acceso a Firebase y servicios externos.

#### 1.7.3. Ramas en GitHub
Cada rama de funcionalidad se nombrará con el prefijo `feature/` seguido de la clave del ticket en Jira y una descripción breve en minúsculas y separada por guiones:
`feature/<ticket_jira>-<descripcion>`

### 1.8 Plan de gestión de cambios
Los cambios se gestionarán de manera que el equipo pueda valorar su impacto, aprobarlos y conservar un registro de las decisiones tomadas.

#### 1.8.1. Causas y propuesta
Los cambios se limitarán a imprevistos técnicos, problemas de dependencias, ajustes de estimaciones temporales, peticiones del cliente o a la necesidad de reducir alcance secundario para cumplir los plazos de entrega de una iteración. Cualquier integrante que detecte la necesidad de modificar una tarea o la arquitectura planteará la propuesta en el canal oficial o en una reunión de coordinación.

#### 1.8.2. Análisis y aprobación
Antes de aceptar una modificación se evaluará su impacto en las horas de trabajo y en la fecha límite de la iteración. La decisión se tomará por consenso del equipo, bajo la supervisión del Coordinador. Si el cambio aumenta la carga de trabajo, el equipo acordará qué tarea de menor prioridad posponer o retirar del backlog. Si un cambio retrasa un plazo intermedio, se comunicará y justificará al profesorado con al menos tres días de antelación, como exige el pliego.

#### 1.8.3. Registro y trazabilidad
Toda modificación aprobada quedará reflejada en los registros del proyecto:
1. El ticket correspondiente en el tablero de Jira.
2. El acta de la reunión, redactada por el Catalogador.
3. El informe de seguimiento de la iteración, con la planificación prevista y el resultado real.

### 1.9 Control de versiones
El código se gestionará con Git en un repositorio de GitHub, y la planificación de tareas en Jira, para no duplicar tableros. Se seguirá este flujo:
- **Rama `main`:** versión estable que se entrega al final de cada iteración.
- **Rama `develop`:** integración del trabajo de la iteración.
- **Ramas `feature/<ticket_jira>-<descripcion>`:** una por historia o tarea.
- Cada cambio entra mediante **pull request**, revisada por al menos otra persona del equipo y con los tests superados.

### 1.10 Gestión de calidad
La calidad se revisará durante el desarrollo y al final del proyecto mediante pruebas y comprobaciones de accesibilidad. Las herramientas indicadas son:
- **Flutter Test:** pruebas unitarias, de widgets y de integración sobre la aplicación.
- **Comprobaciones de accesibilidad de flutter_test (`meetsGuideline`):** tamaño mínimo de los botones, contraste y etiquetas.
- **Accessibility Scanner (Android), TalkBack y VoiceOver:** revisión manual de la accesibilidad en tabletas.
- **WCAG 2.1 nivel AA:** referencia para la revisión, junto con la lista de comprobación de la asignatura.

Además, antes de cada pull request se comprobará que el código cumple los estándares con el analizador de Dart y las reglas de `flutter_lints`. Las incidencias detectadas durante las pruebas se registrarán junto con su tiempo medio de resolución.

### 1.11 Protección de datos
La aplicación tratará datos de menores y de personas con discapacidad, por lo que se cumplirán el RGPD y la LOPDGDD desde el diseño:
- Solo se recogerán los datos necesarios para cada funcionalidad (minimización).
- Firestore y Cloud Storage se alojarán en una región de la Unión Europea.
- El acceso se limitará por perfil mediante las reglas de seguridad de Firebase.
- Se recogerá el consentimiento de los tutores legales y se podrá ejercer el derecho de supresión.
- En las pruebas se usarán datos ficticios, nunca datos reales del alumnado.

### 1.12 Medición del desempeño y recompensas

#### 1.12.1. Desempeño individual
- **Registro y balance de horas:** Cada integrante registrará semanalmente sus horas de dedicación. Se vigilará una distribución equitativa de la carga, con un objetivo de desviación máxima de ±15 % respecto a la media del grupo; si se supera, se revisará el reparto de trabajo teniendo en cuenta la disponibilidad y las tareas asumidas.
- **Eficacia en las tareas:** Se calculará la proporción de tareas completadas frente a las asignadas al inicio de la iteración.
- **Desempeño del rol:** Se revisará el cumplimiento de las responsabilidades asignadas en cada iteración, como mantener las actas al día, revisar la calidad o coordinar el trabajo.

#### 1.12.2. Desempeño del proyecto
- **Desviación de esfuerzo:** comparación entre las horas reales y las horas estimadas para analizar las diferencias entre la planificación y la ejecución.
- **Cumplimiento del alcance:** porcentaje de tickets planificados en Jira que llegan al estado *Done* antes de la fecha límite de entrega (23:59 h).
- **Evolución del trabajo:** seguimiento del trabajo pendiente a través del gráfico burndown de Jira.

#### 1.12.3. Evaluación y seguimiento
Al cierre de cada una de las tres iteraciones, las métricas se revisarán en la reunión de retrospectiva. El Coordinador y el Gestor de Calidad elaborarán un resumen breve del desempeño, que se incorporará a la documentación de seguimiento y control de la iteración.

#### 1.12.4. Recompensas
Las recompensas serán no monetarias y estarán orientadas a reconocer tanto los resultados como las conductas que favorecen la calidad y la colaboración. Al cierre de cada iteración, el Coordinador y el Gestor de Calidad revisarán los indicadores individuales y del proyecto para proponer reconocimientos de manera transparente y equilibrada.
- **Reconocimiento de contribuciones:** destacar en la retrospectiva los logros concretos, la calidad del trabajo y el cumplimiento responsable de las tareas y del rol.
- **Intercambio de conocimientos:** ofrecer a quien haya aportado una solución útil la oportunidad de compartirla con el equipo mediante una breve demostración o explicación.
- **Reconocimiento colectivo:** valorar los logros alcanzados por el equipo en conjunto, especialmente cuando dependan de la colaboración y el apoyo entre integrantes.

La valoración tendrá en cuenta el contexto y la complejidad de las tareas; no se basará únicamente en el número de tickets completados ni en las horas registradas. Los reconocimientos y sus motivos podrán anotarse en el resumen de la retrospectiva. No se establecen premios económicos.

### 1.13 Aprobación del manual
Con su firma, las personas integrantes del equipo declaran haber revisado este manual y aceptar las pautas de coordinación aquí descritas:

| Miembro | Firma |
|---|---|
| David Bacas Posadas | *(Firmado)* |
| Adam Ben Chacha | *(Firmado)* |
| Paula Cobos González | *(Firmado)* |
| Manuel José Fernández Poyatos | *(Firmado)* |
| Alberto David Gómez Gijón | *(Firmado)* |
| Daniel Viloria Prieto | *(Firmado)* |

---

## 2 Propuesta técnica

### 2.1 Datos generales de la propuesta
- **Título de la propuesta:** Solución para la agenda móvil del Colegio Purísima Concepción de Granada.
- **Identificador del equipo:** DGP1_Jueves 8,30_5.
- **Integrantes:** David Bacas Posadas, Adam Ben Chacha, Paula Cobos González, Manuel José Fernández Poyatos, Alberto David Gómez Gijón y Daniel Viloria Prieto.
- **Destinatario:** Dirección y equipo docente del Colegio de Educación Especial de la Fundación Purísima Concepción (Granada).
- **Asignatura:** Dirección y Gestión de Proyectos (Grado en Ingeniería Informática, UGR).
- **Fecha de entrega:** 29 de octubre de 2026.

### 2.2 Problema y oportunidad

#### 2.2.1. Descripción del problema
El alumnado del Programa de Transición a la Vida Adulta (PTVAL) del Colegio Purísima Concepción necesita una herramienta accesible que le ayude a organizar sus actividades diarias —tanto tareas personales como encargos del centro— y a ejecutarlas con el mayor grado de autonomía posible.

En la actualidad se emplean agendas en papel y paneles visuales que requieren un esfuerzo continuo de actualización y no permiten la adaptación dinámica a las necesidades de cada estudiante ni la comunicación en tiempo real con los tutores.

#### 2.2.2. Antecedentes del equipo
El equipo está formado por seis estudiantes de cuarto curso del Grado en Ingeniería Informática. Sus conocimientos previos relacionados con el proyecto son:

| Miembro | Experiencia y conocimientos |
| --- | --- |
| David Bacas Posadas | Ha cursado las asignaturas de la rama de Ingeniería del Software del grado, incluidas las de análisis, diseño y pruebas de software, y ha realizado cursos extracurriculares de desarrollo web. |
| Adam Ben Chacha | Ha cursado las asignaturas de la rama de Ingeniería del Software del grado y ha participado en actividades y cursos extracurriculares relacionados con la creación de páginas web. |
| Paula Cobos González | Ha cursado las asignaturas de la rama de Ingeniería del Software del grado, con especial interés en el diseño de interfaces, y ha realizado cursos extracurriculares de desarrollo web. |
| Manuel José Fernández Poyatos | Ha cursado las asignaturas de la rama de Ingeniería del Software del grado y ha completado cursos extracurriculares sobre creación de páginas y aplicaciones web. |
| Alberto David Gómez Gijón | Ha cursado las asignaturas de la rama de Ingeniería del Software del grado y ha participado en actividades extracurriculares relacionadas con el desarrollo web y Flutter. |
| Daniel Viloria Prieto | Ha cursado las asignaturas de la rama de Ingeniería del Software del grado y ha realizado cursos y actividades extracurriculares relacionados con Flutter y la creación de aplicaciones web. |


#### 2.2.3. Factibilidad y viabilidad
- **Factibilidad técnica:** El equipo cuenta con experiencia previa en Flutter, desarrollo web y bases de datos NoSQL como Firestore. Además, existen recursos accesibles y APIs probadas como ARASAAC.
- **Factibilidad operativa:** La solución encaja en las rutinas actuales del centro escolar, facilitando la labor docente y la coordinación con las familias.
- **Viabilidad económica y legal:** La solución se basa en tecnologías abiertas y gratuitas para el ámbito educativo, cumpliendo estrictamente con el RGPD y la normativa de protección de datos de menores.

#### 2.2.4. Cliente real y contexto
El cliente real es la dirección del Colegio de Educación Especial de la Fundación Purísima Concepción, en Granada. El anexo del pliego propone desarrollar una aplicación a partir de las necesidades recogidas en las visitas y entrevistas iniciales con el centro, validando los prototipos e incrementos con el profesorado y el cliente.

#### 2.2.5. Justificación: soluciones existentes
Hemos revisado aplicaciones de agenda visual dirigidas a personas con discapacidad intelectual, TEA o TDAH:

| Aplicación | Plataforma | Español | Limitaciones para nuestro caso |
| --- | --- | --- | --- |
| Tiimo | Dispositivos Apple y web | Sí | Orientada a TDAH en adultos; texto e IA, sin pictogramas ARASAAC ni un rol de tutor que gestione a varios estudiantes. |
| Choiceworks | iPad y iPhone | Sí | Solo iOS; agendas y temporizadores visuales en un único dispositivo, sin seguimiento remoto del tutor ni tareas del centro. |
| First Then Visual Schedule | iPhone | No | Solo en inglés y sin actualizar desde 2012. |
| Pictogram- Agenda | Android e iOS | Sí | Usa ARASAAC y tiene modo alumno, pero las secuencias se guardan en un solo dispositivo: no hay cuentas por rol, avisos al tutor ni gestión de aulas. |


### 2.3 Objetivos del proyecto

#### 2.3.1. Objetivo general
Desarrollar una aplicación móvil accesible para tableta que permita al alumnado del PTVAL del Colegio Purísima Concepción consultar, seguir y registrar sus actividades diarias con apoyos adaptados, y proporcione a los tutores y administradores herramientas de gestión y seguimiento.

#### 2.3.2. Objetivos específicos
- **Adaptar la agenda:** ofrecer las preferencias de visualización previstas en el pliego y hacer configurable la consulta diaria o semanal y la representación del paso del tiempo.
- **Dar seguimiento al progreso:** proporcionar a la persona tutora una consulta del estado y avance de las tareas del estudiante vinculado a su perfil.
- **Verificar la accesibilidad:** evaluar los flujos desde los puntos de vista cognitivo y motriz, usar WCAG 2.1 nivel AA como referencia de evaluación y registrar resultados, incidencias y correcciones.
- **Proteger la información:** definir los datos que se tratarán, documentar permisos por perfil y medidas de protección, y comprobar su adecuación a la normativa de protección de datos aplicable.
- **Completar el trabajo de forma iterativa:** planificar y revisar tres iteraciones, dejando un incremento y documentación de seguimiento verificables al cierre de cada una.

### 2.4 Solución técnica

#### 2.4.1. Descripción de la solución
Se propone una aplicación para tabletas (Android e iOS) desarrollada con Flutter para ayudar a estudiantes del Programa de Transición a la Vida Adulta (PTVAL) a organizar su agenda y realizar tareas personales y actividades del centro con apoyos adaptados. La solución se diseñará teniendo en cuenta las necesidades de accesibilidad cognitiva y motriz descritas en el pliego y recogidas en la entrevista con el cliente.

#### 2.4.2. Arquitectura y componentes (Esquema lógico)

```
Administración                Tutoría               Estudiante
      │                          │                       │
      └──────────────────────────┼───────────────────────┘
                                 ▼
           Aplicación para tabletas Flutter (Android e iOS)
         Agenda, perfiles, tareas, instrucciones y seguimiento
                                 ↕
                       Servicios de Firebase
             Authentication | Cloud Storage | Cloud Messaging
                                 ↕
                    Cloud Firestore (región UE)
              Perfiles, tareas, preferencias y progreso
                                 ↕
              API de ARASAAC: búsqueda de pictogramas
```

*Visual Studio Code y Android Studio se emplearán como entorno de desarrollo; no forman parte de los componentes de ejecución.*

#### 2.4.3. Requisitos funcionales (RF)

| ID | Requisito |
| --- | --- |
| RF-01 | El administrador puede crear, editar y eliminar las cuentas de tutores y estudiantes. |
| RF-02 | Los tutores y el administrador pueden iniciar sesión con usuario y contraseña, y recuperar la contraseña si la olvidan. |
| RF-03 | El inicio de sesión del estudiante se adapta a su perfil y puede realizarse, por ejemplo, mediante un PIN, un pictograma o una contraseña. |
| RF-04 | El administrador puede asignar y desasignar uno o varios tutores a cada estudiante, incluidos tutores del centro y familiares. |
| RF-05 | El administrador puede crear, editar y eliminar aulas, y asignarles estudiantes y un tutor responsable. |
| RF-06 | Cada tutor solo puede consultar y gestionar la información de los estudiantes que tiene asignados. |
| RF-07 | Cada estudiante tiene un perfil configurable con su nombre, lugar de residencia, fotografía y datos importantes, como aquello que le calma o lo que necesita en su día a día. |
| RF-08 | El perfil permite configurar las preferencias de comunicación, como pictogramas, imágenes reales, texto, sonido, voz y botones grandes. |
| RF-09 | El perfil permite configurar las preferencias visuales: colores, tipografía, tamaño de letra y posición de menús y botones. |
| RF-10 | El perfil almacena los intereses del estudiante. |
| RF-11 | El tutor o el administrador puede modificar el perfil según el progreso del estudiante. |
| RF-12 | El tutor decide si cada estudiante puede modificar sus propias preferencias. El tutor o un familiar también puede modificarlas. |
| RF-13 | El tutor puede buscar pictogramas en ARASAAC y subir imágenes o fotografías propias para utilizarlas en tareas y perfiles; el profesorado del centro puede utilizarlas también en el chat con el estudiante. |
| RF-14 | El tutor o un familiar puede grabar su voz para utilizarla en avisos y descripciones de tareas. |
| RF-15 | El tutor puede crear, editar y eliminar tareas, indicando nombre, pictograma, descripción, tipo, horario, días de la semana y pasos. |
| RF-16 | Una tarea puede asignarse a uno o varios estudiantes, o a toda un aula. |
| RF-17 | Las tareas pueden repetirse los días de la semana indicados, sin tener que crearlas cada día. |
| RF-18 | El tutor o el estudiante pueden crear tareas personales. Solo el tutor del centro puede crear tareas del colegio. |
| RF-19 | Cada tarea puede incluir una descripción en formato accesible, como texto, audio, vídeo o una secuencia de imágenes. |
| RF-20 | El sistema permite definir cómo se realiza una tarea mediante una «ruta»; por ejemplo, primero se recoge el material y después se va al taller. |
| RF-21 | Si una tarea tiene pasos, se muestra una secuencia y se indica progresivamente el avance. |
| RF-22 | El estudiante puede consultar un horario con las tareas del día. |
| RF-23 | El estudiante puede consultar las tareas de la semana. |
| RF-24 | La agenda cubre todo el día, desde que el estudiante se levanta hasta que se acuesta, e incluye también las tareas de casa. |
| RF-25 | El sistema envía avisos antes de cada tarea y permite configurar cuándo se reciben. |
| RF-26 | El estudiante puede confirmar el inicio y la finalización de cada tarea. |
| RF-27 | Durante una tarea, se puede mostrar u ocultar un reloj temporizador accesible. |
| RF-28 | La aplicación muestra un mensaje de refuerzo positivo cuando el estudiante completa una tarea. |
| RF-29 | La aplicación ofrece guías paso a paso para realizar tareas domésticas. |
| RF-30 | La aplicación ofrece soporte para el tiempo de autorregulación, vinculado a los elementos que calman al estudiante y que constan en su perfil. |
| RF-31 | La aplicación permite gestionar actividades de ocio, como ir al cine o hacer deporte, y sugiere actividades según los intereses del estudiante. |
| RF-32 | La aplicación permite gestionar tareas de tipo profesional complementario. |
| RF-33 | El tutor puede consultar el progreso del estudiante y confirmar la finalización de las tareas que este haya completado. |
| RF-34 | La aplicación mantiene un historial de tareas completadas, organizado por día y semana, para facilitar el seguimiento. |
| RF-35 | El tutor recibe un aviso si el estudiante no inicia o no finaliza una tarea en el tiempo previsto. |
| RF-36 | La aplicación ofrece un chat accesible exclusivamente entre el profesorado del centro y el estudiante. |
| RF-37 | El chat se adapta a las necesidades del estudiante y puede utilizar, por ejemplo, audio o pictogramas. |
| RF-38 | El profesor o tutor del centro recibe un aviso cuando el estudiante le escribe por el chat. |
| RF-39 | El tutor puede gestionar el listado diario de comedor de su aula, indicando qué estudiantes comen y el tipo de comida de cada uno. |
| RF-40 | La aplicación ofrece recordatorios meteorológicos cuando no sea recomendable salir al exterior, según la ubicación del colegio o el lugar de residencia del estudiante. |
| RF-41 | La aplicación envía alertas de actividad sísmica e incluye el protocolo correspondiente, proporcionado por el colegio. |
| RF-42 | La aplicación envía alertas de clima peligroso e incluye el protocolo correspondiente. |
| RF-43 | El administrador o el tutor puede lanzar manualmente una alerta de emergencia y asociarle su protocolo. |
| RF-44 | Después de una alerta de emergencia, el estudiante puede indicar si está bien o si necesita ayuda. |
| RF-45 | El tutor ve en tiempo real qué estudiantes han respondido a la alerta, cuáles necesitan ayuda y cuáles no han contestado. |


### 2.5 Requisitos no funcionales (RNF)

| ID | Categoría | Requisito |
| --- | --- | --- |
| RNF-01 | Dispositivos | La aplicación móvil está optimizada para tabletas, especialmente para pantallas medianas o grandes. |
| RNF-02 | Accesibilidad | La aplicación cumple con la normativa de accesibilidad vigente (WCAG). |
| RNF-03 | Protección de datos | La aplicación cumple con la legislación sobre protección de datos, especialmente en el tratamiento de datos de menores y personas con discapacidad. Se recoge el consentimiento de los tutores legales y se puede ejercer el derecho de supresión. |
| RNF-04 | Recursos gráficos | La interfaz utiliza pictogramas de ARASAAC en toda la aplicación. |
| RNF-05 | Personalización | La interfaz es personalizable según el perfil: colores, tamaño y posición de los elementos, y modo de comunicación. |
| RNF-06 | Licencia | La aplicación se desarrolla con software libre o con una licencia universitaria. |
| RNF-07 | Notificaciones | Las notificaciones pueden recibirse aunque la aplicación esté en segundo plano o cerrada. |
| RNF-08 | Seguridad | El acceso se controla por perfil (estudiante, tutor, familiar y administrador), y los datos se cifran en tránsito y en reposo. |
| RNF-09 | Disponibilidad | La agenda del día puede consultarse sin conexión a internet. |
| RNF-10 | Accesibilidad cognitiva | Los textos siguen las pautas de lectura fácil (UNE 153101 EX). |
| RNF-11 | Usabilidad | La interfaz es predecible y consistente: los elementos no cambian de posición salvo que lo configure el tutor, y no hay animaciones ni sonidos bruscos. |
| RNF-12 | Licencia de recursos | Se respeta la licencia de ARASAAC (CC BY-NC-SA): se atribuye la autoría de los pictogramas y no se hace uso comercial. |
| RNF-13 | Rendimiento | La agenda del día se carga en menos de 2 segundos. |
| RNF-14 | Plataforma | Se indican el sistema operativo y la versión mínima compatibles de las tabletas. |
| RNF-15 | Idioma | La interfaz está en español. |
| RNF-16 | Copias de seguridad | Se realizan copias de seguridad periódicas de los datos. |


### 2.6 Requisitos de información / Modelo de datos lógico (RI)

| ID | Entidad | Información |
| --- | --- | --- |
| RI01 | Estudiante | Nombre, fotografía, dirección (lugar de residencia), datos de inicio de sesión adaptado, preferencias de comunicación (pictogramas, imágenes, texto, voz y botones grandes), preferencias visuales (colores, tipografía, tamaño de letra y posición de menús), elementos que le calman, intereses (televisión, cine, música y deporte), permiso para modificar sus propias preferencias, aula y tutores asignados. |
| RI02 | Tutor | Nombre, datos de contacto, credenciales de acceso, relación con el estudiante (tutor del centro o familiar) y estudiantes asignados. |
| RI03 | Administrador | Nombre, credenciales de acceso y permisos de gestión global. |
| RI04 | Tarea | Nombre, imagen o pictograma asociado, descripción (texto, audio, vídeo o secuencia de imágenes), tipo (escolar, personal, ocio, doméstica o profesional complementaria), hora de inicio, hora de fin, días de la semana, pasos (si los tiene), estado (pendiente, en curso o completada), persona que la crea, persona que la confirma (estudiante o tutor) y estudiantes o aula asignados. |
| RI05 | Horario o agenda | Conjunto de tareas organizadas por día y franja horaria para cada estudiante, que cubre el día completo. |
| RI06 | Notificación o aviso | Tipo (recordatorio de tarea, refuerzo o aviso al tutor; emergencia o clima, si se implementan RF-40–RF-45), destinatario (estudiante o tutor), momento de envío, formato (pictograma, sonido o voz grabada del usuario, si se implementa RF-14) y estado (enviada o leída). |
| RI07 | Mensaje de chat | Emisor (profesor o tutor del centro, o estudiante), receptor, contenido (texto, pictograma o audio), fecha, hora y estado (enviado o leído). |
| RI08 | Registro de progreso | Estudiante, tarea, fecha, hora real de inicio, hora real de fin, confirmación (por el estudiante o el tutor) y pasos completados. |
| RI09 | Alerta de emergencia | Si se implementan RF-40–RF-45: tipo (sismo o clima peligroso), fecha y hora, persona que la lanza, protocolo asociado (pasos con pictogramas) y respuestas de los estudiantes (está bien, necesita ayuda o sin respuesta). |
| RI10 | Aula | Nombre o número, estudiantes asignados y tutor responsable. |
| RI11 | Listado de comedor | Fecha, aula, estudiantes que comen y tipo de comida de cada uno (hiposódica, triturada, sin gluten, entre otros). |
| RI12 | Recurso multimedia | Archivo, tipo (pictograma, imagen, audio o vídeo), categoría, nombre descriptivo, fuente (ARASAAC, fotografía propia, voz grabada, entre otras) y autoría, para cumplir la licencia de ARASAAC. |


### 2.7 Beneficios y beneficiarios
Los beneficiarios principales serán los estudiantes del PTVAL, que podrán contar con una agenda adaptada para comprender y organizar sus actividades. De forma complementaria, la herramienta podrá apoyar a tutores, familiares y personal del centro en la preparación de tareas y el seguimiento de su realización.

| Beneficiario | Necesidad o situación | Beneficio esperado | Alcance
estimado |
| --- | --- | --- | --- |
| Estudiantes del PTVAL (beneficiarios directos) | Necesidad de organizar y comprender sus actividades con apoyos accesibles. | Agenda personalizada y visual que ayude a seguir tareas con mayor autonomía. | Número por confirmar con el Colegio. |
| Tutores y profesorado | Necesidad de adaptar las tareas y acompañar su realización. | Configuración de apoyos y consulta del progreso para orientar el seguimiento. | Número por confirmar con el Colegio. |
| Familias | Interés en apoyar rutinas y tareas personales fuera del centro. | Posible continuidad de los apoyos entre el centro y el entorno familiar, si se habilita su participación. | Número y modalidad de participación por confirmar. |
| Administración del centro | Necesidad de organizar perfiles y actividades institucionales. | Información más estructurada para gestionar las tareas previstas. | Personas responsables por confirmar. |
| Personal de reprografía y comedor | Coordinación de solicitudes, recogidas, entregas y datos diarios del comedor. | Consulta más clara de las actividades asignadas y de su estado. | Servicios y personas participantes por confirmar. |
| Colegio y comunidad educativa | Interés en apoyar la autonomía y participación del alumnado. | Una propuesta común que podrá revisarse según su utilidad en el centro. | Un centro; alcance de participantes por determinar. |


### 2.8 Planificación temporal e iteraciones

| Fase o
iteración | Actividades y entregables | Coordinación | Fechas |
| --- | --- | --- | --- |
| Inicio | Entrevista y visita, requisitos, manual de coordinación, propuesta técnica y de solución, registro de horas y actas. | Todo el equipo | 25/09 – 22/10/2026 |
| Iteración 1 | Diseño, cuentas y perfiles, creación de tareas y agenda diaria; primer prototipo. | David | 22/10 – 12/11/2026 |
| Iteración 2 | Pasos de las tareas, avisos, seguimiento del tutor y comedor. | Alberto | 12/11 – 3/12/2026 |
| Iteración 3 | Funciones deseables, informe de usabilidad y accesibilidad e informe de calidad. | Manu | 3/12 – 21/12/2026 |
| Cierre | Presentación y defensa del proyecto. | Todo el equipo | 12/01/2027 |


### 2.9 Riesgos, dependencias y restricciones

| Riesgo | Prob. | Medida |
| --- | --- | --- |
| Alcance excesivo (46 requisitos funcionales) | Alta | Priorizar y entregar primero los imprescindibles; los opcionales solo si sobra tiempo. |
| Poca experiencia del equipo con Flutter o Firebase | Media | Formación en la primera semana y revisión de código entre compañeros. |
| Disponibilidad limitada del cliente para validar | Media | Agrupar las dudas y canalizarlas por el profesorado; solicitar validación en la presentación final. |
| Ausencia o baja de un miembro | Media | Tareas documentadas en Jira y traspaso entre iteraciones. |
| Incumplimiento del RGPD con datos de menores | Baja | Datos ficticios en las pruebas, región UE y control de acceso por perfil. |
| Límites del plan gratuito de Firebase | Baja | Vigilar el consumo y optimizar consultas y tamaño de archivos. |


### 2.10 Conformidad con la propuesta técnica
Con su firma, los integrantes del equipo manifiestan su conformidad con la propuesta técnica aquí detallada:

| Miembro | Firma |
| --- | --- |
| David Bacas Posadas |  |
| Adam Ben Chacha |  |
| Paula Cobos González |  |
| Manuel José Fernández Poyatos |  |
| Alberto David Gómez Gijón |  |
| Daniel Viloria Prieto |  |


---

## 3 Propuesta de solución

### 3.1 Resumen
Agenda para tablet que ayuda al alumnado del PTVAL del Colegio de Educación Especial de la Fundación Purísima Concepción a organizar su día y realizar tareas personales y del centro con autonomía. Cada estudiante tiene un perfil adaptado (pictogramas de ARASAAC, colores, tamaño de letra y opciones de comunicación e inicio de sesión); sus tutores preparan las tareas y siguen su progreso, y el administrador gestiona aulas, cuentas y tareas del colegio.

### 3.2 Roles
- **Administrador:** gestiona cuentas, aulas, asignaciones y tareas del centro.
- **Tutor (del centro o familiar):** configura el perfil de sus estudiantes, crea tareas, consulta el progreso y recibe avisos.
- **Estudiante:** consulta su agenda, sigue los pasos de cada tarea y confirma su inicio y fin; puede crear tareas personales y cambiar sus preferencias si su tutor lo permite.

### 3.3 Tecnología
Aplicación en Flutter para tablets Android e iOS, con Firebase (Authentication, Cloud Firestore en región UE, Cloud Storage y Cloud Messaging) y la API de ARASAAC. Flutter permite una sola base de código para ambas plataformas.

### 3.4 Alcance de la propuesta
Relación de requisitos abordados en la entrega inicial y su prioridad de desarrollo (1 = alta/imprescindible, 2 = media/condicionada):

| ID | Requisito | Prioridad |
| --- | --- | --- |
| RF-01 | Gestión de cuentas de tutores y estudiantes | 1 |
| RF-02 | Inicio de sesión de tutores y administrador con recuperación de contraseña | 1 |
| RF-03 | Inicio de sesión adaptado del estudiante (PIN, pictograma o contraseña) | 1 |
| RF-04 | Asignar uno o varios tutores a cada estudiante | 1 |
| RF-05 | Gestión de aulas | 1 |
| RF-06 | Cada tutor solo ve a sus estudiantes | 1 |
| RF-07 | Perfil configurable del estudiante | 1 |
| RF-08 | Preferencias de comunicación (pictogramas, imágenes, texto, voz, botones grandes) | 1 |
| RF-09 | Preferencias visuales (colores, tipografía, tamaño, posición) | 1 |
| RF-10 | Intereses del estudiante | 2 |
| RF-11 | Modificar el perfil según el progreso | 1 |
| RF-12 | Permiso para que el estudiante cambie sus preferencias | 2 |
| RF-13 | Buscar pictogramas en ARASAAC y subir imágenes propias | 1 |
| RF-15 | Crear, editar y eliminar tareas con horario, días y pasos | 1 |
| RF-16 | Asignar tareas a varios estudiantes o a un aula | 1 |
| RF-17 | Tareas que se repiten por días de la semana | 1 |
| RF-18 | Tareas personales del estudiante; tareas del colegio solo por el tutor del centro | 1 |
| RF-19 | Descripción accesible (texto, audio, vídeo o secuencia de imágenes) | 1 |
| RF-20 | Definir la ruta de una tarea (por ejemplo, recoger material y luego ir al taller) | 2 |
| RF-21 | Mostrar los pasos y su avance | 1 |
| RF-22 | Agenda del día | 1 |
| RF-23 | Agenda de la semana | 1 |
| RF-24 | Agenda de todo el día, incluidas tareas de casa | 2 |
| RF-25 | Avisos configurables antes de cada tarea | 1 |
| RF-26 | Confirmar inicio y fin de cada tarea | 1 |
| RF-27 | Reloj temporizador accesible que se puede mostrar u ocultar | 1 |
| RF-28 | Mensaje de refuerzo positivo al completar | 2 |
| RF-29 | Guías paso a paso de tareas domésticas | 3 |
| RF-30 | Apoyo al tiempo de autorregulación | 3 |
| RF-31 | Actividades de ocio con sugerencias según intereses | 3 |
| RF-32 | Tareas de tipo profesional complementario | 3 |
| RF-33 | El tutor consulta el progreso y confirma tareas | 1 |
| RF-34 | Historial de tareas por día y semana | 2 |
| RF-35 | Aviso al tutor si no se inicia o termina una tarea a tiempo | 2 |
| RF-39 | Listado diario de comedor por aula | 1 |


#### 3.4.1. Requisitos no prioritarios o aplazados
- **RF-40–RF-42 — Alertas meteorológicas y de emergencias:** no se abordarán inicialmente, pues requieren fuentes de datos fiables y protocolos de actuación definidos.
- **RF-43–RF-45 — Gestión de emergencias:** no se implementarán inicialmente; requieren protocolos validados por el centro, avisos fiables y seguimiento de respuestas en tiempo real.

#### 3.4.2. Chat accesible condicionado a disponibilidad
Los requisitos **RF-36–RF-38** (chat accesible exclusivamente entre el profesorado del centro y el estudiante, adaptado con audio o pictogramas y con aviso al profesorado del centro) no forman parte de la prioridad de desarrollo. Solo se abordarán si se completan los requisitos priorizados y queda tiempo disponible.

### 3.5 Fuera del alcance
- Suministro de tabletas y otros dispositivos de apoyo.
- Mantenimiento de la aplicación después de la entrega final.
- Integración con otros sistemas del centro (secretaría, plataformas educativas).

---

## 4 Registro de horas

Horas dedicadas al proyecto por cada miembro (fechas de 2026). Las sesiones de prácticas (jueves de 8:30 a 10:30) se computan como 2 horas por asistente.

### Registro de sesiones de trabajo

| Fecha | Horario | Miembro | Tarea | Tipo | Horas |
| --- | --- | --- | --- | --- | --- |
| 24/09 | 8:30–10:30 | Todo el equipo salvo Daniel | Formación del equipo, reparto de roles y preparación de las preguntas para la entrevista con el cliente | Reunión | 2 c/u |
| 25/09 | No especificado; duración aprox. 2 h | Todo el equipo salvo Daniel | Entrevista con la dirección del Colegio | Reunión con cliente | 2 c/u |
| 01/10 | 8:30–10:30 | Todo el equipo | Puesta en común de la entrevista, lista única de requisitos y elección de la tecnología | Análisis | 2 c/u |
| 02/10 | No especificado; duración aprox. 2 h | Paula Cobos González y Manuel José Fernández Poyatos | Visita al Colegio y observación de las actividades del PTVAL | Visita | 2 c/u |
| 08/10 | 8:30–10:30 | Todo el equipo | Redacción del manual de coordinación: metodología, roles, herramientas y estándares | Gestión | 2 c/u |
| 13/10 | 16:00–18:00 | David | Estructura del documento en LATEX y primera versión del manual de coordinación | Documentación | 2 |
| 14/10 | 17:00–18:00 | Paula | Revisión de los requisitos de accesibilidad y usabilidad | Análisis | 1 |
| 15/10 | 8:30–10:30 | Todo el equipo | Propuesta técnica: requisitos funcionales, no funcionales y de información | Análisis | 2 c/u |
| 20/10 | 16:30–18:30 | Daniel | Revisión del manual de coordinación y apartados pendientes de la propuesta técnica | Documentación | 2 |


### Totales por miembro

| Miembro | Reuniones | Adicionales | Total |
| --- | --- | --- | --- |
| David Bacas Posadas | 10 | 2 | 12 |
| Adam Ben Chacha | 10 | 0 | 10 |
| Paula Cobos González | 12 | 1 | 13 |
| Manuel José Fernández Poyatos | 12 | 0 | 12 |
| Alberto David Gómez Gijón | 10 | 0 | 10 |
| Daniel Viloria Prieto | 6 | 2 | 8 |
| Total | 60 | 5 | 65 |


---

## 5 Actas de reuniones

### 5.1 Acta 01 – Formación del equipo, roles y tecnología

| Campo | Detalle |
| --- | --- |
| Fecha y hora | 24/09/2026, 8:30 – 10:30 |
| Lugar o modalidad | Presencial, sesión de prácticas |
| Asistentes | David, Adam, Paula, Manu y Alberto |
| Ausentes | Ninguno (Daniel se incorporó al equipo el 01/10/2026) |
| Modera / redacta | Manu / Alberto |

#### Orden del día
1. Presentación del proyecto y lectura del pliego técnico.
2. Asignación de roles organizativos y funciones técnicas.
3. Selección inicial de las tecnologías del proyecto.
4. Preparación de la entrevista con el cliente del 25/09.

#### Desarrollo
Repasamos el pliego técnico y el guion de prácticas para entender qué hay que entregar y en qué fechas. Hablamos de qué roles encajaban mejor con cada persona: Paula se ofreció para Usabilidad y Accesibilidad y Adam para Calidad, que no rotan. Los demás roles se repartieron de forma rotatoria para que todos pasemos por cada uno, dejando hueco para un sexto miembro si se incorporaba alguien más al grupo. Después preparamos entre todos una lista de dudas y temas que queríamos consultar al cliente en la entrevista del día siguiente.

#### Acuerdos
- Roles organizativos iniciales: David (Coordinador), Manu (Moderador), Alberto (Catalogador), Daniel (Presentador, pendiente de confirmación de asistencia), Paula (Usabilidad/Accesibilidad) y Adam (Calidad).
- Funciones técnicas iniciales: David y Alberto en Planificación y Documentación; Manu y Daniel en Especificación y Diseño; Paula y Adam en Implementación y Pruebas.
- Tecnologías: Flutter como framework principal y Firebase para el backend (autenticación, base de datos y almacenamiento).
- Canales de comunicación: WhatsApp para el día a día y Discord para reuniones online y compartir material.

#### Tareas asignadas

| Tarea | Responsable | Fecha límite |
| --- | --- | --- |
| Cerrar la lista de preguntas para la entrevista | Todo el equipo | 25/09/2026 |
| Crear el grupo de WhatsApp y el servidor de Discord | David | 25/09/2026 |

*Próxima reunión:* 25/09/2026, entrevista con el cliente.  
*Conformidad:* Los asistentes dan su conformidad a esta acta.

### 5.2 Acta de entrevista con el cliente – 25/09/2026

| Campo | Detalle |
| --- | --- |
| Fecha y hora | 25/09/2026; horario no especificado (duración aproximada: 2 horas, según el registro de horas) |
| Lugar o modalidad | No especificado en la documentación disponible |
| Asistentes | Dirección del Colegio y todo el equipo salvo Daniel, que se incorporó el 01/10/2026 |
| Modera / redacta | No consta en la documentación disponible |

#### Orden del día
1. Recogida de necesidades iniciales para la agenda móvil del alumnado del PTVAL.

#### Desarrollo
Se realizó una entrevista inicial con la dirección del Colegio para conocer las necesidades del alumnado del PTVAL relacionadas con la organización del tiempo y la realización de tareas. En el acta del 01/10/2026 consta que, a partir de esta entrevista, el equipo recopiló necesidades de accesibilidad y cuestiones pendientes sobre los apoyos y la presentación de las tareas. Esas cuestiones se trasladaron a la lista de requisitos y motivaron la visita al centro del 02/10/2026 para observar el contexto real de uso.

#### Acuerdos
- El perfil destinatario principal es el alumnado del PTVAL.
- Se identificó la necesidad de estructurar la información con apoyos visuales y accesibles (pictogramas, fotos, audio).
- Se acordó una visita presencial al colegio el 2 de octubre para conocer las instalaciones y rutinas.

*Conformidad:* Los asistentes dan su conformidad a esta acta.

### 5.3 Acta 02 – Análisis de la entrevista y tecnología

| Campo | Detalle |
| --- | --- |
| Fecha y hora | 01/10/2026, 8:30 – 10:30 |
| Lugar o modalidad | Presencial, sesión de prácticas |
| Asistentes | David, Adam, Paula, Manu, Alberto y Daniel |
| Ausentes | Ninguno |
| Modera / redacta | Manu / Daniel |

#### Orden del día
1. Puesta en común de la entrevista con el cliente.
2. Definición de la lista única de requisitos.
3. Confirmación de las herramientas y tecnologías definitivas.
4. Preparación de la visita al Colegio Purísima Concepción del 02/10.

#### Desarrollo
Compartimos las notas que tomamos en la entrevista con el cliente. Vimos que los alumnos tienen niveles de autonomía muy distintos y que la aplicación tiene que ser muy adaptable: algunos necesitarán solo pictogramas, otros texto con audio y otros fotos de los lugares reales del colegio. Juntamos las listas de requisitos que habíamos pensado por separado para crear un único documento compartido, evitando duplicados. Confirmamos que Flutter y Firebase cubren todo lo que necesitamos para el desarrollo, y que la documentación se hará en LaTeX para que tenga un formato homogéneo.

#### Acuerdos
- Daniel Viloria se incorpora formalmente al equipo y asume los roles y funciones asignados.
- Lista unificada de requisitos funcionales y no funcionales como base para la propuesta técnica.
- Necesidades de accesibilidad recogidas como criterios para el diseño de los perfiles y las tareas.
- El chat y las alertas quedan sujetos a priorización posterior.
- Trasladar a la visita del centro las dudas pendientes sobre los requisitos.

#### Tareas asignadas

| Tarea | Responsable | Fecha límite |
| --- | --- | --- |
| Pasar a limpio la lista de requisitos | Alberto y Manu | 08/10/2026 |
| Revisar los requisitos de accesibilidad | Paula | 08/10/2026 |
| Preguntar en la visita las dudas pendientes | Paula y Manu | 02/10/2026 |

*Próxima reunión:* 08/10/2026, 8:30, sesión de prácticas.  
*Conformidad:* Los asistentes dan su conformidad a esta acta.

### 5.4 Acta 03 – Visita al centro

| Campo | Detalle |
| --- | --- |
| Fecha | 02/10/2026 |
| Lugar o modalidad | Presencial, Colegio de Educación Especial de la Fundación Purísima Concepción (Granada) |
| Asistentes | Paula Cobos González y Manuel José Fernández Poyatos |
| Modera / redacta | Paula Cobos González / Manuel José Fernández Poyatos |

#### Orden del día
1. Observación directa del entorno escolar y de las rutinas del alumnado del PTVAL.
2. Resolución de dudas sobre los apoyos visuales y el uso de dispositivos en el aula.

#### Desarrollo
Paula y Manu visitaron las instalaciones del CEE Purísima Concepción. Observaron las aulas del PTVAL, los talleres (reprografía, jardinería, cocina) y los espacios comunes. Comprobaron cómo el profesorado utiliza actualmente paneles físicos con velcros y pictogramas de ARASAAC, y la importancia de que la tableta ofrezca una navegación muy clara, con pulsadores grandes y confirmación sonora/visual de pasos completados.

#### Acuerdos
- La aplicación debe priorizar la simplicidad extrema en el modo estudiante: un solo elemento o paso por pantalla si el perfil lo requiere.
- Se debe integrar la biblioteca de pictogramas ARASAAC y admitir fotos reales de estancias del centro.
- Los apoyos y preferencias concretos se validarán con el Colegio antes de cerrar el diseño.

#### Tareas asignadas

| Tarea | Responsable | Fecha límite |
| --- | --- | --- |
| Incorporar las observaciones de accesibilidad a la lista de requisitos | Paula y Manu | 08/10/2026 |

*Próxima reunión:* 08/10/2026, 8:30, sesión de prácticas.  
*Conformidad:* Los asistentes dan su conformidad a esta acta.

### 5.5 Acta 04 – Enfoque de la aplicación y reparto del documento

| Campo | Detalle |
| --- | --- |
| Fecha y hora | 08/10/2026, 8:30 – 10:30 |
| Lugar o modalidad | Presencial, sesión de prácticas |
| Asistentes | David, Adam, Paula, Manu, Alberto y Daniel |
| Ausentes | Ninguno |
| Modera / redacta | Manu / Daniel |

#### Orden del día
1. Cómo queremos enfocar la aplicación tras la visita al centro.
2. Reparto de los apartados de la primera entrega.
3. Formato y herramienta para la documentación.

#### Desarrollo
Con lo recogido en la entrevista y en la visita, hablamos de cómo enfocar la aplicación. Acordamos que la prioridad absoluta es que sea accesible para los alumnos del PTVAL, con perfiles adaptables y tareas paso a paso, dejando el chat o funciones más complejas para cuando lo básico funcione bien. Repartimos los apartados del documento entre todos para tener un primer borrador la semana siguiente. Elegimos LaTeX para la redacción final, montando una plantilla compartida.

#### Acuerdos
- La solución se centrará en tres perfiles: Estudiante, Tutor y Administrador.
- Los requisitos se clasificarán formalmente en RF, RNF y RI.
- Se redacta el Manual de Coordinación y la Propuesta Técnica en LaTeX.

#### Tareas asignadas

| Tarea | Responsable | Fecha límite |
| --- | --- | --- |
| Estructura del documento en LATEX y primera versión del manual de coordinación | David | 15/10/2026 |
| Requisitos funcionales, no funcionales y de información de la propuesta técnica | Alberto y Manu | 15/10/2026 |
| Requisitos de accesibilidad y usabilidad | Paula | 15/10/2026 |
| Revisión de calidad de la documentación | Adam | 21/10/2026 |
| Revisión del manual y apartados pendientes de la propuesta técnica | Daniel | 21/10/2026 |

*Próxima reunión:* 15/10/2026, 8:30, sesión de prácticas.  
*Conformidad:* Los asistentes dan su conformidad a esta acta.

### 5.6 Acta 05 – Seguimiento del documento y resolución de dudas

| Campo | Detalle |
| --- | --- |
| Fecha y hora | 15/10/2026, 8:30 – 10:30 |
| Lugar o modalidad | Presencial, sesión de prácticas |
| Asistentes | David, Adam, Paula, Manu, Alberto y Daniel |
| Ausentes | Ninguno |
| Modera / redacta | Manu / Daniel |

#### Orden del día
1. Revisión del borrador integrado del documento.
2. Resolución de dudas sobre los requisitos de accesibilidad y modelo de datos.
3. Planificación del cierre de la primera entrega.

#### Desarrollo
Pusimos en común las partes redactadas por cada uno y revisamos que la numeración de los requisitos y la estructura fueran coherentes. Ajustamos la redacción de varios requisitos funcionales para que quedara claro qué hace el alumno y qué hace el tutor. También revisamos el registro de horas para comprobar que todos llevamos un seguimiento adecuado. Acordamos los últimos detalles que faltaban por completar antes de la entrega final.

#### Acuerdos
- Integrar todos los apartados en el repositorio común de LaTeX.
- Validar las tablas de requisitos y la matriz de riesgos.
- Fijar el 21/10/2026 como fecha para la revisión final y firma del manual.

#### Tareas asignadas

| Tarea | Responsable | Fecha límite |
| --- | --- | --- |
| Completar los apartados pendientes de la propuesta técnica y la propuesta de solución | Daniel | 21/10/2026 |
| Revisión y cierre del acta de requisitos y del acta de visita | Paula y Manu | 21/10/2026 |
| Revisión final y firma del manual | Todo el equipo | 22/10/2026 |

*Próxima reunión:* 22/10/2026, 8:30, sesión de prácticas (inicio de la iteración 1).  
*Conformidad:* Los asistentes dan su conformidad a esta acta.

#### Nota de actualización documental (22/10/2026)
Durante la revisión posterior del documento, el equipo acuerda que el chat (**RF-36–RF-38**), si llega a desarrollarse, será exclusivamente entre profesorado del centro y estudiantes, y no tendrá prioridad. También se excluyen inicialmente las alertas **RF-40–RF-45** y se elimina **RF-46** (asistente conversacional de IA), que se había añadido a petición del equipo en una versión de trabajo, por no estar justificado con las necesidades reales del centro y suponer un riesgo de alcance.
