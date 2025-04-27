import 'package:banking4students/pages/dashboard.dart';
import 'package:banking4students/services/auth/login_or_register.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    if (authService.user == null) {
      return const LoginOrRegister(); // Show login/register page
    } else {
      return Dashboard(); // Show dashboard
    }
  }
}
