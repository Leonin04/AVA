import '../../../core/constantes/pictogramas.dart';
import '../../../core/modelos/recurso_visual.dart';
import '../../../core/servicios/almacen_simulado.dart';
import 'repositorio_tareas.dart';
import 'tarea_agenda.dart';

/// Tareas guardadas en el [AlmacenSimulado].
///
/// La primera vez que se consulta un día de un estudiante se le crea una
/// rutina de ejemplo. Después, las tareas se pueden modificar o borrar
/// como cualquier otra.
class RepositorioTareasSimulado implements RepositorioTareas {
  RepositorioTareasSimulado(this._almacen);

  static const coleccion = 'tareas';
  static const _coleccionDias = 'dias_con_rutina';

  final AlmacenSimulado _almacen;

  @override
  Future<List<Tarea>> obtenerTareas({
    required String idEstudiante,
    required DateTime desde,
    required DateTime hasta,
  }) async {
    for (
      var dia = DateTime(desde.year, desde.month, desde.day);
      dia.isBefore(hasta);
      dia = DateTime(dia.year, dia.month, dia.day + 1)
    ) {
      _crearRutinaSiFalta(idEstudiante, dia);
    }

    final tareas = [
      for (final (id, datos) in _almacen.listar(
        coleccion,
        donde: (d) => d['idEstudiante'] == idEstudiante,
      ))
        Tarea.fromMap(id, datos),
    ].where((t) => !t.inicio.isBefore(desde) && t.inicio.isBefore(hasta));

    return tareas.toList()..sort((a, b) => a.inicio.compareTo(b.inicio));
  }

  @override
  Future<void> guardar(Tarea tarea) async {
    _almacen.guardar(coleccion, tarea.id, tarea.toMap());
  }

  @override
  Future<void> crearEncargo(
    Tarea plantilla, {
    required Set<String> idsEstudiantes,
    String? idAula,
  }) async {
    // Aquí no hay consultas por aula: se crea una copia para cada alumno.
    for (final idEstudiante in idsEstudiantes) {
      final copia = Tarea(
        id: nuevoId('tarea'),
        idEstudiante: idEstudiante,
        titulo: plantilla.titulo,
        descripcion: plantilla.descripcion,
        pasos: plantilla.pasos,
        inicio: plantilla.inicio,
        fin: plantilla.fin,
        tipo: plantilla.tipo,
        pictograma: plantilla.pictograma,
        creadaPor: plantilla.creadaPor,
        idEncargo: plantilla.id,
      );
      _almacen.guardar(coleccion, copia.id, copia.toMap());
    }
  }

  @override
  Future<void> eliminar(String idTarea) async {
    _almacen.eliminar(coleccion, idTarea);
  }

  @override
  Future<Tarea> actualizarEstado(String idTarea, EstadoTarea estado) async {
    final datos = _almacen.obtener(coleccion, idTarea);
    if (datos == null) throw StateError('No existe la tarea $idTarea');

    final actualizada = Tarea.fromMap(idTarea, datos).copyWith(estado: estado);
    _almacen.guardar(coleccion, idTarea, actualizada.toMap());
    return actualizada;
  }

  @override
  String nuevoId(String prefijo) => _almacen.nuevoId(prefijo);

  void _crearRutinaSiFalta(String idEstudiante, DateTime dia) {
    final clave = '$idEstudiante-${dia.year}-${dia.month}-${dia.day}';
    if (_almacen.existe(_coleccionDias, clave)) return;
    _almacen.guardar(_coleccionDias, clave, const {});

    final plantillas = _plantillasDelDia(dia.weekday);
    for (var i = 0; i < plantillas.length; i++) {
      final tarea = plantillas[i].crear(
        id: '$clave-$i',
        idEstudiante: idEstudiante,
        dia: dia,
      );
      _almacen.guardar(coleccion, tarea.id, tarea.toMap());
    }
  }

