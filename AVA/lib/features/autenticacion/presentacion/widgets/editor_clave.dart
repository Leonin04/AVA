import 'package:flutter/material.dart';

import '../../../../core/constantes/dimensiones.dart';
import '../../../../core/widgets/pictograma.dart';
import '../../dominio/clave_acceso.dart';
import '../../dominio/metodo_acceso.dart';
import '../../dominio/pictograma_clave.dart';

/// Configuración del método de acceso de un estudiante y de su clave
/// (HU-01, HU-08): contraseña, número de 4 cifras o de 3 a 6 pictogramas.
///
/// Avisa con [alCambiar] de la clave válida, o de `null` si aún no lo es.
class EditorClave extends StatefulWidget {
  const EditorClave({
    super.key,
    required this.alCambiar,
    this.metodoInicial = const AccesoConPictogramas(longitudClave: 3),
  });

  final ValueChanged<ClaveAcceso?> alCambiar;
  final MetodoAcceso metodoInicial;

  @override
  State<EditorClave> createState() => _EditorClaveState();
}

enum _Tipo { contrasena, pin, pictogramas }

class _EditorClaveState extends State<EditorClave> {
  late _Tipo _tipo = switch (widget.metodoInicial) {
    AccesoConContrasena() => _Tipo.contrasena,
    AccesoConPin() => _Tipo.pin,
    AccesoConPictogramas() => _Tipo.pictogramas,
  };
  final _texto = TextEditingController();
  final List<PictogramaClave> _secuencia = [];

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  void _notificar() => widget.alCambiar(_clave);

  ClaveAcceso? get _clave {
    final texto = _texto.text.trim();
    return switch (_tipo) {
      _Tipo.contrasena => texto.length >= 4 ? ClaveContrasena(texto) : null,
      _Tipo.pin => RegExp(r'^\d{4}$').hasMatch(texto) ? ClavePin(texto) : null,
      _Tipo.pictogramas =>
        _secuencia.length >= AccesoConPictogramas.longitudMinima
            ? ClavePictogramas(List.of(_secuencia))
            : null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<_Tipo>(
          segments: const [
            ButtonSegment(
              value: _Tipo.pictogramas,
              icon: Icon(Icons.image_rounded),
              label: Text('Pictogramas'),
            ),
            ButtonSegment(
              value: _Tipo.pin,
              icon: Icon(Icons.pin_rounded),
              label: Text('Número'),
            ),
            ButtonSegment(
              value: _Tipo.contrasena,
              icon: Icon(Icons.password_rounded),
              label: Text('Contraseña'),
            ),
          ],
          selected: {_tipo},
          onSelectionChanged: (seleccion) {
            setState(() {
              _tipo = seleccion.first;
              _texto.clear();
              _secuencia.clear();
            });
            _notificar();
          },
        ),
        const SizedBox(height: Dimensiones.espaciado),
        if (_tipo == _Tipo.pictogramas)
          _editorPictogramas(context)
        else
          TextField(
            controller: _texto,
            keyboardType: _tipo == _Tipo.pin
                ? TextInputType.number
                : TextInputType.text,
            maxLength: _tipo == _Tipo.pin ? 4 : null,
            onChanged: (_) => _notificar(),
            decoration: InputDecoration(
              labelText: _tipo == _Tipo.pin
                  ? 'Número de 4 cifras'
                  : 'Contraseña (al menos 4 caracteres)',
            ),
          ),
      ],
    );
  }

  Widget _editorPictogramas(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final llena = _secuencia.length >= AccesoConPictogramas.longitudMaxima;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Toca de ${AccesoConPictogramas.longitudMinima} a '
          '${AccesoConPictogramas.longitudMaxima} pictogramas en orden.',
          style: textos.bodyMedium,
        ),
        const SizedBox(height: Dimensiones.espaciadoPequeno),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in PictogramaClave.values)
              ActionChip(
                avatar: Pictograma(recurso: p.pictograma, tamano: 32),
                label: Text(p.nombre),
                onPressed: llena
                    ? null
                    : () {
                        setState(() => _secuencia.add(p));
                        _notificar();
                      },
              ),
          ],
        ),
        const SizedBox(height: Dimensiones.espaciadoPequeno),
        Row(
          children: [
            Expanded(
              child: Text(
                _secuencia.isEmpty
                    ? 'Clave: (vacía)'
                    : 'Clave: ${_secuencia.map((p) => p.nombre).join(' → ')}',
                style: textos.titleMedium,
              ),
            ),
            TextButton.icon(
              onPressed: _secuencia.isEmpty
                  ? null
                  : () {
                      setState(_secuencia.clear);
                      _notificar();
                    },
              icon: const Icon(Icons.clear_rounded),
              label: const Text('Vaciar'),
            ),
          ],
        ),
      ],
    );
  }
}
