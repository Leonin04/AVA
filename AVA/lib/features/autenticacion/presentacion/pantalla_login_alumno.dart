import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/servicios/autenticacion.dart';
import '../../../core/widgets/avatar_alumno.dart';
import '../../perfil/dominio/estudiante.dart';
import '../dominio/acceso.dart';

/// Login de un alumno (wireframe 4): su avatar y su clave.
/// La clave depende de `alumno.metodoLogin`: PIN, 3 pictogramas o contraseña.
class PantallaLoginAlumno extends StatefulWidget {
  const PantallaLoginAlumno({
    super.key,
    required this.alumno,
    this.autenticacion,
  });

  final Acceso alumno;

  /// Solo para pruebas; por defecto usa `Autenticacion()`.
  final Autenticacion? autenticacion;

  @override
  State<PantallaLoginAlumno> createState() => _PantallaLoginAlumnoState();
}

class _PantallaLoginAlumnoState extends State<PantallaLoginAlumno> {
  static const _longitudSecuencia = 3;

  // Iconos provisionales para las palabras de `Autenticacion.pictogramasClave`.
  // Se pueden sustituir por pictogramas de ARASAAC.
  static const _iconos = <String, IconData>{
    'sol': Icons.wb_sunny,
    'casa': Icons.home,
    'perro': Icons.pets,
    'coche': Icons.directions_car,
    'flor': Icons.local_florist,
    'pelota': Icons.sports_soccer,
  };

  late final Autenticacion _auth = widget.autenticacion ?? Autenticacion();
  final _texto = TextEditingController();
  final List<String> _secuencia = [];
  bool _entrando = false;
  bool _verClave = false;
  String? _error;

  MetodoLogin get _metodo => widget.alumno.metodoLogin;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _entrar(Object entrada) async {
    setState(() {
      _entrando = true;
      _error = null;
    });
    try {
      await _auth.entrarEstudiante(widget.alumno, entrada);
      if (!mounted) return;
      // AuthGate ya enseña la pantalla que corresponde a la nueva sesión.
      Navigator.of(context).popUntil((r) => r.isFirst);
    } on ErrorAcceso catch (e) {
      if (!mounted) return;
      setState(() {
        _entrando = false;
        _error = e.mensaje;
        _secuencia.clear();
        _texto.clear();
      });
    }
  }

  void _entrarConTexto() {
    final valor = _texto.text.trim();
    if (valor.isEmpty) {
      setState(() => _error = 'Escribe tu clave.');
      return;
    }
    // Una contraseña puede tener espacios internos; solo se recorta en el PIN.
    _entrar(_metodo == MetodoLogin.pin ? valor : _texto.text);
  }

  void _tocarPictograma(String palabra) {
    if (_entrando || _secuencia.length >= _longitudSecuencia) return;
    setState(() {
      _secuencia.add(palabra);
      _error = null;
    });
    if (_secuencia.length == _longitudSecuencia) {
      _entrar(List<String>.of(_secuencia));
    }
  }

  void _borrarUltimo() {
    if (_entrando || _secuencia.isEmpty) return;
    setState(() => _secuencia.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AvatarAlumno(fotoUrl: widget.alumno.fotoUrl, radio: 64),
                  const SizedBox(height: 12),
                  Text(
                    widget.alumno.nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  if (_metodo == MetodoLogin.pictograma)
                    _zonaPictogramas(colores)
                  else
                    _zonaTexto(),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, color: colores.error),
                      ),
                    ),
                  ],
                  if (_entrando) ...[
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// PIN o contraseña: un campo y el botón Entrar.
  Widget _zonaTexto() {
    final esPin = _metodo == MetodoLogin.pin;
    return Column(
      children: [
        TextField(
          controller: _texto,
          enabled: !_entrando,
          autofocus: true,
          obscureText: !_verClave,
          keyboardType: esPin ? TextInputType.number : TextInputType.text,
          inputFormatters:
              esPin ? [FilteringTextInputFormatter.digitsOnly] : null,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _entrarConTexto(),
          style: const TextStyle(fontSize: 28),
          decoration: InputDecoration(
            labelText: esPin ? 'PIN' : 'Contraseña',
            prefixIcon: const Icon(Icons.lock_outline),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              tooltip: _verClave ? 'Ocultar clave' : 'Mostrar clave',
              icon: Icon(_verClave ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _verClave = !_verClave),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: FilledButton(
            onPressed: _entrando ? null : _entrarConTexto,
            style: FilledButton.styleFrom(
              textStyle: const TextStyle(fontSize: 26),
            ),
            child: const Text('Entrar'),
          ),
        ),
      ],
    );
  }

  /// Pictogramas: el alumno toca 3 en orden y entra al tocar el tercero.
  Widget _zonaPictogramas(ColorScheme colores) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _longitudSecuencia; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colores.surfaceContainerHighest,
                    border: Border.all(color: colores.outline, width: 2),
                  ),
                  child: i < _secuencia.length
                      ? Icon(_iconos[_secuencia[i]], size: 40)
                      : null,
                ),
              ),
            IconButton(
              tooltip: 'Borrar el último',
              iconSize: 36,
              onPressed:
                  _entrando || _secuencia.isEmpty ? null : _borrarUltimo,
              icon: const Icon(Icons.backspace_outlined),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final palabra in Autenticacion.pictogramasClave)
              SizedBox(
                width: 130,
                height: 130,
                child: FilledButton.tonal(
                  onPressed: _entrando ? null : () => _tocarPictograma(palabra),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_iconos[palabra] ?? Icons.help_outline, size: 56),
                      const SizedBox(height: 8),
                      Text(palabra, style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}