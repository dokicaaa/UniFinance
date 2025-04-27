import 'package:flutter/material.dart';

class RoundedCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final double size;
  final Color activeColor;

  const RoundedCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    this.size = 24,
    required this.activeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const CircleBorder(),
        activeColor: activeColor,
      ),
    );
  }
}