  static List<_PlantillaTarea> _plantillasDelDia(int diaSemana) {
    if (diaSemana == DateTime.saturday || diaSemana == DateTime.sunday) {
      return _rutinaFinDeSemana;
    }
    return [
      _asamblea,
      _talleres[diaSemana]!,
      _recreo,
      _encargos[diaSemana]!,
      _comida,
    ];
  }

  static const _asamblea = _PlantillaTarea(
    titulo: 'Asamblea',
    pictograma: Pictogramas.asamblea,
    inicio: (9, 0),
    fin: (9, 30),
    descripcion: 'Saludamos a los compañeros y vemos qué hacemos hoy.',
    pasos: ['Entra en clase.', 'Siéntate en tu sitio.', 'Escucha al profesor.'],
  );

  static const _recreo = _PlantillaTarea(
    titulo: 'Recreo',
    pictograma: Pictogramas.recreo,
    tipo: TipoTarea.ocio,
    inicio: (11, 0),
    fin: (11, 30),
    descripcion: 'Descansamos en el patio.',
    pasos: [
      'Coge tu almuerzo.',
      'Sal al patio.',
      'Vuelve a clase cuando suene el timbre.',
    ],
  );

  static const _comida = _PlantillaTarea(
    titulo: 'Comida',
    pictograma: Pictogramas.comer,
    inicio: (13, 30),
    fin: (14, 30),
    descripcion: 'Comemos en el comedor.',
    pasos: [
      'Lávate las manos.',
      'Ve al comedor.',
      'Recoge tu bandeja al terminar.',
    ],
  );

  static const _talleres = {
    DateTime.monday: _PlantillaTarea(
      titulo: 'Taller de cocina',
      pictograma: Pictogramas.cocinar,
      inicio: (9, 30),
      fin: (11, 0),
      descripcion: 'Hacemos una receta fácil.',
      pasos: ['Ponte el delantal.', 'Lávate las manos.', 'Sigue la receta.'],
    ),
    DateTime.tuesday: _PlantillaTarea(
      titulo: 'Huerto',
      pictograma: Pictogramas.huerto,
      inicio: (9, 30),
      fin: (11, 0),
      descripcion: 'Cuidamos las plantas del huerto.',
      pasos: [
        'Coge los guantes.',
        'Riega las plantas.',
        'Guarda las herramientas.',
      ],
    ),
    DateTime.wednesday: _PlantillaTarea(
      titulo: 'Informática',
      pictograma: Pictogramas.ordenador,
      inicio: (9, 30),
      fin: (11, 0),
      descripcion: 'Practicamos con el ordenador.',
      pasos: [
        'Enciende el ordenador.',
        'Abre el programa.',
        'Apaga el ordenador al terminar.',
      ],
    ),
    DateTime.thursday: _PlantillaTarea(
      titulo: 'Lavandería',
      pictograma: Pictogramas.lavadora,
      inicio: (9, 30),
      fin: (11, 0),
      descripcion: 'Doblamos y guardamos la ropa.',
      pasos: ['Saca la ropa.', 'Dobla la ropa.', 'Guarda la ropa en su sitio.'],
    ),
    DateTime.friday: _PlantillaTarea(
      titulo: 'Manualidades',
      pictograma: Pictogramas.manualidades,
      inicio: (9, 30),
      fin: (11, 0),
      descripcion: 'Hacemos un trabajo con las manos.',
      pasos: ['Coge los materiales.', 'Mira el modelo.', 'Recoge la mesa.'],
    ),
  };

