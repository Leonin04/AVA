import 'package:ava/features/tareas/dominio/repositorio_tareas_simulado.dart';
import 'package:ava/features/tareas/dominio/tarea.dart';
import 'package:ava/features/tareas/logica/detalle_tarea_controlador.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lunes = DateTime(2026, 11, 9);
  final lunesSiguiente = DateTime(2026, 11, 16);

  test('genera tareas para los siete días de la semana, ordenadas', () async {
    final repositorio = RepositorioTareasSimulado();

    final tareas = await repositorio.obtenerTareas(
      idEstudiante: 'e01',
      desde: lunes,
      hasta: lunesSiguiente,
    );

    final dias = tareas.map((t) => t.inicio.weekday).toSet();
    expect(dias, hasLength(7));
    for (var i = 1; i < tareas.length; i++) {
      expect(tareas[i].inicio.isBefore(tareas[i - 1].inicio), isFalse);
    }
    expect(tareas.any((t) => t.tipo == TipoTarea.encargoCentro), isTrue);
  });

  test('empezar y terminar una tarea se guarda (HU-11)', () async {
    final repositorio = RepositorioTareasSimulado();
    final tareas = await repositorio.obtenerTareas(
      idEstudiante: 'e01',
      desde: lunes,
      hasta: lunesSiguiente,
    );
    final controlador = DetalleTareaControlador(
      repositorio: repositorio,
      tarea: tareas.first,
    );

    expect(controlador.puedeEmpezar, isTrue);
    expect(await controlador.empezar(), isTrue);
    expect(controlador.puedeTerminar, isTrue);
    expect(await controlador.terminar(), isTrue);

    final recargadas = await repositorio.obtenerTareas(
      idEstudiante: 'e01',
      desde: lunes,
      hasta: lunesSiguiente,
    );
    expect(recargadas.first.estado, EstadoTarea.completada);
  });
}
