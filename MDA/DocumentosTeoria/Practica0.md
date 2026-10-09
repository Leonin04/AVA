# Práctica 0: Descripción del problema y organización del grupo de trabajo

**Metodologías de Desarrollo Ágiles (Grado en Ingeniería Informática) — Curso 2026/2027**  
*© Lenguajes y Sistemas Informáticos (Universidad de Granada)*

---

## 1. Temporización

| Comienzo de la práctica | Duración |
| :--- | :--- |
| Semana del 28 de septiembre de 2026 | 1 semana |

---

## 2. Descripción del problema a abordar

La aplicación que se propone desarrollar surge a partir de la necesidad de facilitar la organización y estructuración del tiempo a estudiantes con discapacidad intelectual, proporcionándoles una agenda personalizada como una aplicación móvil que permita personalizar la lista de tareas a realizar y avise del tiempo. Esta herramienta será muy útil para estudiantes del **Programa de Transición a la Vida Adulta (PTVAL)**.

### Tareas del centro
Existen algunas tareas concretas del centro que se pueden asignar a un estudiante para que las realice a una hora concreta durante un día, o varios días. Estas tareas son:

- **Reprografía:** un estudiante del taller de reprografía deberá realizar los siguientes pasos:
  1. Recoger de un aula un material.
  2. Ir al taller para imprimir, fotocopiar o plastificar el material.
  3. Volver al aula a repartir el material original y el creado.  
  *Nota:* Será el tutor de un aula el que haga la petición y el encargado del taller de reprografía o administrador el que asigne la tarea a un estudiante concreto.
- **Comedor:** un estudiante debe ir a todas las aulas del centro, una por una, anotando qué estudiante comerá en el comedor del centro y qué tipo de comida (hiposódica, triturada, sin gluten, etc.). Se generará un listado para el comedor. Un administrador asignará esta tarea a un estudiante concreto cada día.
- **Documento de menú mensual:** un estudiante repartirá a cada estudiante de cada aula un documento impreso con el menú mensual del centro, tomando nota de las entregas realizadas. Un administrador asignará esta tarea a un estudiante concreto cada mes.
- **Guía de visita:** un estudiante o varios serán encargados de ser embajadores del centro, contando qué se hace en sus diferentes espacios durante una visita por parte de personas externas. Un administrador asignará esta tarea a uno o varios estudiantes concretos cada vez que haya una necesidad.

### Tareas personales
Además, se podrán crear otras tareas personales: un tutor o el propio estudiante podrán crear tareas personales, asignando hora de inicio y fin, y días en los que se realizarán en esa semana.

- Cada tarea debe tener un nombre y una imagen asociada.
- También podrá llevar una descripción en un formato accesible para el estudiante (texto, audio, vídeo, secuencia de imágenes).
- El estudiante confirmará su inicio y finalización.
- Durante la realización se podrá visualizar/ocultar un reloj temporal accesible (opcional dependiendo del estudiante).
- En el caso de mostrarse una secuencia de pasos, se irá marcando también el fin de cada paso.
- *Ejemplos de tareas personales:* hacerse la merienda, ir a jugar al pádel, regar las plantas, hacer los deberes, etc. Cada estudiante tendrá sus propias tareas.
- El tutor puede ser diferente del tutor del colegio, por ejemplo, alguno de sus padres.

### Perfiles de usuario y personalización
Con el objetivo de adaptarnos a las necesidades específicas de los estudiantes, se crearán perfiles para éstos:
- En el perfil se introducirán datos de identificación del estudiante, datos para entrar a la aplicación (login) de forma accesible y preferencias de visualización de la aplicación.
- En las preferencias pueden escogerse colores favoritos, tipo y tamaño de letra y posición de botones o menús, así como las imágenes y audios usados en la aplicación.
- Para las imágenes e iconos se pueden usar fotografías y pictogramas de **ARASAAC**.
- Las tareas pueden visualizarse solo las del día en curso o bien ofrecer un menú semanal para elegir (dependerá también del perfil del estudiante).
- El poder visualizar el paso del tiempo durante la realización de una tarea también será configurable (fijo u opcional).
- Algunos estudiantes podrán modificar ellos mismos sus propias preferencias.

