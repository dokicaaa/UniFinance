// lib/components/logout_button.dart
import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const LogoutButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ), // Smaller padding
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16, // Smaller font size
            ),
          ),
        ),
      ),
    );
  }
}
