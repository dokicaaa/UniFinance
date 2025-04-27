import 'package:flutter/material.dart';

class SavingsChallengeCard extends StatelessWidget {
  final Map<String, dynamic> savingsChallenge;

  const SavingsChallengeCard({Key? key, required this.savingsChallenge})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (savingsChallenge.isEmpty) {
      return Center(
        child: Text(
          "No savings challenge available.",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🔥 Weekend Savings Challenge",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "📌 ${savingsChallenge["challenge"] ?? "No challenge available."}",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              "🛒 Category: ${savingsChallenge["category"] ?? "Unknown"}",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
