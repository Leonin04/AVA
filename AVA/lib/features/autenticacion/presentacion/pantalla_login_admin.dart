import 'package:flutter/material.dart';

import '../../../core/servicios/autenticacion.dart';

/// Login de administrador o tutor (wireframe 3).
/// Usa `Autenticacion.entrarPersonal` (correo y contraseña).
class PantallaLoginAdmin extends StatefulWidget {
  const PantallaLoginAdmin({super.key, this.autenticacion});

  /// Solo para pruebas; por defecto usa `Autenticacion()`.
  final Autenticacion? autenticacion;

  @override
  State<PantallaLoginAdmin> createState() => _PantallaLoginAdminState();
}

class _PantallaLoginAdminState extends State<PantallaLoginAdmin> {
  late final Autenticacion _auth = widget.autenticacion ?? Autenticacion();
  final _correo = TextEditingController();
  final _clave = TextEditingController();
  bool _entrando = false;
  bool _verClave = false;
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final correo = _correo.text.trim();
    final clave = _clave.text;
    if (correo.isEmpty || clave.isEmpty) {
      setState(() => _error = 'Escribe tu correo y tu contraseña.');
      return;
    }
    setState(() {
      _entrando = true;
      _error = null;
    });
    try {
      await _auth.entrarPersonal(correo, clave);
      if (!mounted) return;
      // Cierra esta pantalla y las anteriores: AuthGate ya enseña la pantalla
      // que corresponde a la nueva sesión.
      Navigator.of(context).popUntil((r) => r.isFirst);
    } on ErrorAcceso catch (e) {
      if (!mounted) return;
      setState(() {
        _entrando = false;
        _error = e.mensaje;
      });
    }
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
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: colores.secondaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 64,
                      color: colores.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _correo,
                    enabled: !_entrando,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    style: const TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.mail_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _clave,
                    enabled: !_entrando,
                    obscureText: !_verClave,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => _entrar(),
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: _verClave
                            ? 'Ocultar contraseña'
                            : 'Mostrar contraseña',
                        icon: Icon(_verClave
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _verClave = !_verClave),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: colores.error),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _entrando ? null : _entrar,
                      style: FilledButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 22),
                      ),
                      child: _entrando
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            )
                          : const Text('Entrar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}