import '../../../core/constantes/paleta.dart';
import '../../../core/constantes/pictogramas.dart';
import '../../../core/modelos/recurso_visual.dart';

/// Pictogramas disponibles para el inicio de sesión con imágenes (RF-03).
///
/// Son las mismas palabras que guarda la base de datos
/// (`Autenticacion.pictogramasClave`): el nombre de cada valor es la palabra.
/// Cada uno tiene además un color distinto, para reconocerlos también por el
/// color (sin depender solo de él).
enum PictogramaClave {
  sol('Sol', Pictogramas.sol, ColorPastel.amarillo),
  casa('Casa', Pictogramas.casa, ColorPastel.rosa),
  perro('Perro', Pictogramas.perro, ColorPastel.melocoton),
  coche('Coche', Pictogramas.coche, ColorPastel.cielo),
  flor('Flor', Pictogramas.flor, ColorPastel.menta),
  pelota('Pelota', Pictogramas.pelota, ColorPastel.lavanda);

  const PictogramaClave(this.nombre, this.pictograma, this.color);

  final String nombre;
  final PictogramaArasaac pictograma;
  final ColorPastel color;

  static PictogramaClave porNombre(String nombre) =>
      values.firstWhere((p) => p.name == nombre);
}
