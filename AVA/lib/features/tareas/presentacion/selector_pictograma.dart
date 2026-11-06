import 'package:flutter/material.dart';

import '../../../core/servicios/arasaac.dart';

/// Diálogo para buscar un pictograma en ARASAAC (T-70).
/// Devuelve la URL elegida o null si se cancela.
Future<String?> elegirPictograma(BuildContext context, {String textoInicial = ''}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _DialogoPictograma(textoInicial: textoInicial),
  );
}

class _DialogoPictograma extends StatefulWidget {
  const _DialogoPictograma({required this.textoInicial});
  final String textoInicial;

  @override
  State<_DialogoPictograma> createState() => _DialogoPictogramaState();
}

class _DialogoPictogramaState extends State<_DialogoPictograma> {
  final _arasaac = Arasaac();
  late final _texto = TextEditingController(text: widget.textoInicial);
  List<String> _resultados = [];
  bool _cargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.textoInicial.trim().isNotEmpty) _buscar();
  }

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final r = await _arasaac.buscar(_texto.text);
      if (!mounted) return;
      setState(() {
        _resultados = r;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo conectar con ARASAAC.';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Elegir pictograma'),
      content: SizedBox(
        width: 520,
        height: 460,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _texto,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Buscar (por ejemplo: comer, mochila)',
                    ),
                    onSubmitted: (_) => _buscar(),
                  ),
                ),
                IconButton(
                  tooltip: 'Buscar',
                  icon: const Icon(Icons.search),
                  onPressed: _buscar,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : _resultados.isEmpty
                          ? const Center(child: Text('Sin resultados'))
                          : GridView.count(
                              crossAxisCount: 4,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              children: [
                                for (final url in _resultados)
                                  InkWell(
                                    onTap: () => Navigator.pop(context, url),
                                    child: Image.network(
                                      url,
                                      errorBuilder: (context, error, stack) =>
                                          const Icon(Icons.broken_image),
                                    ),
                                  ),
                              ],
                            ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pictogramas de ARASAAC (CC BY-NC-SA)',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
