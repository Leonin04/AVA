import 'package:flutter/foundation.dart';

import '../connections/auth_service.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._authService);

  final AuthService _authService;

  bool isSigningIn = false;
  bool isSignedIn = false;
  String? errorMessage;

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Porfavor, ingresa tu correo electrónico';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Porfavor, ingresa tu contraseña';
    }
    if (value.length < 6) return 'Utiliza al menos 6 caracteres';
    return null;
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    if (isSigningIn) return;

    isSigningIn = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.signIn(email: email, password: password);
      isSignedIn = true;
    } on AuthException catch (error) {
      errorMessage = error.message;
    } finally {
      isSigningIn = false;
      notifyListeners();
    }
  }

  void signOut() {
    isSignedIn = false;
    errorMessage = null;
    notifyListeners();
  }
}
