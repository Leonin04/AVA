import 'dart:math' as math;

/// Cálculos de paginación para mostrar listas sin desplazamiento.
class Paginacion {
  const Paginacion({required this.total, required int porPagina})
    : porPagina = porPagina < 1 ? 1 : porPagina;

  final int total;
  final int porPagina;

  int get numeroPaginas => math.max(1, (total / porPagina).ceil());

  /// Índice del primer elemento de [pagina] (empezando en 0).
  int inicio(int pagina) => math.min(pagina * porPagina, total);

  /// Índice siguiente al último elemento de [pagina].
  int fin(int pagina) => math.min(inicio(pagina) + porPagina, total);

  /// Cuántos elementos de [tamanoMinimo] caben en [disponible] dejando
  /// [espaciado] entre ellos. Siempre al menos 1 y como mucho [maximo].
  static int cuantosCaben({
    required double disponible,
    required double tamanoMinimo,
    required double espaciado,
    int maximo = 1000,
  }) {
    if (!disponible.isFinite || tamanoMinimo <= 0) return 1;
    final caben = ((disponible + espaciado) / (tamanoMinimo + espaciado))
        .floor();
    return caben.clamp(1, maximo);
  }
}
