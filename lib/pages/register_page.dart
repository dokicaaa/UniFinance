import 'package:banking4students/components/email_input.dart';
import 'package:banking4students/components/main_button.dart';
import 'package:banking4students/components/pass_input.dart';
import 'package:banking4students/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers for the new fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  void register(BuildContext context) {
    // Get auth service
    final auth = Provider.of<AuthService>(context, listen: false);

    // if passwords match -> create user
    if (_confirmPassController.text == _passController.text) {
      try {
        auth.signUp(
          _emailController.text,
          _passController.text,
          _nameController.text,
          _surnameController.text,
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text(e.toString())),
        );
      }
    }
    // if passwords don't match -> show error to user
    else {
      showDialog(
        context: context,
        builder:
            (context) =>
                const AlertDialog(title: Text("Passwords don't match!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _loginText(),
              const SizedBox(height: 28),
              _loginInputFields(),
              const SizedBox(height: 36),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: MainButton(
                  text: 'Sign Up',
                  onTap: () => register(context),
                ),
              ),
              const SizedBox(height: 28),
              _altTextSignUp(),
            ],
          ),
        ),
      ),
    );
  }

  Row _altTextSignUp() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 5),
        InkWell(
          onTap: widget.onTap,
          child: Text(
            'Log In',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Column _loginInputFields() {
    return Column(
      children: [
        // NAME & SURNAME INPUT FIELDS (SPLIT IN ONE ROW)
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 28),
          child: Row(
            children: [
              // Name Field
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10), // Spacing between fields
              // Surname Field
              Expanded(
                child: TextField(
                  controller: _surnameController,
                  decoration: InputDecoration(
                    hintText: 'Surname',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // EMAIL INPUT FIELD
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 28),
          child: EmailInput(
            hintText: 'Email',
            obscureText: false,
            controller: _emailController,
            customColor: Colors.white,
            focusNode: null,
          ),
        ),
        // PASSWORD INPUT FIELD
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 28),
          child: PassInput(
            hintText: 'Password',
            controller: _passController,
            customColor: Colors.white,
          ),
        ),
        // CONFIRM PASSWORD INPUT FIELD
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: PassInput(
            hintText: 'Confirm password',
            controller: _confirmPassController,
            customColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Padding _loginText() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Create and account",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 36,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            "Start your smart financial journey today. Creating an account will take less than a minute",
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
