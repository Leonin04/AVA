import 'package:flutter/material.dart';

import 'auth/connections/demo_auth_service.dart';
import 'auth/presentation/login_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginPage(authService: DemoAuthService()),
    );
  }
}
