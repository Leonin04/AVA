/// Quién ha registrado la asistencia al comedor (HU-23).
enum OrigenAsistencia {
  estudiante('El alumno'),
  encargado('El encargado'),
  tutor('El tutor');

  const OrigenAsistencia(this.nombre);

  final String nombre;

  static OrigenAsistencia desde(Object? valor) =>
      OrigenAsistencia.values.firstWhere(
        (o) => o.name == valor,
        orElse: () => OrigenAsistencia.estudiante,
      );
}

/// Respuesta de un estudiante para un día: si come en el centro (HU-23).
class AsistenciaComedor {
  const AsistenciaComedor({
    required this.idEstudiante,
    required this.come,
    required this.origen,
    this.idActor,
  });

  final String idEstudiante;
  final bool come;

  /// Quién lo registró. Si es el tutor, se considera revisada (T-115).
  final OrigenAsistencia origen;
  final String? idActor;

  bool get revisadaPorTutor => origen == OrigenAsistencia.tutor;

  Map<String, Object?> toMap() => {
    'come': come,
    'origen': origen.name,
    'idActor': idActor,
  };

  factory AsistenciaComedor.fromMap(
    String idEstudiante,
    Map<Object?, Object?> datos,
  ) => AsistenciaComedor(
    idEstudiante: idEstudiante,
    come: datos['come'] as bool? ?? false,
    origen: OrigenAsistencia.desde(datos['origen']),
    idActor: datos['idActor'] as String?,
  );
}

/// Información de la dieta autorizada de un estudiante (HU-24). Es un dato
/// protegido: solo la ven y cambian la administración y los tutores del
/// centro (T-117).
class Dieta {
  const Dieta({
    required this.idEstudiante,
    this.tipo = '',
    this.alergias = const [],
    this.indicaciones = '',
  });

  final String idEstudiante;

  /// Tipo de menú autorizado, por ejemplo «Sin gluten» o «Triturado».
  final String tipo;

  /// Alergias o intolerancias.
  final List<String> alergias;

  /// Indicaciones para cocina.
  final String indicaciones;

  bool get vacia => tipo.isEmpty && alergias.isEmpty && indicaciones.isEmpty;

  /// Resumen con lo necesario para preparar la comida (T-121).
  String get resumen => [
    if (tipo.isNotEmpty) tipo,
    if (alergias.isNotEmpty) 'Alergias: ${alergias.join(', ')}',
    if (indicaciones.isNotEmpty) indicaciones,
  ].join(' · ');

  Map<String, Object?> toMap() => {
    'tipo': tipo,
    'alergias': alergias,
    'indicaciones': indicaciones,
  };

  factory Dieta.fromMap(String idEstudiante, Map<Object?, Object?> datos) =>
      Dieta(
        idEstudiante: idEstudiante,
        tipo: datos['tipo'] as String? ?? '',
        alergias: [
          for (final alergia in datos['alergias'] as List? ?? const [])
            alergia as String,
        ],
        indicaciones: datos['indicaciones'] as String? ?? '',
      );
}

/// Cambio en la dieta de un estudiante, para saber quién la cambió y cuándo
/// (T-118).
class CambioDieta {
  const CambioDieta({
    required this.momento,
    required this.idActor,
    required this.resumen,
  });

  final DateTime momento;
  final String idActor;

  /// La dieta tal como quedó tras el cambio.
  final String resumen;

  Map<String, Object?> toMap() => {
    'momento': momento.toIso8601String(),
    'idActor': idActor,
    'resumen': resumen,
  };

  factory CambioDieta.fromMap(Map<Object?, Object?> datos) => CambioDieta(
    momento: DateTime.parse(datos['momento']! as String),
    idActor: datos['idActor'] as String? ?? '',
    resumen: datos['resumen'] as String? ?? '',
  );
}

/// Una línea del listado para cocina: solo el nombre y, si la tiene, su
/// dieta (HU-25, T-121).
class LineaListadoCocina {
  const LineaListadoCocina({required this.nombre, this.dieta});

  final String nombre;
  final String? dieta;
}

/// Listado diario de comedor de un aula para cocina (HU-25).
class ListadoCocina {
  const ListadoCocina({
    required this.nombreAula,
    required this.fecha,
    required this.comensales,
    required this.sinResponder,
  });

  final String nombreAula;
  final DateTime fecha;

  /// Quienes comen, cada uno con su dieta si la tiene.
  final List<LineaListadoCocina> comensales;

  /// Cuántos no han respondido todavía (para que el tutor lo revise antes).
  final int sinResponder;

  int get conDieta => comensales.where((c) => c.dieta != null).length;
}
