import 'package:flutter/material.dart';

// Income categories color
Color getIncomeColor(String source) {
  switch (source) {
    case 'Job':
      return Color.fromARGB(255, 186, 10, 255);
    case 'Allowance':
      return Color.fromARGB(255, 103, 2, 131);
    case 'Scholarships':
      return Color.fromARGB(255, 214, 35, 221);
    default:
      return Colors.grey;
  }
}

// Expense categories color
Color getExpenseColor(String category) {
  switch (category) {
    case 'Food':
      return Color.fromARGB(255, 2, 62, 138);
    case 'Transport':
      return Color.fromARGB(255, 47, 25, 209);
    case 'Rent':
      return Color.fromARGB(255, 72, 202, 228);
    case 'Entertainment':
      return Color.fromARGB(255, 33, 143, 239);
    case 'Others':
      return Color.fromARGB(255, 12, 117, 138);
    default:
      return Colors.grey;
  }
}
