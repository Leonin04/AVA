import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/modelos/recurso_visual.dart';
import '../../../core/servicios/almacenamiento.dart';
import '../../../core/servicios/base_datos.dart';
import '../../agenda/dominio/registro.dart' as bd;
import '../../perfil/dominio/conversion_firestore.dart';
import 'paso.dart' as bd;
import 'evento_historial.dart';
import 'repositorio_tareas.dart';
import 'tarea.dart' as bd;
import 'tarea_agenda.dart';

/// Tareas en Cloud Firestore.
///
/// En la base de datos una tarea es una definición (`tareas/{id}`) que se
/// repite unos días de la semana o toca un día concreto, con sus pasos en
/// `tareas/{id}/pasos` y el estado de cada día en
/// `estudiantes/{id}/registros`. La agenda trabaja con la tarea de cada día,
/// cuyo identificador es `{idTarea}|{yyyy-MM-dd}`.
///
/// Además del esquema, guarda `categoria` (clase, personal, ocio, casa o
/// encargo) para conservar el color de cada tipo.
class RepositorioTareasFirebase implements RepositorioTareas {
  RepositorioTareasFirebase({
    BaseDatos? baseDatos,
    Almacenamiento? almacenamiento,
    FirebaseFirestore? firestore,
  }) : _bd = baseDatos ?? BaseDatos(),
       _almacenamiento = almacenamiento ?? Almacenamiento(),
       _db = firestore ?? FirebaseFirestore.instance;

  static const _separador = '|';

  final BaseDatos _bd;
  final Almacenamiento _almacenamiento;
  final FirebaseFirestore _db;

  /// Tareas del día ya mostradas, para poder actualizar su estado.
  final Map<String, Tarea> _cache = {};
  final Map<String, List<PasoTarea>> _pasos = {};

  CollectionReference<Map<String, dynamic>> get _tareas =>
      _db.collection('tareas');

  static String _idBase(String id) => id.split(_separador).first;

