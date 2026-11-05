import 'package:flutter/material.dart';

import '../connections/auth_service.dart';
import '../logic/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.authService});

  final AuthService authService;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthController _authController;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(widget.authService);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    try {
      await _authController.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo iniciar sesión: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authController,
      builder: (context, _) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _authController.isSignedIn
                    ? _buildWelcome()
                    : _buildLoginForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BrandMark(),
          const SizedBox(height: 32),
          Text(
            'Hola de nuevo!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF202824),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inicia sesión para acceder a tu cuenta',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF66716B),
            ),
          ),
          const SizedBox(height: 32),
          const _FieldLabel('Correo electrónico'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              hintText: 'nombre@correo.com',
              prefixIcon: Icon(Icons.mail_outline),
            ),
            validator: _authController.validateEmail,
          ),
          const SizedBox(height: 20),
          const _FieldLabel('Contraseña'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => _signIn(),
            decoration: InputDecoration(
              hintText: 'Introduce tu contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                tooltip: _isPasswordVisible
                    ? 'Ocultar contraseña'
                    : 'Mostrar contraseña',
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            validator: _authController.validatePassword,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('La recuperación de contraseña aún no está configurada.'),
                  ),
                );
              },
              child: const Text('¿Olvidaste tu contraseña?'),
            ),
          ),
          if (_authController.errorMessage case final message?) ...[
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _authController.isSigningIn ? null : _signIn,
            child: _authController.isSigningIn
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Iniciar sesión'),
          ),
          const SizedBox(height: 20),
          Text(
            'Demo only: connect an authentication service to sign in securely.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF7A847F)),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _BrandMark(),
        const SizedBox(height: 40),
        const Icon(
          Icons.check_circle_outline,
          size: 64,
          color: Color(0xFF315C55),
        ),
        const SizedBox(height: 20),
        Text(
          'You’re signed in!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF202824),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome, ${_emailController.text.trim()}',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF66716B)),
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: _authController.signOut,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Salir de la sesión'),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Color(0xFF303A35),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFFE3ECE7),
          borderRadius: BorderRadius.circular(17),
        ),
        child: const Icon(
          Icons.lock_person_outlined,
          color: Color(0xFF315C55),
          size: 28,
        ),
      ),
    );
  }
}
