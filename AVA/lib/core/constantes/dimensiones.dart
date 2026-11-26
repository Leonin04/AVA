/// Medidas comunes de la interfaz.
///
/// Pensadas para tabletas y para alumnado con dificultades motoras: los
/// objetivos táctiles superan con margen los 44 px de WCAG 2.5.5 (AAA) y
/// los 48 px de Material.
abstract final class Dimensiones {
  static const double objetivoTactilMinimo = 64;
  static const double altoBotonGrande = 96;
  static const double altoBarraNavegacion = 96;
  static const double altoCabecera = 88;

  /// Alto de la barra «Anterior / 1 de 3 / Siguiente» cuando el contenido
  /// no cabe legible en una sola pantalla.
  static const double altoBarraPaginas = 80;

  /// Tamaño de letra mínimo (antes de aplicar la escala elegida por el
  /// alumno) para considerar un texto legible. Si no se alcanza, se
  /// reparte el contenido en páginas.
  static const double letraMinimaLegible = 16;

  static const double espaciado = 24;
  static const double espaciadoPequeno = 12;

  /// Relleno de los botones pequeños con letra común (vista semanal). Es
  /// mayor que el borde de foco (6), para que no tape el texto.
  static const double rellenoCompacto = 8;
  static const double radioBorde = 24;
  static const double radioBordePequeno = 16;

  /// Grosor del borde de tarjetas y botones (contraste no textual, WCAG 1.4.11).
  static const double grosorBorde = 3;

  /// Grosor del borde cuando el elemento está seleccionado o tiene el foco
  /// (indicador de foco visible, WCAG 2.4.7).
  static const double grosorBordeFoco = 6;

  static const double avatarGrande = 140;
  static const double avatarMediano = 96;

  static const double anchoMaximoContenido = 960;
  static const double anchoMaximoFormulario = 560;

  /// Tiempo durante el que se ignoran pulsaciones repetidas con el filtro
  /// antitemblor activado (persona Carlos).
  static const Duration esperaAntitemblor = Duration(milliseconds: 1200);

  /// Espera mínima entre pulsaciones aunque el filtro esté desactivado, para
  /// evitar dobles toques accidentales.
  static const Duration esperaDobleToque = Duration(milliseconds: 350);
}
