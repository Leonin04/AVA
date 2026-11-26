import '../../../core/utilidades/controlador_carga.dart';
import '../../autenticacion/dominio/cuenta.dart';
import '../../autenticacion/logica/permisos.dart';
import '../../aulas/dominio/ficha_aula.dart';
import '../../aulas/dominio/repositorio_aulas.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../../perfil/dominio/repositorio_estudiantes.dart';
import '../dominio/comedor.dart';
import '../dominio/repositorio_comedor.dart';
import 'listado_cocina.dart';

/// Lo que ha respondido el estudiante para un día: `true` come, `false` no
/// come y `null` todavía no ha respondido.
typedef DiaComedor = ({DateTime dia, bool? come});

/// El estudiante marca qué días de la semana va al comedor (boceto de la
/// figura 3 del entregable 2). No ve ni puede cambiar dietas.
class ComedorEstudianteControlador extends ControladorCarga<List<DiaComedor>> {
  ComedorEstudianteControlador({
    required RepositorioComedor comedor,
    required this.estudiante,
    DateTime Function()? reloj,
  }) : _comedor = comedor,
       _reloj = reloj ?? DateTime.now;

  final RepositorioComedor _comedor;
  final Estudiante estudiante;
  final DateTime Function() _reloj;

  @override
  Future<List<DiaComedor>> obtenerDatos() async {
    final idAula = estudiante.idAula;
    if (idAula == null) {
      throw const ErrorConMensaje(
        'Todavía no tienes clase. Díselo a tu profesor.',
      );
    }
    return [
      for (final dia in CalculosComedor.diasDeLaSemana(_reloj()))
        (
          dia: dia,
          come: (await _comedor.asistencia(
            idAula: idAula,
            fecha: dia,
          ))[estudiante.id]?.come,
        ),
    ];
  }

  @override
  String get mensajeErrorCarga => 'No se ha podido abrir el comedor.';

  /// Cambia la respuesta de [dia]: si iba, ya no va, y al revés.
  /// Al marcar cualquier día de la semana, el resto de días aún sin responder
  /// se guardan como «no come» para que no figuren como pendientes.
  Future<void> cambiar(DiaComedor dia) async {
    final idAula = estudiante.idAula!;
    await Future.wait([
      _comedor.registrarAsistencia(
        idAula: idAula,
        fecha: dia.dia,
        asistencia: AsistenciaComedor(
          idEstudiante: estudiante.id,
          come: !(dia.come ?? false),
          origen: OrigenAsistencia.estudiante,
          idActor: estudiante.id,
        ),
      ),
      for (final otro in datos ?? const <DiaComedor>[])
        if (otro.dia != dia.dia && otro.come == null)
          _comedor.registrarAsistencia(
            idAula: idAula,
            fecha: otro.dia,
            asistencia: AsistenciaComedor(
              idEstudiante: estudiante.id,
              come: false,
              origen: OrigenAsistencia.estudiante,
              idActor: estudiante.id,
            ),
          ),
    ]);
    await cargar();
  }
}

/// Un estudiante del aula con su respuesta del día.
typedef FilaComedor = ({Estudiante estudiante, AsistenciaComedor? asistencia});

/// Asistencia de un aula en un día (HU-23). La usan el estudiante encargado
/// (T-113, T-114) y el tutor, que además la revisa y corrige (T-115). En
/// ningún caso se muestran dietas.
class ListaComedorControlador extends ControladorCarga<List<FilaComedor>> {
  ListaComedorControlador({
    required RepositorioComedor comedor,
    required RepositorioEstudiantes estudiantes,
    required this.aula,
    required this.fecha,
    required this.origen,
    required this.idActor,
  }) : _comedor = comedor,
       _estudiantes = estudiantes;

  final RepositorioComedor _comedor;
  final RepositorioEstudiantes _estudiantes;
  final Aula aula;
  final DateTime fecha;

  /// Encargado o tutor.
  final OrigenAsistencia origen;
  final String idActor;

  @override
  Future<List<FilaComedor>> obtenerDatos() async {
    final asistencia = await _comedor.asistencia(idAula: aula.id, fecha: fecha);
    return [
      for (final estudiante in await _estudiantes.listar(idAula: aula.id))
        if (estudiante.activo)
          (estudiante: estudiante, asistencia: asistencia[estudiante.id]),
    ];
  }

  @override
  String get mensajeErrorCarga => 'No se ha podido cargar la lista.';

  int get sinResponder => (datos ?? const <FilaComedor>[])
      .where((f) => f.asistencia == null)
      .length;

  Future<void> marcar(Estudiante estudiante, {required bool come}) async {
    await _comedor.registrarAsistencia(
      idAula: aula.id,
      fecha: fecha,
      asistencia: AsistenciaComedor(
        idEstudiante: estudiante.id,
        come: come,
        origen: origen,
        idActor: idActor,
      ),
    );
    await cargar();
  }
}

