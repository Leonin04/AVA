# Modelos y servicio de base de datos (iteración 1)

Los modelos están en la capa `dominio/` de cada funcionalidad y el servicio en `core/servicios/`:

```
lib/
├── core/servicios/base_datos.dart            ← todas las lecturas y escrituras
└── features/
    ├── autenticacion/dominio/usuario.dart    ← usuarios/{uid}          (RF-01, RF-02)
    ├── perfil/dominio/estudiante.dart        ← estudiantes/{uid}       (RF-01, RF-03, RF-04, RF-06, RF-07)
    ├── perfil/dominio/preferencias.dart      ← map "preferencias"      (RF-08, RF-09)
    ├── aulas/dominio/aula.dart               ← aulas/{id}              (RF-05)
    ├── tareas/dominio/tarea.dart             ← tareas/{id}             (RF-15, RF-22)
    └── tareas/dominio/paso.dart              ← tareas/{id}/pasos/{id}  (RF-15)
```

La agenda (RF-22) usa `Tarea` de `features/tareas/dominio/` y `BaseDatos.tareasDelDia`.

Dependencia necesaria: `flutter pub add cloud_firestore`

## Ejemplos de uso

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:<nombre_app>/core/servicios/base_datos.dart';
import 'package:<nombre_app>/features/perfil/dominio/estudiante.dart';
import 'package:<nombre_app>/features/tareas/dominio/paso.dart';
import 'package:<nombre_app>/features/tareas/dominio/tarea.dart';
// <nombre_app> = el "name:" de pubspec.yaml

final bd = BaseDatos();
final uid = FirebaseAuth.instance.currentUser!.uid;

// Después del login: ¿es admin, tutor o estudiante?
final usuario = await bd.obtenerUsuario(uid);   // null => es estudiante
final estudiante = usuario == null ? await bd.obtenerEstudiante(uid) : null;

// RF-06: lista de estudiantes del tutor (se actualiza sola)
StreamBuilder<List<Estudiante>>(
  stream: bd.estudiantesDeTutor(uid),
  builder: (context, snap) {
    final lista = snap.data ?? [];
    return ListView(children: [for (final e in lista) ListTile(title: Text(e.nombre))]);
  },
);

// RF-08/09: activar la voz y subir el tamaño de letra
final p = estudiante!.preferencias;
await bd.actualizarPreferencias(estudiante.id, p.copyWith(
  comunicacion: p.comunicacion.copyWith(voz: true),
  visual: p.visual.copyWith(tamanoLetra: 28),
));

// RF-15: crear una tarea con pasos
await bd.crearTarea(
  Tarea(
    id: '',
    nombre: 'Preparar la mochila',
    horaInicio: '20:00',
    horaFin: '20:15',
    diasSemana: [1, 2, 3, 4],
    creadaPor: uid,
    estudiantes: [estudiante.id],
  ),
  [
    const Paso(id: '', orden: 1, texto: 'Meter los libros'),
    const Paso(id: '', orden: 2, texto: 'Cerrar la mochila'),
  ],
);

// RF-22: tareas de hoy del estudiante, ordenadas por hora
bd.tareasDelDia(uid);   // Stream<List<Tarea>>
```

## Avisos

- Los tutores **siempre** cargan a sus estudiantes con `estudiantesDeTutor`. Si consultan la colección completa, las reglas rechazan la petición.
- `crearEstudiante` solo guarda el documento. La cuenta de Authentication del estudiante (`<usuario>@alumnos.agenda.local` con el PIN como contraseña) se crea antes, y su `uid` es el `id` del estudiante.
- Las fechas `creadoEn` las pone el servidor con `FieldValue.serverTimestamp()`.
