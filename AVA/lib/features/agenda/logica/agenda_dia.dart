import '../../tareas/dominio/tarea.dart';
import '../dominio/registro.dart';

/// Lógica de la agenda del día, sin Flutter ni Firebase
/// (así se puede probar con tests unitarios).

/// T-81: de todas las tareas del estudiante, las que tocan el [dia] indicado.
/// T-82: ordenadas por hora de inicio (y por hora de fin si empiezan a la vez).
List<Tarea> tareasDelDia(List<Tarea> todas, DateTime dia) {
  final lista = todas.where((t) => t.esParaDia(dia)).toList();
  lista.sort((a, b) {
    final c = a.horaInicio.compareTo(b.horaInicio); // "HH:mm" se ordena como texto
    return c != 0 ? c : a.horaFin.compareTo(b.horaFin);
  });
  return lista;
}

const _diasSemana = [
  'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo',
];
const _meses = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio',
  'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

/// "Sábado, 7 de noviembre" para la cabecera de la agenda.
String fechaLarga(DateTime d) {
  final dia = _diasSemana[d.weekday - 1];
  return '${dia[0].toUpperCase()}${dia.substring(1)}, ${d.day} de ${_meses[d.month - 1]}';
}

/// Estado de una tarea según los registros del día (HU-12).
EstadoTarea estadoDe(Tarea t, List<Registro> registros) {
  for (final r in registros) {
    if (r.tareaId == t.id) return r.estado;
  }
  return EstadoTarea.pendiente;
}

/// HU-11: la siguiente tarea pendiente del día (la primera, por hora,
/// que no está terminada). null si ya no queda ninguna.
/// [deHoy] tiene que venir ya ordenada (usar [tareasDelDia]).
Tarea? siguienteTarea(List<Tarea> deHoy, List<Registro> registros) {
  for (final t in deHoy) {
    if (estadoDe(t, registros) != EstadoTarea.terminada) return t;
  }
  return null;
}