/// Dieta autorizada de un estudiante y sus cambios (HU-24). Solo la usan
/// la administración y los tutores del centro (T-117).
class DietaControlador extends ControladorCarga<(Dieta, List<CambioDieta>)> {
  DietaControlador({
    required RepositorioComedor comedor,
    required this.estudiante,
    required this.cuenta,
  }) : _comedor = comedor;

  final RepositorioComedor _comedor;
  final Estudiante estudiante;
  final Cuenta cuenta;

  @override
  Future<(Dieta, List<CambioDieta>)> obtenerDatos() async {
    if (!Permisos.puedeGestionarDietas(cuenta)) {
      throw const ErrorConMensaje(
        'Tu cuenta no puede ver la información de dietas.',
      );
    }
    return (
      await _comedor.dieta(estudiante.id) ?? Dieta(idEstudiante: estudiante.id),
      await _comedor.cambiosDieta(estudiante.id),
    );
  }

  @override
  String get mensajeErrorCarga => 'No se ha podido cargar la dieta.';

  /// Guarda la dieta (T-116) y su cambio (T-118). Devuelve un mensaje de
  /// error o `null`.
  Future<String?> guardar({
    required String tipo,
    required String alergias,
    required String indicaciones,
  }) async {
    String? error;
    if (!Permisos.puedeGestionarDietas(cuenta)) {
      error = 'Tu cuenta no puede cambiar la información de dietas.';
    } else {
      await _comedor.guardarDieta(
        Dieta(
          idEstudiante: estudiante.id,
          tipo: tipo.trim(),
          alergias: [
            for (final alergia in alergias.split(','))
              if (alergia.trim().isNotEmpty) alergia.trim(),
          ],
          indicaciones: indicaciones.trim(),
        ),
        idActor: cuenta.id,
      );
      await cargar();
    }
    return error;
  }
}

/// Panel del comedor para el tutor (HU-23 a HU-25): elegir aula y fecha,
/// revisar la asistencia, elegir al encargado y generar el listado para
/// cocina.
class ComedorTutorControlador extends ControladorCarga<List<Aula>> {
  ComedorTutorControlador({
    required RepositorioComedor comedor,
    required RepositorioEstudiantes estudiantes,
    required RepositorioAulas aulas,
    required this.cuenta,
    DateTime Function()? reloj,
  }) : _comedor = comedor,
       _estudiantes = estudiantes,
       _aulas = aulas,
       fecha = _hoy((reloj ?? DateTime.now)());

  final RepositorioComedor _comedor;
  final RepositorioEstudiantes _estudiantes;
  final RepositorioAulas _aulas;
  final Cuenta cuenta;

  static DateTime _hoy(DateTime d) => DateTime(d.year, d.month, d.day);

  Aula? aula;
  DateTime fecha;

  @override
  Future<List<Aula>> obtenerDatos() async {
    final aulas = Permisos.aulasVisibles(cuenta, await _aulas.obtenerAulas());
    final actual = aula;
    aula = actual == null
        ? aulas.firstOrNull
        : aulas.where((a) => a.id == actual.id).firstOrNull ??
              aulas.firstOrNull;
    return aulas;
  }

  @override
  String get mensajeErrorCarga => 'No se han podido cargar las aulas.';

  void elegir({Aula? aula, DateTime? fecha}) {
    this.aula = aula ?? this.aula;
    this.fecha = fecha == null ? this.fecha : _hoy(fecha);
    notifyListeners();
  }

  /// Nombra al estudiante encargado del comedor del aula elegida.
  Future<void> elegirEncargado(Estudiante? estudiante) async {
    final actual = aula;
    if (actual != null) {
      final cambiada = estudiante == null
          ? actual.copyWith(quitarEncargado: true)
          : actual.copyWith(idEncargadoComedor: estudiante.id);
      await _aulas.guardar(cambiada);
      aula = cambiada;
      await cargar();
    }
  }

  /// Listado para cocina del aula y la fecha elegidas (HU-25). Lanza
  /// [ErrorConMensaje] si no son válidas.
  Future<ListadoCocina> listado() async {
    CalculosComedor.validar(aula, fecha);
    final elegida = aula!;
    final estudiantes = await _estudiantes.listar(idAula: elegida.id);
    final dietas = <String, Dieta>{};
    if (Permisos.puedeGestionarDietas(cuenta)) {
      for (final estudiante in estudiantes) {
        final dieta = await _comedor.dieta(estudiante.id);
        if (dieta != null) dietas[estudiante.id] = dieta;
      }
    }
    return CalculosComedor.listado(
      aula: elegida,
      fecha: fecha,
      estudiantes: estudiantes,
      asistencia: await _comedor.asistencia(idAula: elegida.id, fecha: fecha),
      dietas: dietas,
    );
  }
}
