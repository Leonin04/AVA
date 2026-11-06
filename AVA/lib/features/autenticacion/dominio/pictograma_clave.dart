/// Pictogramas disponibles para el inicio de sesión con imágenes.
///
/// Por ahora se representan con iconos; más adelante se sustituirán por
/// pictogramas de ARASAAC.
enum PictogramaClave {
  sol('Sol'),
  luna('Luna'),
  estrella('Estrella'),
  corazon('Corazón'),
  flor('Flor'),
  coche('Coche');

  const PictogramaClave(this.nombre);

  final String nombre;
}
