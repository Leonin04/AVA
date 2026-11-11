import 'package:flutter/foundation.dart';

import '../../../core/constantes/pictogramas.dart';
import '../../../core/modelos/recurso_visual.dart';
import '../dominio/repositorio_tareas.dart';
import '../dominio/tarea_agenda.dart';

/// Actividad que el estudiante puede elegir al crear una tarea personal.
class ActividadPersonal {
  const ActividadPersonal(this.nombre, this.pictograma, this.tipo);

  final String nombre;
  final PictogramaArasaac pictograma;
  final TipoTarea tipo;

  static const catalogo = [
    ActividadPersonal('Jugar', Pictogramas.jugar, TipoTarea.ocio),
    ActividadPersonal('Leer', Pictogramas.leer, TipoTarea.personal),
    ActividadPersonal('Música', Pictogramas.musica, TipoTarea.ocio),
    ActividadPersonal('Deporte', Pictogramas.deporte, TipoTarea.ocio),
    ActividadPersonal('Descansar', Pictogramas.descansar, TipoTarea.personal),
    ActividadPersonal('Ver la tele', Pictogramas.television, TipoTarea.ocio),
    ActividadPersonal(
      'Preparar la mochila',
      Pictogramas.mochila,
      TipoTarea.personal,
    ),
    ActividadPersonal('Ir al cine', Pictogramas.cine, TipoTarea.ocio),
  ];
}

/// Pasos del asistente para crear una tarea personal.
enum PasoAsistente { que, cuando, confirmar }

/// Asistente accesible para que el estudiante cree o cambie sus tareas
/// personales (HU-04): elige qué, después cuándo y por último confirma.
class TareaEstudianteControlador extends ChangeNotifier {
  TareaEstudianteControlador({
    required RepositorioTareas repositorio,
    required this.idEstudiante,
    required DateTime hoy,
    Tarea? tareaExistente,
  }) : _repositorio = repositorio,
       _hoy = DateTime(hoy.year, hoy.month, hoy.day),
       _existente = tareaExistente {
    final tarea = tareaExistente;
    if (tarea != null) {
      _actividad = ActividadPersonal.catalogo.firstWhere(
        (a) => a.nombre == tarea.titulo,
        orElse: () => ActividadPersonal(
          tarea.titulo,
          tarea.pictograma is PictogramaArasaac
              ? tarea.pictograma! as PictogramaArasaac
              : Pictogramas.lapiz,
          tarea.tipo,
        ),
      );
      _dia = DateTime(tarea.inicio.year, tarea.inicio.month, tarea.inicio.day);
      _minutoInicio = tarea.inicio.hour * 60 + tarea.inicio.minute;
      _duracion = tarea.fin.difference(tarea.inicio).inMinutes;
    }
  }

  static const pasoMinutos = 15;
  static const duraciones = [15, 30, 60];
  static const _primerMinuto = 7 * 60;
  static const _ultimoMinuto = 22 * 60;

  final RepositorioTareas _repositorio;
  final String idEstudiante;
  final DateTime _hoy;
  final Tarea? _existente;

  PasoAsistente _paso = PasoAsistente.que;
  ActividadPersonal? _actividad;
  late DateTime _dia = _hoy;
  int _minutoInicio = 17 * 60;
  int _duracion = 30;
  bool _guardando = false;

  PasoAsistente get paso => _paso;
  ActividadPersonal? get actividad => _actividad;
  DateTime get dia => _dia;
  int get duracion => _duracion;
  bool get guardando => _guardando;
  bool get esEdicion => _existente != null;

  DateTime get inicio => DateTime(
    _dia.year,
    _dia.month,
    _dia.day,
    _minutoInicio ~/ 60,
    _minutoInicio % 60,
  );

  DateTime get fin => inicio.add(Duration(minutes: _duracion));

  /// Días que se pueden elegir: hoy y los seis siguientes.
  List<DateTime> get diasDisponibles => [
    for (var i = 0; i < 7; i++) DateTime(_hoy.year, _hoy.month, _hoy.day + i),
  ];

  void elegirActividad(ActividadPersonal actividad) {
    _actividad = actividad;
    _paso = PasoAsistente.cuando;
    notifyListeners();
  }

  void elegirDia(DateTime dia) {
    _dia = DateTime(dia.year, dia.month, dia.day);
    notifyListeners();
  }

  void elegirDuracion(int minutos) {
    _duracion = minutos;
    notifyListeners();
  }

  bool get puedeAdelantar => _minutoInicio - pasoMinutos >= _primerMinuto;
  bool get puedeRetrasar => _minutoInicio + pasoMinutos <= _ultimoMinuto;

  void adelantarHora() {
    if (!puedeAdelantar) return;
    _minutoInicio -= pasoMinutos;
    notifyListeners();
  }

  void retrasarHora() {
    if (!puedeRetrasar) return;
    _minutoInicio += pasoMinutos;
    notifyListeners();
  }

  void irAConfirmar() {
    if (_actividad == null) return;
    _paso = PasoAsistente.confirmar;
    notifyListeners();
  }

  void volver() {
    _paso = switch (_paso) {
      PasoAsistente.que || PasoAsistente.cuando => PasoAsistente.que,
      PasoAsistente.confirmar => PasoAsistente.cuando,
    };
    notifyListeners();
  }

  /// Guarda la tarea y la devuelve, o `null` si falta elegir la actividad.
  Future<Tarea?> guardar() async {
    final actividad = _actividad;
    if (actividad == null || _guardando) return null;

    _guardando = true;
    notifyListeners();
    try {
      final existente = _existente;
      final tarea = existente != null
          ? existente.copyWith(
              titulo: actividad.nombre,
              pictograma: actividad.pictograma,
              tipo: actividad.tipo,
              inicio: inicio,
              fin: fin,
            )
          : Tarea(
              id: _repositorio.nuevoId('tarea'),
              idEstudiante: idEstudiante,
              titulo: actividad.nombre,
              pictograma: actividad.pictograma,
              tipo: actividad.tipo,
              inicio: inicio,
              fin: fin,
              creadaPor: idEstudiante,
            );
      await _repositorio.guardar(tarea);
      return tarea;
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }
}
