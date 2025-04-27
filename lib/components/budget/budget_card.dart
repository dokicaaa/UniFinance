import 'package:flutter/material.dart';
import 'package:banking4students/models/budget.dart';
import 'package:banking4students/utility/currency_converter.dart';

class BudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final String currentCurrency;
  const BudgetCard({
    Key? key,
    required this.budget,
    required this.currentCurrency,
  }) : super(key: key);

  // Helper function for formatting the amount
  String formatAmount(double value, String currency) {
    if (currency == "MKD") {
      return value.toStringAsFixed(0) + " MKD";
    } else if (currency == "USD") {
      return "\$" + value.toStringAsFixed(2);
    } else if (currency == "EUR") {
      return "€" + value.toStringAsFixed(2);
    } else {
      return "$currency " + value.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Convert values from MKD (base) to the user's currency.
    final double convertedLimit = convertCurrency(
      budget.limit,
      "MKD",
      currentCurrency,
    );
    final double convertedSpent = convertCurrency(
      budget.spent,
      "MKD",
      currentCurrency,
    );
    final double convertedRemaining = convertCurrency(
      budget.remaining,
      "MKD",
      currentCurrency,
    );

    final double progress =
        convertedLimit > 0
            ? (convertedRemaining / convertedLimit).clamp(0.0, 1.0)
            : 0.0;

    final String remainingDisplay = formatAmount(
      convertedRemaining,
      currentCurrency,
    );
    final String spentDisplay = formatAmount(convertedSpent, currentCurrency);
    final String limitDisplay = formatAmount(convertedLimit, currentCurrency);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.category,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                    children: [
                      // For USD/EUR, the symbol will be added by formatAmount.
                      TextSpan(
                        text: remainingDisplay,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text: " left",
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: const Color(0xFFD7E4ED),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF4E87FF),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF4E87FF),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Spent: " + spentDisplay,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFD7E4ED),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Budget: " + limitDisplay,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
