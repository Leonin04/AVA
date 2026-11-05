import 'auth_service.dart';

class DemoAuthService implements AuthService {
  const DemoAuthService();

  @override
  Future<void> signIn({required String email, required String password}) async {
    // Replace this demo implementation with a real authentication connection.
  }
}