  @override
  Future<List<Tarea>> obtenerTareas({
    required String idEstudiante,
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final estudiante = await _bd.obtenerEstudiante(idEstudiante);
    if (estudiante == null) return const [];

    // Las suyas y los encargos de su aula (HU-08), sin repetir.
    final consultas = [
      _tareas.where('estudiantes', arrayContains: idEstudiante).get(),
      if (estudiante.aulaId != null)
        _tareas.where('aulaId', isEqualTo: estudiante.aulaId).get(),
    ];
    final documentos = {
      for (final resultado in await Future.wait(consultas))
        for (final doc in resultado.docs) doc.id: doc,
    };

    final resultado = <Tarea>[];
    for (
      var dia = DateTime(desde.year, desde.month, desde.day);
      dia.isBefore(hasta);
      dia = DateTime(dia.year, dia.month, dia.day + 1)
    ) {
      final registros = {
        for (final r in await _bd.registrosDelDia(idEstudiante, dia).first)
          r.tareaId: r,
      };
      final delDia = [
        for (final doc in documentos.values)
          if (bd.Tarea.fromDoc(doc) case final base when base.esParaDia(dia))
            (doc: doc, base: base),
      ];
      for (final (:doc, :base) in delDia) {
        final registro = registros[base.id];
        final datos = doc.data();
        final tarea = Tarea(
          id: '${base.id}$_separador${bd.Tarea.claveFecha(dia)}',
          idEstudiante: idEstudiante,
          titulo: base.nombre,
          descripcion: base.descripcion,
          pasos: await _pasosDe(base.id),
          inicio: _hora(dia, base.horaInicio),
          fin: _fin(dia, base.horaInicio, base.horaFin),
          tipo: _tipoDesde(datos, base),
          estado: _estadoDesde(registro?.estado),
          pictograma: RecursoVisual.desdeUrl(base.pictogramaUrl),
          creadaPor: base.creadaPor,
          idEncargo: _esEncargo(base) ? base.id : null,
          diasSemana: base.diasSemana,
          temporizador: datos['temporizador'] as bool? ?? false,
          avisoMinutos: (datos['avisoMinutos'] as num?)?.toInt(),
          pasoActual: registro?.pasoActual ?? 0,
        );
        _cache[tarea.id] = tarea;
        resultado.add(tarea);
      }
    }
    return resultado..sort((a, b) => a.inicio.compareTo(b.inicio));
  }

  @override
  Future<void> guardar(Tarea tarea) async {
    final idBase = _idBase(tarea.id);
    // Las tareas ya guardadas llegan con el día en su identificador
    // («id|yyyy-MM-dd»). Una nueva no se lee: las reglas no dejan leer un
    // documento que todavía no existe.
    bd.Tarea? anterior;
    if (tarea.id.contains(_separador)) {
      final doc = await _tareas.doc(idBase).get();
      if (doc.exists) anterior = bd.Tarea.fromDoc(doc);
    }

    final definicion = bd.Tarea(
      id: idBase,
      nombre: tarea.titulo,
      pictogramaUrl: tarea.pictograma?.url ?? '',
      descripcion: tarea.descripcion,
      tipo: _tipoA(tarea.tipo),
      horaInicio: _textoHora(tarea.inicio),
      horaFin: _textoHora(tarea.fin),
      // HU-14: los días elegidos. Al cambiarlos se actualizan las próximas
      // apariciones; los registros y su historial no se tocan.
      diasSemana: tarea.diasSemana,
      fecha: bd.Tarea.claveFecha(tarea.inicio),
      creadaPor: anterior?.creadaPor ?? tarea.creadaPor ?? '',
      estudiantes: anterior?.estudiantes ?? [tarea.idEstudiante],
      aulaId: anterior?.aulaId,
    );
    await _guardarDefinicion(definicion, tarea, existe: anterior != null);
  }

  @override
  Future<void> crearEncargo(
    Tarea plantilla, {
    required Set<String> idsEstudiantes,
    String? idAula,
  }) async {
    final definicion = bd.Tarea(
      id: '',
      nombre: plantilla.titulo,
      pictogramaUrl: plantilla.pictograma?.url ?? '',
      descripcion: plantilla.descripcion,
      horaInicio: _textoHora(plantilla.inicio),
      horaFin: _textoHora(plantilla.fin),
      fecha: bd.Tarea.claveFecha(plantilla.inicio),
      creadaPor: plantilla.creadaPor ?? '',
      // Para un aula se guarda el aula: así llega también a los alumnos que
      // se incorporen después.
      estudiantes: idAula == null ? idsEstudiantes.toList() : const [],
      aulaId: idAula,
    );
    await _guardarDefinicion(definicion, plantilla, existe: false);
  }

  Future<void> _guardarDefinicion(
    bd.Tarea definicion,
    Tarea tarea, {
    required bool existe,
  }) async {
    final foto = ConversionFirestore.fotoIncrustada(tarea.pictograma);
    final sinFoto = foto == null ? definicion : _conPictograma(definicion, '');

    // Los pasos con foto propia se guardan primero sin ella; las fotos se
    // suben después, cuando ya se conoce el id de la tarea (HU-20).
    final String id;
    final pasosSinFotos = _pasosA(tarea.pasos, urls: const {});
    if (existe) {
      await _bd.actualizarTarea(sinFoto, pasosSinFotos);
      id = definicion.id;
    } else {
      id = await _bd.crearTarea(sinFoto, pasosSinFotos);
    }

    final urls = <int, String>{};
    for (final (i, paso) in tarea.pasos.indexed) {
      final fotoPaso = ConversionFirestore.fotoIncrustada(paso.imagen);
      if (fotoPaso != null) {
        urls[i] = await _almacenamiento.subirImagenTarea(
          '$id-paso-${i + 1}',
          fotoPaso.bytes,
          tipo: fotoPaso.tipo,
        );
      }
    }
    if (urls.isNotEmpty) {
      await _bd.actualizarTarea(
        _conId(sinFoto, id),
        _pasosA(tarea.pasos, urls: urls),
      );
    }

    final extras = <String, Object?>{
      'categoria': tarea.tipo.name,
      'temporizador': tarea.temporizador,
      'avisoMinutos': tarea.avisoMinutos,
    };
    if (foto != null) {
      extras['pictogramaUrl'] = await _almacenamiento.subirImagenTarea(
        id,
        foto.bytes,
        tipo: foto.tipo,
      );
    }
    await _tareas.doc(id).update(extras);
    _pasos.remove(id);
  }

  /// Pasos para la base de datos. Las fotos incrustadas se sustituyen por
  /// su dirección en [urls] (por posición) o se dejan sin imagen.
  static List<bd.Paso> _pasosA(
    List<PasoTarea> pasos, {
    required Map<int, String> urls,
  }) => [
    for (final (i, paso) in pasos.indexed)
      bd.Paso(
        id: '',
        orden: i + 1,
        texto: paso.texto,
        imagenUrl:
            urls[i] ??
            (ConversionFirestore.fotoIncrustada(paso.imagen) == null
                ? paso.imagen?.url ?? ''
                : ''),
      ),
  ];

  @override
  Future<void> eliminar(String idTarea) async {
    final idBase = _idBase(idTarea);
    await _bd.eliminarTarea(idBase);
    _cache.removeWhere((id, _) => _idBase(id) == idBase);
    _pasos.remove(idBase);
  }

  Tarea _enCache(String idTarea) {
    final tarea = _cache[idTarea];
    if (tarea == null) throw StateError('No se encuentra la tarea $idTarea');
    return tarea;
  }

  static DateTime _diaDe(Tarea tarea) =>
      DateTime(tarea.inicio.year, tarea.inicio.month, tarea.inicio.day);

  @override
  Future<Tarea> actualizarEstado(
    String idTarea,
    EstadoTarea estado, {
    OrigenCambio origen = OrigenCambio.estudiante,
    String? idActor,
  }) async {
    final tarea = _enCache(idTarea);
    await _bd.registrarEstado(
      tarea.idEstudiante,
      _idBase(idTarea),
      _diaDe(tarea),
      estadoNuevo: _estadoA(estado),
      estadoAnterior: _estadoA(tarea.estado),
      origen: origen.name,
      actorUid: idActor,
    );
    final actualizada = tarea.copyWith(estado: estado);
    _cache[idTarea] = actualizada;
    return actualizada;
  }

  @override
  Future<Tarea> guardarPasoActual(String idTarea, int paso) async {
    final tarea = _enCache(idTarea);
    await _bd.guardarPasoActual(
      tarea.idEstudiante,
      _idBase(idTarea),
      _diaDe(tarea),
      paso,
    );
    final actualizada = tarea.copyWith(pasoActual: paso);
    _cache[idTarea] = actualizada;
    return actualizada;
  }

  @override
  Future<List<EventoHistorial>> historial({
    required String idEstudiante,
    required DateTime desde,
    required DateTime hasta,
  }) async {
    final registros = await _bd.historialDe(idEstudiante, desde, hasta);
    final nombres = <String, String>{};
    final eventos = <EventoHistorial>[];
    for (final (registro, cambios) in registros) {
      final titulo = nombres[registro.tareaId] ??= await _nombreTarea(
        registro.tareaId,
      );
      for (final cambio in cambios) {
        final momento = (cambio['fechaHora'] as Timestamp?)?.toDate();
        if (momento != null) {
          eventos.add(
            EventoHistorial(
              idEstudiante: idEstudiante,
              idTarea: registro.tareaId,
              tituloTarea: titulo,
              dia: DateTime.parse(registro.fecha),
              estadoAnterior: cambio['estadoAnterior'] == null
                  ? null
                  : _estadoDesde(
                      bd.EstadoTarea.values.byName(
                        cambio['estadoAnterior'] as String,
                      ),
                    ),
              estadoNuevo: _estadoDesde(
                bd.EstadoTarea.values.byName(
                  cambio['estadoNuevo'] as String? ?? 'pendiente',
                ),
              ),
              momento: momento,
              origen: OrigenCambio.desde(cambio['origen']),
              idActor: cambio['actorUid'] as String?,
            ),
          );
        }
      }
    }
    return eventos..sort((a, b) => a.momento.compareTo(b.momento));
  }

  /// Nombre de una tarea para el historial. Si se ha borrado, el historial
  /// se conserva igualmente.
  Future<String> _nombreTarea(String idBase) async {
    final doc = await _tareas.doc(idBase).get();
    return doc.data()?['nombre'] as String? ?? 'Tarea borrada';
  }

  static EstadoTarea _estadoDesde(bd.EstadoTarea? estado) => switch (estado) {
    bd.EstadoTarea.iniciada => EstadoTarea.enCurso,
    bd.EstadoTarea.terminada => EstadoTarea.completada,
    _ => EstadoTarea.pendiente,
  };

  static bd.EstadoTarea _estadoA(EstadoTarea estado) => switch (estado) {
    EstadoTarea.pendiente => bd.EstadoTarea.pendiente,
    EstadoTarea.enCurso => bd.EstadoTarea.iniciada,
    EstadoTarea.completada => bd.EstadoTarea.terminada,
  };

  @override
  String nuevoId(String prefijo) => _bd.nuevoId('tareas');

  Future<List<PasoTarea>> _pasosDe(String idBase) async => _pasos[idBase] ??= [
    for (final paso in await _bd.pasosDe(idBase))
      if (paso.texto.trim().isNotEmpty)
        PasoTarea(paso.texto, imagen: RecursoVisual.desdeUrl(paso.imagenUrl)),
  ];

  static bd.Tarea _conId(bd.Tarea t, String id) => bd.Tarea(
    id: id,
    nombre: t.nombre,
    pictogramaUrl: t.pictogramaUrl,
    descripcion: t.descripcion,
    tipo: t.tipo,
    horaInicio: t.horaInicio,
    horaFin: t.horaFin,
    diasSemana: t.diasSemana,
    fecha: t.fecha,
    creadaPor: t.creadaPor,
    estudiantes: t.estudiantes,
    aulaId: t.aulaId,
  );

  static bd.Tarea _conPictograma(bd.Tarea t, String url) => bd.Tarea(
    id: t.id,
    nombre: t.nombre,
    pictogramaUrl: url,
    descripcion: t.descripcion,
    tipo: t.tipo,
    horaInicio: t.horaInicio,
    horaFin: t.horaFin,
    diasSemana: t.diasSemana,
    fecha: t.fecha,
    creadaPor: t.creadaPor,
    estudiantes: t.estudiantes,
    aulaId: t.aulaId,
  );

  static bool _esEncargo(bd.Tarea t) =>
      t.aulaId != null || t.estudiantes.length > 1;

  static TipoTarea _tipoDesde(Map<String, dynamic> datos, bd.Tarea base) {
    final categoria = datos['categoria'] as String?;
    for (final tipo in TipoTarea.values) {
      if (tipo.name == categoria) return tipo;
    }
    if (_esEncargo(base)) return TipoTarea.encargoCentro;
    return base.tipo == bd.TipoTarea.personal
        ? TipoTarea.personal
        : TipoTarea.escolar;
  }

  /// En el esquema solo hay «colegio» y «personal».
  static bd.TipoTarea _tipoA(TipoTarea tipo) => switch (tipo) {
    TipoTarea.escolar || TipoTarea.encargoCentro => bd.TipoTarea.colegio,
    _ => bd.TipoTarea.personal,
  };

  static String _textoHora(DateTime fecha) =>
      '${fecha.hour.toString().padLeft(2, '0')}:'
      '${fecha.minute.toString().padLeft(2, '0')}';

  static DateTime _hora(DateTime dia, String texto) {
    final partes = texto.split(':');
    final hora = int.tryParse(partes.first) ?? 0;
    final minuto = partes.length > 1 ? int.tryParse(partes[1]) ?? 0 : 0;
    return DateTime(dia.year, dia.month, dia.day, hora, minuto);
  }

  /// Hora de fin; si en la base de datos no es posterior al inicio, se
  /// considera que dura media hora.
  static DateTime _fin(DateTime dia, String inicio, String fin) {
    final desde = _hora(dia, inicio);
    final hasta = _hora(dia, fin);
    return hasta.isAfter(desde)
        ? hasta
        : desde.add(const Duration(minutes: 30));
  }
}
