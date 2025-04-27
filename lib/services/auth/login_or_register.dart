import 'package:banking4students/pages/login_page.dart';
import 'package:banking4students/pages/register_page.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool _showLoginPage = true; // Toggle between login and register pages

  void _togglePages() {
    setState(() {
      _showLoginPage = !_showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showLoginPage
        ? LoginPage(onTap: _togglePages)
        : RegisterPage(onTap: _togglePages);
  }
}
