import 'package:flutter/material.dart';

class RoundedPillDropdown extends StatelessWidget {
  final String selectedValue;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  /// Optional styling parameters
  final Color backgroundColor;
  final Color textColor;
  final Color? dropdownColor;
  final double borderRadius;
  final EdgeInsets padding;

  const RoundedPillDropdown({
    Key? key,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.white,
    this.dropdownColor,
    this.borderRadius = 35.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: padding,
      child: DropdownButton<String>(
        value: selectedValue,
        isDense: true, // Shrinks vertical space
        style: TextStyle(color: textColor, fontSize: 14),
        dropdownColor: dropdownColor,
        icon: Icon(Icons.arrow_drop_down, color: textColor),
        underline: const SizedBox(),
        items:
            options.map((option) {
              return DropdownMenuItem(value: option, child: Text(option));
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
