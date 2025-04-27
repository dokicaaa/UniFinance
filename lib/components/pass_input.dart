import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PassInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Color customColor;
  final bool isPassWrong;

  const PassInput({
    super.key,
    required this.controller,
    required this.hintText,
    required this.customColor,
    this.isPassWrong = false,
  });

  @override
  State<PassInput> createState() => _PassInputState();
}

class _PassInputState extends State<PassInput> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white, // Background color changed to white
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 10,
        ),
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
        prefixIcon: const Icon(
          Icons.lock_outline, // Lock icon added
          color: Colors.grey,
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: InkWell(
            onTap: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            child: SvgPicture.asset(
              _isPasswordVisible
                  ? 'assets/icons/show.svg'
                  : 'assets/icons/hide.svg',
            ),
          ),
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
