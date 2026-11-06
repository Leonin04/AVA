# Tareas y agenda (T-65 a T-86)

Código de las tareas asignadas a Daniel. Va dentro de `AVA/` respetando la
estructura `features/<módulo>/{dominio,logica,presentacion}`.

## Qué tarea está en qué fichero

| Tarea | Qué hace | Fichero |
|---|---|---|
| T-65 | Listar las tareas de un estudiante | `features/tareas/presentacion/pantalla_tareas_estudiante.dart` + `BaseDatos.tareasDeEstudiante` |
| T-66 | Crear una tarea con nombre | `features/tareas/presentacion/pantalla_formulario_tarea.dart` |
| T-67 | Asignar la tarea a uno o varios estudiantes | formulario (selector de estudiantes) |
| T-68 | Descripción | formulario |
| T-69 | Tipo (colegio / personal) | formulario + `TipoTarea` en `dominio/tarea.dart` |
| T-70 | Pictograma de ARASAAC | `features/tareas/presentacion/selector_pictograma.dart` + `core/servicios/arasaac.dart` |
| T-71, T-72 | Hora de inicio y de fin | formulario |
| T-73 | Días en que se repite (o una fecha concreta) | formulario + `Tarea.esParaDia` |
| T-74 a T-77 | Añadir, editar, eliminar y reordenar pasos | `features/tareas/presentacion/editor_pasos.dart` + `logica/formulario_tarea.dart` |
| T-78 | Validar campos obligatorios | `FormularioTarea.validar()` en `features/tareas/logica/formulario_tarea.dart` |
| T-79 | Editar una tarea | formulario abierto con `tareaEditar` |
| T-80 | Eliminar una tarea (con confirmación) | `pantalla_tareas_estudiante.dart` |
| T-81 | Tareas del estudiante para hoy | `features/agenda/logica/agenda_dia.dart` → `tareasDelDia()` |
| T-82 | Ordenarlas por hora | `tareasDelDia()` |
| T-84 | Lista de tareas del día | `features/agenda/presentacion/pantalla_agenda_dia.dart` |
| T-85 | Abrir el detalle de una tarea | `features/agenda/presentacion/pantalla_detalle_tarea.dart` |
| T-86 | Mostrar los pasos en el detalle | `pantalla_detalle_tarea.dart` |

**Para otros miembros:**
- **T-83** (tarjeta de tarea): en `pantalla_agenda_dia.dart` hay un widget provisional `_FilaTarea`. Cuando esté la tarjeta definitiva, se cambia ahí.
- **T-87** (aviso si no hay tareas) y **T-88** (tiempo real): ya funcionan de forma básica, porque la lista usa un `Stream` y muestra "Hoy no tienes tareas". Quien los tenga asignados puede mejorarlos.

## Cómo usar las pantallas desde otras partes de la app

```dart
// Tutor o admin: tareas de un estudiante (con crear / editar / borrar)
Navigator.push(context, MaterialPageRoute(
  builder: (_) => PantallaTareasEstudiante(usuario: usuario, estudiante: estudiante),
));

// Estudiante: su agenda de hoy
Navigator.push(context, MaterialPageRoute(
  builder: (_) => PantallaAgendaDia(estudiante: estudiante),
));
```

## Pantalla de desarrollo (`lib/dev/pantalla_desarrollo.dart`)

Sirve para probar todo esto mientras no exista el login real: entras como admin o tutor,
creas un estudiante de prueba y abres sus tareas o su agenda. Se usa poniendo
temporalmente `home: const PantallaDesarrollo()` en `main.dart`. **No dejar ese cambio en main.**

## Tests

`test/features/agenda_dia_test.dart` y `test/features/formulario_tarea_test.dart`
comprueban T-71 a T-82 sin Firebase. Se lanzan con `flutter test`.
