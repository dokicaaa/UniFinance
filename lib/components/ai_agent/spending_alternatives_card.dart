import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SpendingAlternativesCard extends StatelessWidget {
  final Map<String, dynamic> spendingAlternatives;

  const SpendingAlternativesCard({Key? key, required this.spendingAlternatives})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the data exists
    if (spendingAlternatives.isEmpty ||
        spendingAlternatives["spending_alternatives"] == null) {
      return Center(
        child: Text(
          "No spending alternatives available.",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // Get the entries from the JSON map.
    final List entries =
        (spendingAlternatives["spending_alternatives"] as Map).entries.toList();

    return Container(
      height: 280, // Increased height for a bigger display
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontally scrollable list of cards
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: entries.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final String category = entry.key;
                final String suggestion =
                    entry.value["suggestion"] ?? "No suggestion available.";

                return Container(
                  width: 300,
                  // Increased card width for a larger card
                  child: Card(
                    elevation: 4,
                    color: Theme.of(context).colorScheme.tertiary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category row with a FontAwesome icon
                          Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.tags,
                                color: Colors.blue,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Suggestion text
                          Expanded(
                            child: Text(
                              suggestion,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Optional: Add dot indicators here if needed.
        ],
      ),
    );
  }
}
