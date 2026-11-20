import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/modelos/recurso_visual.dart';
import '../../../core/servicios/almacenamiento.dart';
import '../../../core/servicios/base_datos.dart';
import '../../agenda/dominio/registro.dart' as bd;
import '../../perfil/dominio/conversion_firestore.dart';
import 'paso.dart' as bd;
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
  final Map<String, List<String>> _pasos = {};

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
          r.tareaId: r.estado,
      };
      final delDia = [
        for (final doc in documentos.values)
          if (bd.Tarea.fromDoc(doc) case final base when base.esParaDia(dia))
            (doc: doc, base: base),
      ];
      for (final (:doc, :base) in delDia) {
        final tarea = Tarea(
          id: '${base.id}$_separador${bd.Tarea.claveFecha(dia)}',
          idEstudiante: idEstudiante,
          titulo: base.nombre,
          descripcion: base.descripcion,
          pasos: await _pasosDe(base.id),
          inicio: _hora(dia, base.horaInicio),
          fin: _fin(dia, base.horaInicio, base.horaFin),
          tipo: _tipoDesde(doc.data(), base),
          estado: switch (registros[base.id]) {
            bd.EstadoTarea.iniciada => EstadoTarea.enCurso,
            bd.EstadoTarea.terminada => EstadoTarea.completada,
            _ => EstadoTarea.pendiente,
          },
          pictograma: RecursoVisual.desdeUrl(base.pictogramaUrl),
          creadaPor: base.creadaPor,
          idEncargo: _esEncargo(base) ? base.id : null,
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
    bd.Tarea? anterior;
    try {
      final doc = await _tareas.doc(idBase).get();
      if (doc.exists) anterior = bd.Tarea.fromDoc(doc);
    } catch (_) {
      anterior = null;
    }

    final definicion = bd.Tarea(
      id: idBase,
      nombre: tarea.titulo,
      pictogramaUrl: tarea.pictograma?.url ?? '',
      descripcion: tarea.descripcion,
      tipo: _tipoA(tarea.tipo),
      horaInicio: _textoHora(tarea.inicio),
      horaFin: _textoHora(tarea.fin),
      // Una tarea que se repite sigue repitiéndose; si no, es de ese día.
      diasSemana: anterior?.diasSemana ?? const [],
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
    final pasos = [
      for (final (i, texto) in tarea.pasos.indexed)
        bd.Paso(id: '', orden: i + 1, texto: texto),
    ];
    final foto = ConversionFirestore.fotoIncrustada(tarea.pictograma);
    final sinFoto = foto == null ? definicion : _conPictograma(definicion, '');

    final String id;
    if (existe) {
      await _bd.actualizarTarea(sinFoto, pasos);
      id = definicion.id;
    } else {
      id = await _bd.crearTarea(sinFoto, pasos);
    }

    final extras = <String, Object?>{'categoria': tarea.tipo.name};
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

  @override
  Future<void> eliminar(String idTarea) async {
    final idBase = _idBase(idTarea);
    await _bd.eliminarTarea(idBase);
    _cache.removeWhere((id, _) => _idBase(id) == idBase);
    _pasos.remove(idBase);
  }

  @override
  Future<Tarea> actualizarEstado(String idTarea, EstadoTarea estado) async {
    final tarea = _cache[idTarea];
    if (tarea == null) throw StateError('No se encuentra la tarea $idTarea');

    final dia = DateTime(
      tarea.inicio.year,
      tarea.inicio.month,
      tarea.inicio.day,
    );
    final idBase = _idBase(idTarea);
    // Volver a «pendiente» no se registra: solo se guardan inicio y fin.
    if (estado == EstadoTarea.enCurso) {
      await _bd.marcarInicio(tarea.idEstudiante, idBase, dia);
    } else if (estado == EstadoTarea.completada) {
      await _bd.marcarFin(tarea.idEstudiante, idBase, dia);
    }
    final actualizada = tarea.copyWith(estado: estado);
    _cache[idTarea] = actualizada;
    return actualizada;
  }

  @override
  String nuevoId(String prefijo) => _bd.nuevoId('tareas');

  Future<List<String>> _pasosDe(String idBase) async => _pasos[idBase] ??= [
    for (final paso in await _bd.pasosDe(idBase))
      if (paso.texto.trim().isNotEmpty) paso.texto,
  ];

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
