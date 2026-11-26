import '../../../core/utilidades/controlador_carga.dart';
import '../../aulas/dominio/ficha_aula.dart';
import '../../perfil/dominio/perfil_estudiante.dart';
import '../dominio/comedor.dart';

/// Cálculos del comedor, sin interfaz ni base de datos.
abstract final class CalculosComedor {
  /// El comedor abre de lunes a viernes.
  static bool esDiaDeComedor(DateTime fecha) =>
      fecha.weekday >= DateTime.monday && fecha.weekday <= DateTime.friday;

  /// [fecha] si abre el comedor ese día; si es fin de semana, el lunes
  /// siguiente.
  static DateTime proximoDiaDeComedor(DateTime fecha) {
    final dia = DateTime(fecha.year, fecha.month, fecha.day);
    return esDiaDeComedor(dia) ? dia : diasDeLaSemana(dia).first;
  }

  /// Días de comedor (lunes a viernes) de la semana de [referencia]. En fin
  /// de semana, los de la semana siguiente.
  static List<DateTime> diasDeLaSemana(DateTime referencia) {
    final dia = DateTime(referencia.year, referencia.month, referencia.day);
    final lunes = esDiaDeComedor(dia)
        ? dia.subtract(Duration(days: dia.weekday - DateTime.monday))
        : dia.add(Duration(days: 8 - dia.weekday));
    return [
      for (var i = 0; i < 5; i++)
        DateTime(lunes.year, lunes.month, lunes.day + i),
    ];
  }

  /// Comprueba el aula y la fecha del listado (T-121). Lanza
  /// [ErrorConMensaje] si no son válidas.
  static void validar(Aula? aula, DateTime? fecha) {
    if (aula == null) throw const ErrorConMensaje('Elige un aula.');
    if (fecha == null) throw const ErrorConMensaje('Elige una fecha.');
    if (!esDiaDeComedor(fecha)) {
      throw const ErrorConMensaje(
        'El comedor solo abre de lunes a viernes. Elige otro día.',
      );
    }
  }

  /// Listado diario para cocina (HU-25, T-119 a T-121) a partir de la
  /// asistencia y de las dietas autorizadas. Solo lleva el nombre de quien
  /// come y, si la tiene, su dieta: nada más de su ficha.
  static ListadoCocina listado({
    required Aula aula,
    required DateTime fecha,
    required List<Estudiante> estudiantes,
    required Map<String, AsistenciaComedor> asistencia,
    required Map<String, Dieta> dietas,
  }) {
    validar(aula, fecha);
    final activos = estudiantes.where((e) => e.activo).toList();
    final comensales = [
      for (final estudiante in activos)
        if (asistencia[estudiante.id]?.come ?? false)
          LineaListadoCocina(
            nombre: estudiante.nombre,
            dieta: switch (dietas[estudiante.id]) {
              final Dieta dieta when !dieta.vacia => dieta.resumen,
              _ => null,
            },
          ),
    ]..sort((a, b) => a.nombre.compareTo(b.nombre));
    return ListadoCocina(
      nombreAula: aula.nombre,
      fecha: fecha,
      comensales: comensales,
      sinResponder: activos.where((e) => !asistencia.containsKey(e.id)).length,
    );
  }

  /// El listado como texto para enviar o imprimir.
  static String comoTexto(ListadoCocina listado) {
    final fecha = listado.fecha;
    return [
      'Comedor · ${listado.nombreAula} · '
          '${fecha.day}/${fecha.month}/${fecha.year}',
      'Comensales: ${listado.comensales.length} '
          '(${listado.conDieta} con dieta)',
      for (final linea in listado.comensales)
        linea.dieta == null
            ? '- ${linea.nombre}'
            : '- ${linea.nombre}: ${linea.dieta}',
    ].join('\n');
  }
}
