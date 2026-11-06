import 'package:flutter/material.dart';

import '../constantes/pictogramas.dart';

/// Atribución obligatoria de los pictogramas de ARASAAC (RNF-12).
class AtribucionArasaac extends StatelessWidget {
  const AtribucionArasaac({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      Pictogramas.atribucion,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
