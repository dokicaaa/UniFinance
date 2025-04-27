import 'package:flutter/material.dart';

class EmailInput extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final Color customColor;
  final FocusNode? focusNode;

  const EmailInput({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    required this.customColor,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white, // Background color changed to white
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 10,
        ),
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
        prefixIcon: const Icon(
          Icons.email_outlined, // Envelope icon added
          color: Colors.grey,
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1,
          ), // Added border
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1,
          ), // Normal state border
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 2,
          ), // Focused state border
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }
}