### Roles de gestión y comunicación
- **Administrador:** creará a los tutores y a los estudiantes.
- **Tutor:** el administrador o el tutor podrán configurar el perfil de cada uno de sus estudiantes, y cambiarlo en base al progreso de éste y a la valoración sobre su adecuación. El tutor también podrá consultar el progreso del estudiante.
- **Chat accesible:** sería interesante poder crear un chat (accesible también) entre un tutor y un estudiante, de tal forma que puedan intercambiar mensajes de ayuda y refuerzo.

### Accesibilidad física y antecedentes
- **Movilidad:** la aplicación debe ser también accesible para estudiantes con problemas de movilidad. Habrá una clase extra para explicar el uso y aplicación de algunos dispositivos específicos, de tal forma que puedan usarse y probarse en el proyecto.
- **Limitaciones de soluciones existentes:** ya existen aplicaciones similares, pero resultan complejas para los estudiantes por no ser muy accesibles ni estar adaptadas a discapacidad cognitiva. El otro problema es que la personalización o adaptación es inexistente o costosa para los tutores.

---

### Técnicas aplicadas en las prácticas
A lo largo de las prácticas aplicaremos diferentes técnicas sobre el sistema propuesto (para facilitar su diseño y desarrollo) como son:
- La descripción inicial del sistema usando **Personas y Escenarios**.
- La gestión ágil del proyecto usando **SCRUM**.
- La descripción de **Historias de Usuario**.
- La creación de **prototipos y su evaluación con usuarios** siguiendo un Diseño Centrado en el Usuario (**DCU**), etc.

### Roles en el grupo de trabajo
A lo largo del proyecto, el grupo de trabajo (grupo de 6 alumnos de prácticas) mantendrá una organización basada en roles. Cada miembro tendrá asignado un rol con actividades y objetivos específicos:

- **Coordinador:** responsable del cumplimiento de los objetivos grupales, así como de la gestión del grupo (comunicación, coordinación, planificación, etc.).
- **Catalogador:** responsable de recopilar, analizar y clasificar la información generada por el grupo en las diferentes tareas asociadas a las prácticas.
- **Moderador:** responsable de plantear y moderar los debates y de seleccionar las ideas y decisiones grupales.
- **Presentador:** responsable de elaborar y presentar resúmenes, resultados y presentaciones tanto al profesor como a los compañeros de otros grupos.
- **Gestor de la Calidad:** responsable de asegurar la calidad de los productos generados y del proceso de desarrollo. Velará por que los documentos y técnicas aplicadas sigan los estándares presentados en clase.
- **Gestor de usabilidad y accesibilidad:** responsable de planificar y asegurar la usabilidad y accesibilidad del proyecto.

> **Nota:** Aunque se han definido estas tareas y responsabilidades, es responsabilidad de todo el grupo que las actividades se realicen correctamente y en plazo. Si son necesarias nuevas responsabilidades o roles, deben ser definidos y asignados por el grupo.

---

## 3. Actividades a realizar

- Organizar el grupo de prácticas.
- Asignar a cada uno de los miembros del grupo uno de los roles descritos anteriormente.

---

## 4. Recomendaciones para realizar la práctica

Para una buena organización del grupo de prácticas es muy importante mantener un repositorio con la información actualizada del proyecto (documentos de trabajo, documentos para entregar, versiones del producto, etc.). 

En estas primeras reuniones puede ser un buen momento para decidir qué herramientas usar (por ejemplo, un repositorio en la nube tipo Dropbox o Google Drive) y para configurarlas. Recordar que el **Catalogador** debe encargarse y hacerse responsable de estas actividades y recursos compartidos.

---

## 5. Entrega de los documentos generados

| Documentación a aportar (Tipo de entrega) | Fecha de entrega |
| :--- | :--- |
| Lista de asignación de roles del grupo de trabajo. | Antes de que empiece la Práctica 2* |

*\* Se concretará en [Prado](https://prado.ugr.es/) la fecha exacta para cada grupo.*

> **Nota de entrega:** Los documentos se entregarán usando una actividad que se habilitará en Prado.
