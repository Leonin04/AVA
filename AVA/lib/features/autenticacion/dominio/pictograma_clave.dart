import '../../../core/constantes/paleta.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/modelos/recurso_visual.dart';

/// Pictogramas disponibles para el inicio de sesión con imágenes (RF-03).
///
/// Cada uno tiene además un color distinto, para que se reconozcan también
/// por el color (sin depender solo de él).
enum PictogramaClave {
  sol('Sol', Pictogramas.sol, ColorPastel.amarillo),
  manzana('Manzana', Pictogramas.manzana, ColorPastel.rosa),
  mariposa('Mariposa', Pictogramas.mariposa, ColorPastel.lavanda),
  flor('Flor', Pictogramas.flor, ColorPastel.menta),
  coche('Coche', Pictogramas.coche, ColorPastel.cielo),
  perro('Perro', Pictogramas.perro, ColorPastel.melocoton);

  const PictogramaClave(this.nombre, this.pictograma, this.color);

  final String nombre;
  final PictogramaArasaac pictograma;
  final ColorPastel color;

  static PictogramaClave porNombre(String nombre) =>
      values.firstWhere((p) => p.name == nombre);
}
