import '../../../core/constantes/paleta.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/modelos/recurso_visual.dart';

/// Formas de consultar la agenda (HU-09 y HU-10).
enum VistaAgenda {
  semanal('Semana', Pictogramas.semana, ColorPastel.cielo),
  diaria('Hoy', Pictogramas.dia, ColorPastel.menta),
  siguienteTarea(
    'Ahora y después',
    Pictogramas.siguiente,
    ColorPastel.melocoton,
  );

  const VistaAgenda(this.nombre, this.pictograma, this.color);

  final String nombre;
  final PictogramaArasaac pictograma;
  final ColorPastel color;

  static VistaAgenda? porNombre(String nombre) {
    for (final vista in values) {
      if (vista.name == nombre) return vista;
    }
    return null;
  }
}
