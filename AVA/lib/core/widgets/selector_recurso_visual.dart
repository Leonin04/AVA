import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../constantes/dimensiones.dart';
import '../modelos/recurso_visual.dart';
import '../servicios/servicio_arasaac.dart';
import 'atribucion_arasaac.dart';
import 'pictograma.dart';

/// Elección de la imagen de apoyo: un pictograma de ARASAAC o una foto
/// propia (RF-13, HU-05, HU-14, HU-18).
class SelectorRecursoVisual extends StatelessWidget {
  const SelectorRecursoVisual({
    super.key,
    required this.recurso,
    required this.alCambiar,
    this.textoBusquedaInicial = '',
  });

  final RecursoVisual? recurso;
  final ValueChanged<RecursoVisual?> alCambiar;
  final String textoBusquedaInicial;

  Future<void> _buscar(BuildContext context) async {
    final elegido = await showDialog<PictogramaArasaac>(
      context: context,
      builder: (_) => _BuscadorArasaac(textoInicial: textoBusquedaInicial),
    );
    if (elegido != null) alCambiar(elegido);
  }

  Future<void> _subirFoto(BuildContext context) async {
    final avisos = ScaffoldMessenger.of(context);
    try {
      final archivo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (archivo == null) return;
      final bytes = await archivo.readAsBytes();
      final tipo = archivo.mimeType ?? 'image/jpeg';
      // Se guarda incrustada; el repositorio la sube a Cloud Storage.
      alCambiar(FotoPropia('data:$tipo;base64,${base64Encode(bytes)}'));
    } on Exception {
      avisos.showSnackBar(
        const SnackBar(content: Text('No se ha podido abrir la foto.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: esquema.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(Dimensiones.radioBordePequeno),
            border: Border.all(color: esquema.outline, width: 2),
          ),
          alignment: Alignment.center,
          child: Pictograma(
            recurso: recurso,
            tamano: 100,
            etiqueta: recurso == null ? 'Sin imagen' : 'Imagen elegida',
            iconoRespaldo: Icons.image_not_supported_outlined,
          ),
        ),
        const SizedBox(width: Dimensiones.espaciado),
        Expanded(
          child: Wrap(
            spacing: Dimensiones.espaciadoPequeno,
            runSpacing: Dimensiones.espaciadoPequeno,
            children: [
              FilledButton.icon(
                onPressed: () => _buscar(context),
                icon: const Icon(Icons.search_rounded),
                label: const Text('Buscar pictograma'),
              ),
              OutlinedButton.icon(
                onPressed: () => _subirFoto(context),
                icon: const Icon(Icons.add_photo_alternate_rounded),
                label: const Text('Subir foto'),
              ),
              if (recurso != null)
                TextButton.icon(
                  onPressed: () => alCambiar(null),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Quitar'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BuscadorArasaac extends StatefulWidget {
  const _BuscadorArasaac({required this.textoInicial});

  final String textoInicial;

  @override
  State<_BuscadorArasaac> createState() => _BuscadorArasaacState();
}

class _BuscadorArasaacState extends State<_BuscadorArasaac> {
  late final _texto = TextEditingController(text: widget.textoInicial);
  List<ResultadoArasaac> _resultados = const [];
  bool _buscando = false;
  String? _mensaje;

  @override
  void initState() {
    super.initState();
    if (widget.textoInicial.isNotEmpty) _buscar();
  }

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    setState(() {
      _buscando = true;
      _mensaje = null;
    });
    try {
      final resultados = await context.read<ServicioArasaac>().buscar(
        _texto.text,
      );
      if (!mounted) return;
      setState(() {
        _resultados = resultados;
        _mensaje = resultados.isEmpty
            ? 'No hay pictogramas con esa palabra.'
            : null;
      });
    } on ErrorArasaac catch (error) {
      if (mounted) setState(() => _mensaje = error.mensaje);
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(Dimensiones.espaciado),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Buscar en ARASAAC',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: Dimensiones.espaciado),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _texto,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _buscar(),
                      decoration: const InputDecoration(
                        labelText: 'Palabra',
                        hintText: 'Por ejemplo: comer, autobús, clase',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensiones.espaciadoPequeno),
                  FilledButton(
                    onPressed: _buscando ? null : _buscar,
                    child: const Text('Buscar'),
                  ),
                ],
              ),
              const SizedBox(height: Dimensiones.espaciado),
              Expanded(
                child: _buscando
                    ? const Center(child: CircularProgressIndicator())
                    : _mensaje != null
                    ? Center(
                        child: Text(
                          _mensaje!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 160,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: _resultados.length,
                        itemBuilder: (context, i) {
                          final resultado = _resultados[i];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => Navigator.of(
                                context,
                              ).pop(resultado.pictograma),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Pictograma(
                                        recurso: resultado.pictograma,
                                        tamano: 110,
                                      ),
                                    ),
                                    Text(
                                      resultado.palabra,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: Dimensiones.espaciadoPequeno),
              const AtribucionArasaac(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
