/// Comparación alfabética en español que no tiene en cuenta mayúsculas ni
/// tildes, para que «Álex» vaya junto a «Alba» y no al final.
int compararAlfabeticamente(String a, String b) =>
    _normalizar(a).compareTo(_normalizar(b));

const _sinTilde = {
  'á': 'a',
  'é': 'e',
  'í': 'i',
  'ó': 'o',
  'ú': 'u',
  'ü': 'u',
  'ñ': 'n~',
};

String _normalizar(String texto) => [
  for (final letra in texto.toLowerCase().split('')) _sinTilde[letra] ?? letra,
].join();