  static const _encargos = {
    DateTime.monday: _PlantillaTarea(
      titulo: 'Llevar fotocopias',
      pictograma: Pictogramas.fotocopiadora,
      inicio: (11, 30),
      fin: (12, 0),
      tipo: TipoTarea.encargoCentro,
      descripcion: 'Llevamos las hojas a reprografía.',
      pasos: [
        'Coge las hojas del profesor.',
        'Ve a reprografía.',
        'Entrega las hojas.',
      ],
    ),
    DateTime.tuesday: _PlantillaTarea(
      titulo: 'Repartir el correo',
      pictograma: Pictogramas.correo,
      inicio: (11, 30),
      fin: (12, 0),
      tipo: TipoTarea.encargoCentro,
      descripcion: 'Llevamos las cartas a cada clase.',
      pasos: [
        'Recoge el correo en secretaría.',
        'Entrega cada carta en su clase.',
      ],
    ),
    DateTime.wednesday: _PlantillaTarea(
      titulo: 'Regar las plantas',
      pictograma: Pictogramas.regar,
      inicio: (11, 30),
      fin: (12, 0),
      tipo: TipoTarea.encargoCentro,
      descripcion: 'Regamos las macetas del pasillo.',
      pasos: [
        'Llena la regadera.',
        'Riega cada maceta.',
        'Guarda la regadera.',
      ],
    ),
    DateTime.thursday: _PlantillaTarea(
      titulo: 'Poner la mesa',
      pictograma: Pictogramas.ponerLaMesa,
      inicio: (11, 30),
      fin: (12, 0),
      tipo: TipoTarea.encargoCentro,
      descripcion: 'Preparamos las mesas del comedor.',
      pasos: ['Pon los manteles.', 'Pon los cubiertos.', 'Pon los vasos.'],
    ),
    DateTime.friday: _PlantillaTarea(
      titulo: 'Ordenar la clase',
      pictograma: Pictogramas.ordenar,
      inicio: (11, 30),
      fin: (12, 0),
      tipo: TipoTarea.encargoCentro,
      descripcion: 'Dejamos la clase ordenada.',
      pasos: ['Recoge el material.', 'Coloca las sillas.', 'Tira los papeles.'],
    ),
  };

  static const _rutinaFinDeSemana = [
    _PlantillaTarea(
      titulo: 'Hacer la cama',
      pictograma: Pictogramas.hacerLaCama,
      tipo: TipoTarea.domestica,
      inicio: (10, 0),
      fin: (10, 15),
      descripcion: 'Dejamos la habitación ordenada.',
      pasos: ['Estira las sábanas.', 'Coloca la almohada.', 'Pon la colcha.'],
    ),
    _PlantillaTarea(
      titulo: 'Pasear con la familia',
      pictograma: Pictogramas.pasear,
      tipo: TipoTarea.ocio,
      inicio: (18, 0),
      fin: (19, 0),
      descripcion: 'Salimos a pasear.',
      pasos: ['Ponte los zapatos.', 'Coge las llaves.', 'Sal con tu familia.'],
    ),
  ];
}

/// Modelo de tarea que se repite, a partir del cual se crean las tareas
/// concretas de cada día.
class _PlantillaTarea {
  const _PlantillaTarea({
    required this.titulo,
    required this.pictograma,
    required this.inicio,
    required this.fin,
    this.descripcion = '',
    this.pasos = const [],
    this.tipo = TipoTarea.escolar,
  });

  final String titulo;
  final PictogramaArasaac pictograma;
  final (int hora, int minuto) inicio;
  final (int hora, int minuto) fin;
  final String descripcion;
  final List<String> pasos;
  final TipoTarea tipo;

  Tarea crear({
    required String id,
    required String idEstudiante,
    required DateTime dia,
  }) {
    return Tarea(
      id: id,
      idEstudiante: idEstudiante,
      titulo: titulo,
      descripcion: descripcion,
      pasos: pasos,
      tipo: tipo,
      pictograma: pictograma,
      creadaPor: 'rutina',
      inicio: DateTime(dia.year, dia.month, dia.day, inicio.$1, inicio.$2),
      fin: DateTime(dia.year, dia.month, dia.day, fin.$1, fin.$2),
    );
  }
}
