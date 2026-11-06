import 'repositorio_tareas.dart';
import 'tarea.dart';

/// Genera una rutina de prueba para cualquier estudiante mientras no se
/// conecta la base de datos.
///
/// Las tareas se crean la primera vez que se pide un día y se guardan en
/// memoria, de modo que los cambios de estado se mantienen durante la sesión.
class RepositorioTareasSimulado implements RepositorioTareas {
  final Map<String, Tarea> _tareas = {};
  final Set<String> _diasGenerados = {};

  @override
  Future<List<Tarea>> obtenerTareas({
    required String idEstudiante,
    required DateTime desde,
    required DateTime hasta,
  }) async {
    for (var dia = DateTime(desde.year, desde.month, desde.day);
        dia.isBefore(hasta);
        dia = DateTime(dia.year, dia.month, dia.day + 1)) {
      _generarDiaSiFalta(idEstudiante, dia);
    }

    final resultado = _tareas.values
        .where(
          (tarea) =>
              tarea.idEstudiante == idEstudiante &&
              !tarea.inicio.isBefore(desde) &&
              tarea.inicio.isBefore(hasta),
        )
        .toList()
      ..sort((a, b) => a.inicio.compareTo(b.inicio));
    return resultado;
  }

  @override
  Future<Tarea> actualizarEstado(String idTarea, EstadoTarea estado) async {
    final tarea = _tareas[idTarea];
    if (tarea == null) throw StateError('No existe la tarea $idTarea');

    final actualizada = tarea.copyWith(estado: estado);
    _tareas[idTarea] = actualizada;
    return actualizada;
  }

