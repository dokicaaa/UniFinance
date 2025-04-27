import 'package:banking4students/components/email_input.dart';
import 'package:banking4students/components/main_button.dart';
import 'package:banking4students/components/pass_input.dart';
import 'package:banking4students/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  //login method
  void login(BuildContext context) async {
    //Get auth service
    final authService = Provider.of<AuthService>(context, listen: false);
    //Try login
    try {
      await authService.signIn(_emailController.text, _passController.text);

      setState(() {});
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // backgroundColor: Theme.of(context).colorScheme.surface,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _loginText(),
              const SizedBox(height: 20),
              _loginInputFields(),
              //IMPLEMENT FORGOT PASSWORD FEATURE
              // const SizedBox(
              //   height: 16,
              // ),
              // _forgotPassword(),
              const SizedBox(height: 36),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: MainButton(text: 'Log In', onTap: () => login(context)),
              ),
              const SizedBox(height: 28),
              // _altTextLogIn(),
              // const SizedBox(height: 28),
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
          'Dont have an account?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 5),
        InkWell(
          onTap: widget.onTap,
          child: Text(
            'Sign Up',
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

  Padding forgotPassword() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Forgot password?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Column _loginInputFields() {
    return Column(
      children: [
        //EMAIL INPUT FIELD
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 28),
          child: EmailInput(
            hintText: 'Email',
            obscureText: false,
            controller: _emailController,
            focusNode: null,
            customColor: Colors.white,
          ),
        ),

        //PASSWORD INPUT FIELD
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: PassInput(
            hintText: 'Password',
            controller: _passController,
            customColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Padding _loginText() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      //TEXT COLUMN
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome back",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 36,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "We are happy to see you here again. Enter your email adress and password",
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
