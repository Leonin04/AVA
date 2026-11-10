import '../core/servicios/arasaac.dart';
import '../core/servicios/autenticacion.dart';
import '../core/servicios/base_datos.dart';
import '../features/autenticacion/dominio/usuario.dart';
import '../features/perfil/dominio/estudiante.dart';
import '../features/perfil/dominio/preferencias.dart';
import '../features/tareas/dominio/paso.dart';
import '../features/tareas/dominio/tarea.dart';

/// T-11: carga datos de prueba en Firebase desde la propia app.
/// Hay que haber entrado como ADMIN. Todos los datos son inventados.
///
/// Crea: 2 tutores, 2 aulas, 4 estudiantes (uno por método de acceso)
/// y 5 tareas con pasos (una de ellas para un aula entera).
/// Devuelve un resumen con las cuentas creadas.
Future<String> cargarDatosPrueba({required String adminUid}) async {
  final bd = BaseDatos();
  final auth = Autenticacion(bd: bd);
  final arasaac = Arasaac();

  Future<String> picto(String palabra) async {
    try {
      final r = await arasaac.buscar(palabra, maximo: 1);
      return r.isEmpty ? '' : r.first;
    } catch (_) {
      return '';
    }
  }

  // ---------- Tutores ----------
  final tutora = await auth.crearCuentaPersonal(
    nombre: 'Laura Martín',
    correo: 'tutora.ava@ava-pruebas.test',
    contrasena: 'AVAtutor',
    rol: Rol.tutor,
    tipoTutor: TipoTutor.centro,
  );
  final familiar = await auth.crearCuentaPersonal(
    nombre: 'Antonio Ruiz',
    correo: 'familia.ava@ava-pruebas.test',
    contrasena: 'AVAfamilia',
    rol: Rol.tutor,
    tipoTutor: TipoTutor.familiar,
  );

  // ---------- Aulas ----------
  final aulaA = await bd.crearAula(nombre: '1º A', tutorResponsable: tutora);
  final aulaB = await bd.crearAula(nombre: '1º B', tutorResponsable: tutora);

  // ---------- Estudiantes ----------
  final pablo = await auth.crearCuentaEstudiante(
    Estudiante(
      id: '',
      nombre: 'Pablo R.',
      usuario: 'pablo',
      lugarResidencia: 'Granada',
      fotoUrl: await picto('niño'),
      queLeCalma: 'Escuchar música con cascos y que le avisen antes de los cambios.',
      queNecesita: 'Instrucciones cortas, de una en una, con pictograma.',
      intereses: const ['fútbol', 'música'],
      metodoLogin: MetodoLogin.pin,
      aulaId: aulaA,
      tutores: [tutora, familiar],
    ),
    '1234',
  );
  final marta = await auth.crearCuentaEstudiante(
    Estudiante(
      id: '',
      nombre: 'Marta G.',
      usuario: 'marta',
      lugarResidencia: 'Armilla',
      fotoUrl: await picto('niña'),
      queLeCalma: 'Un rincón tranquilo y respirar contando hasta cinco.',
      queNecesita: 'Letra grande y que se le lea el texto en voz alta.',
      intereses: const ['dibujar', 'animales'],
      metodoLogin: MetodoLogin.pictograma,
      aulaId: aulaA,
      tutores: [tutora],
      puedeCambiarPreferencias: true,
      preferencias: const Preferencias(
        visual: PreferenciasVisual(tamanoLetra: 28, colores: EsquemaColores.claro),
      ),
    ),
    const ['sol', 'perro', 'flor'],
  );
  await auth.crearCuentaEstudiante(
    Estudiante(
      id: '',
      nombre: 'Lucía P.',
      usuario: 'lucia',
      lugarResidencia: 'Maracena',
      fotoUrl: await picto('chica'),
      intereses: const ['cocinar'],
      metodoLogin: MetodoLogin.contrasena,
      aulaId: aulaB,
      tutores: [tutora],
    ),
    'lucia123',
  );
  await auth.crearCuentaEstudiante(
    Estudiante(
      id: '',
      nombre: 'Javier M.',
      usuario: 'javier',
      lugarResidencia: 'Granada',
      fotoUrl: await picto('chico'),
      intereses: const ['ordenadores'],
      metodoLogin: MetodoLogin.pin,
      aulaId: aulaB,
      tutores: [tutora],
    ),
    '4321',
  );

  // ---------- Tareas ----------
  final todosLosDias = [1, 2, 3, 4, 5];
  Future<void> tarea(String nombre, String palabraPicto, String inicio, String fin,
      List<String> pasos,
      {List<String> estudiantes = const [],
      String? aula,
      TipoTarea tipo = TipoTarea.colegio,
      List<int>? dias}) async {
    await bd.crearTarea(
      Tarea(
        id: '',
        nombre: nombre,
        pictogramaUrl: await picto(palabraPicto),
        descripcion: '',
        tipo: tipo,
        horaInicio: inicio,
        horaFin: fin,
        diasSemana: dias ?? todosLosDias,
        creadaPor: adminUid, // las reglas exigen que lo cree quien está conectado
        estudiantes: estudiantes,
        aulaId: aula,
      ),
      [for (var i = 0; i < pasos.length; i++) Paso(id: '', orden: i + 1, texto: pasos[i])],
    );
  }

  await tarea('Saludar al llegar', 'saludar', '09:00', '09:10',
      ['Entrar en clase', 'Decir buenos días', 'Colgar la mochila'],
      aula: aulaA);
  await tarea('Llevar fotocopias a reprografía', 'fotocopiadora', '10:00', '10:20', [
    'Coger las fotocopias de la mesa de la profesora',
    'Bajar a la planta baja',
    'Entregar las fotocopias en reprografía',
    'Volver al aula',
  ], estudiantes: [pablo], dias: [1, 3]);
  await tarea('Poner la mesa del comedor', 'poner la mesa', '13:30', '13:45',
      ['Coger los platos', 'Poner un vaso en cada sitio', 'Poner los cubiertos'],
      estudiantes: [pablo, marta]);
  await tarea('Recoger los materiales', 'recoger', '14:00', '14:10',
      ['Guardar los lápices', 'Guardar los cuadernos'],
      aula: aulaB);
  await tarea('Preparar la mochila', 'mochila', '20:00', '20:15',
      ['Mirar la agenda de mañana', 'Meter los libros', 'Cerrar la mochila'],
      estudiantes: [pablo],
      tipo: TipoTarea.personal,
      dias: [1, 2, 3, 4, 7]);

  return '''
Datos de prueba cargados.
Tutora del centro: tutora.ava@ava-pruebas.test / AVAtutor
Familiar:          familia.ava@ava-pruebas.test / AVAfamilia
Alumnos (aula 1º A): Pablo (PIN 1234), Marta (pictogramas sol → perro → flor)
Alumnos (aula 1º B): Lucía (contraseña lucia123), Javier (PIN 4321)''';
}