  void _generarDiaSiFalta(String idEstudiante, DateTime dia) {
    final clave = '$idEstudiante-${dia.year}-${dia.month}-${dia.day}';
    if (!_diasGenerados.add(clave)) return;

    final plantillas = _plantillasDelDia(dia.weekday);
    for (var i = 0; i < plantillas.length; i++) {
      final tarea = plantillas[i].crear(
        id: '$clave-$i',
        idEstudiante: idEstudiante,
        dia: dia,
      );
      _tareas[tarea.id] = tarea;
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
    inicio: (9, 0),
    fin: (9, 30),
    descripcion: 'Saludamos a los compañeros y repasamos el día.',
    pasos: ['Entra en clase', 'Siéntate en tu sitio', 'Escucha al tutor'],
  );

  static const _recreo = _PlantillaTarea(
    titulo: 'Recreo',
    inicio: (11, 0),
    fin: (11, 30),
    descripcion: 'Descanso en el patio.',
    pasos: [
      'Coge tu almuerzo',
      'Sal al patio',
      'Vuelve a clase cuando suene el timbre',
    ],
  );

  static const _comida = _PlantillaTarea(
    titulo: 'Comida',
    inicio: (13, 30),
    fin: (14, 30),
    descripcion: 'Comemos en el comedor.',
    pasos: ['Lávate las manos', 'Ve al comedor', 'Recoge tu bandeja al terminar'],
  );

  static const _talleres = {
    DateTime.monday: _PlantillaTarea(
      titulo: 'Taller de cocina',
      inicio: (9, 30),
      fin: (11, 0),
      descripcion: 'Preparamos una receta sencilla.',
      pasos: ['Ponte el delantal', 'Lávate las manos', 'Sigue la receta'],
    ),
    DateTime.tuesday: _PlantillaTarea(
      titulo: 'Huerto',
      inicio: (9, 30),
      fin: (11, 0),
      descripcion: 'Cuidamos las plantas del huerto.',
      pasos: ['Coge los guantes', 'Riega las plantas', 'Guarda las herramientas'],
    ),
    DateTime.wednesday: _PlantillaTarea(
      titulo: 'Informática',
      inicio: (9, 30),
      fin: (11, 0),
      descripcion: 'Practicamos con el ordenador.',
      pasos: ['Enciende el ordenador', 'Abre el programa', 'Apaga al terminar'],
    ),
    DateTime.thursday: _PlantillaTarea(
      titulo: 'Lavandería',
      inicio: (9, 30),
      fin: (11, 0),
      descripcion: 'Aprendemos a doblar y guardar la ropa.',
      pasos: ['Saca la ropa', 'Dóblala', 'Guárdala en su sitio'],
    ),
    DateTime.friday: _PlantillaTarea(
      titulo: 'Manualidades',
      inicio: (9, 30),
      fin: (11, 0),
      descripcion: 'Hacemos un trabajo manual.',
      pasos: ['Coge los materiales', 'Sigue el modelo', 'Recoge la mesa'],
    ),
  };

  static const _encargos = {
    DateTime.monday: _PlantillaTarea(
      titulo: 'Llevar fotocopias a reprografía',
      inicio: (11, 30),
      fin: (12, 0),
      tipo: TipoTarea.encargoCentro,
      descripcion: 'Encargo del centro: llevar las hojas a reprografía.',
      pasos: ['Coge las hojas del tutor', 'Ve a reprografía', 'Entrégalas'],
    ),
    DateTime.tuesday: _PlantillaTarea(
      titulo: 'Repartir el correo',
      inicio: (11, 30),
      fin: (12, 0),
      tipo: TipoTarea.encargoCentro,
      descripcion: 'Encargo del centro: repartir las cartas por las aulas.',
      pasos: ['Recoge el correo en secretaría', 'Entrega cada carta en su aula'],
    ),
    DateTime.wednesday: _PlantillaTarea(
      titulo: 'Regar las plantas del pasillo',
      inicio: (11, 30),
      fin: (12, 0),
      tipo: TipoTarea.encargoCentro,
      descripcion: 'Encargo del centro: regar las macetas del pasillo.',
      pasos: ['Llena la regadera', 'Riega cada maceta', 'Guarda la regadera'],
    ),
    DateTime.thursday: _PlantillaTarea(
      titulo: 'Poner las mesas del comedor',
      inicio: (11, 30),
      fin: (12, 0),
      tipo: TipoTarea.encargoCentro,
      descripcion: 'Encargo del centro: preparar el comedor.',
      pasos: ['Coloca los manteles', 'Pon los cubiertos', 'Pon los vasos'],
    ),
    DateTime.friday: _PlantillaTarea(
      titulo: 'Ordenar el aula',
      inicio: (11, 30),
      fin: (12, 0),
      tipo: TipoTarea.encargoCentro,
      descripcion: 'Encargo del centro: dejar el aula ordenada.',
      pasos: ['Recoge el material', 'Coloca las sillas', 'Tira los papeles'],
    ),
  };

  static const _rutinaFinDeSemana = [
    _PlantillaTarea(
      titulo: 'Hacer la cama',
      inicio: (10, 0),
      fin: (10, 15),
      descripcion: 'Dejamos la habitación ordenada.',
      pasos: ['Estira las sábanas', 'Coloca la almohada', 'Pon la colcha'],
    ),
    _PlantillaTarea(
      titulo: 'Paseo con la familia',
      inicio: (18, 0),
      fin: (19, 0),
      descripcion: 'Salimos a pasear.',
      pasos: ['Ponte los zapatos', 'Coge las llaves', 'Sal con tu familia'],
    ),
  ];
}

/// Modelo de tarea que se repite y a partir del cual se crean las tareas
/// concretas de cada día.
class _PlantillaTarea {
  const _PlantillaTarea({
    required this.titulo,
    required this.inicio,
    required this.fin,
    this.descripcion = '',
    this.pasos = const [],
    this.tipo = TipoTarea.personal,
  });

  final String titulo;
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
      inicio: DateTime(dia.year, dia.month, dia.day, inicio.$1, inicio.$2),
      fin: DateTime(dia.year, dia.month, dia.day, fin.$1, fin.$2),
    );
  }
}
