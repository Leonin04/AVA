import 'package:flutter/material.dart';

import '../dominio/paso.dart';
import '../dominio/tarea.dart';

/// Un paso mientras se edita en el formulario.
/// [clave] solo sirve para que la lista reordenable distinga cada fila.
class PasoEditable {
  PasoEditable(this.clave, this.texto);
  final int clave;
  String texto;
}

/// Estado y reglas del formulario de crear / editar tarea
/// (T-66 a T-79). Las pantallas solo leen y llaman a estos métodos.
class FormularioTarea extends ChangeNotifier {
  FormularioTarea({required this.creadaPor, String? estudianteInicial}) {
    if (estudianteInicial != null) estudiantes.add(estudianteInicial);
  }

  /// Carga una tarea existente para editarla (T-79).
  FormularioTarea.editar(Tarea t, List<Paso> pasosTarea)
      : creadaPor = t.creadaPor,
        idTarea = t.id {
    nombre = t.nombre;
    descripcion = t.descripcion;
    tipo = t.tipo;
    pictogramaUrl = t.pictogramaUrl;
    horaInicio = _parsear(t.horaInicio);
    horaFin = _parsear(t.horaFin);
    diasSemana.addAll(t.diasSemana);
    fecha = t.fecha == null ? null : DateTime.tryParse(t.fecha!);
    estudiantes.addAll(t.estudiantes);
    for (final p in pasosTarea) {
      pasos.add(PasoEditable(_siguienteClave++, p.texto));
    }
  }

  final String creadaPor;
  String? idTarea; // null = tarea nueva

  String nombre = ''; // T-66
  String descripcion = ''; // T-68
  TipoTarea tipo = TipoTarea.colegio; // T-69
  String pictogramaUrl = ''; // T-70
  TimeOfDay? horaInicio; // T-71
  TimeOfDay? horaFin; // T-72
  final Set<int> diasSemana = {}; // T-73
  DateTime? fecha; // si no se repite
  final Set<String> estudiantes = {}; // T-67
  final List<PasoEditable> pasos = []; // T-74 a T-77

  int _siguienteClave = 0;

  bool get esNueva => idTarea == null;

  // ---------------- Cambios de campos ----------------
  void cambiarTipo(TipoTarea t) {
    tipo = t;
    notifyListeners();
  }

  void cambiarPictograma(String url) {
    pictogramaUrl = url;
    notifyListeners();
  }

  void cambiarHoraInicio(TimeOfDay h) {
    horaInicio = h;
    notifyListeners();
  }

  void cambiarHoraFin(TimeOfDay h) {
    horaFin = h;
    notifyListeners();
  }

  void alternarDia(int dia) {
    diasSemana.contains(dia) ? diasSemana.remove(dia) : diasSemana.add(dia);
    notifyListeners();
  }

  void cambiarFecha(DateTime? f) {
    fecha = f;
    notifyListeners();
  }

  void alternarEstudiante(String id) {
    estudiantes.contains(id) ? estudiantes.remove(id) : estudiantes.add(id);
    notifyListeners();
  }

  // ---------------- Pasos ----------------
  /// T-74
  void anadirPaso() {
    pasos.add(PasoEditable(_siguienteClave++, ''));
    notifyListeners();
  }

  /// T-75 (no avisa a la vista: el texto ya está en el campo).
  void editarPaso(int indice, String texto) {
    pasos[indice].texto = texto;
  }

  /// T-76
  void eliminarPaso(int indice) {
    pasos.removeAt(indice);
    notifyListeners();
  }

  /// T-77. Recibe los índices tal y como los da ReorderableListView.
  void reordenarPaso(int antes, int despues) {
    if (despues > antes) despues -= 1;
    final p = pasos.removeAt(antes);
    pasos.insert(despues, p);
    notifyListeners();
  }

  // ---------------- Validación (T-78) ----------------
  /// Lista de errores; vacía si se puede guardar.
  List<String> validar() {
    final e = <String>[];
    if (nombre.trim().isEmpty) e.add('Escribe el nombre de la tarea.');
    if (horaInicio == null) e.add('Elige la hora de inicio.');
    if (horaFin == null) e.add('Elige la hora de fin.');
    if (horaInicio != null &&
        horaFin != null &&
        _minutos(horaFin!) <= _minutos(horaInicio!)) {
      e.add('La hora de fin tiene que ser posterior a la de inicio.');
    }
    if (diasSemana.isEmpty && fecha == null) {
      e.add('Elige los días en que se repite o una fecha concreta.');
    }
    if (estudiantes.isEmpty) e.add('Asigna la tarea al menos a un estudiante.');
    if (pasos.any((p) => p.texto.trim().isEmpty)) {
      e.add('Hay pasos vacíos: escríbelos o elimínalos.');
    }
    return e;
  }

  // ---------------- Conversión a modelo ----------------
  Tarea aTarea() => Tarea(
        id: idTarea ?? '',
        nombre: nombre.trim(),
        descripcion: descripcion.trim(),
        tipo: tipo,
        pictogramaUrl: pictogramaUrl,
        horaInicio: formatear(horaInicio!),
        horaFin: formatear(horaFin!),
        diasSemana: diasSemana.toList()..sort(),
        fecha: fecha == null ? null : Tarea.claveFecha(fecha!),
        creadaPor: creadaPor,
        estudiantes: estudiantes.toList(),
      );

  List<Paso> aPasos() => [
        for (var i = 0; i < pasos.length; i++)
          Paso(id: '', orden: i + 1, texto: pasos[i].texto.trim()),
      ];

  // ---------------- Utilidades de hora ----------------
  static String formatear(TimeOfDay h) =>
      '${h.hour.toString().padLeft(2, '0')}:${h.minute.toString().padLeft(2, '0')}';

  static TimeOfDay? _parsear(String hhmm) {
    final partes = hhmm.split(':');
    if (partes.length != 2) return null;
    final h = int.tryParse(partes[0]);
    final m = int.tryParse(partes[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  static int _minutos(TimeOfDay h) => h.hour * 60 + h.minute;
}
