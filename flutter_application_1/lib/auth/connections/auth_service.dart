abstract interface class AuthService {
  Future<void> signIn({required String email, required String password});
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
