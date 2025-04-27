import 'package:banking4students/components/main_button.dart';
import 'package:flutter/material.dart';
import '../savings/savings_currency_converter.dart';
import '../savings/add_contribution_popup.dart';
import '../savings/show_unique_code_popup.dart';

class SavingsCard extends StatelessWidget {
  final Map<String, dynamic> saving;
  final String userId;
  final String currentCurrency; // User's currency

  const SavingsCard({
    Key? key,
    required this.saving,
    required this.userId,
    required this.currentCurrency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: SavingsCurrencyConverter().convertSavings(saving),
      builder: (context, convertedSnapshot) {
        if (!convertedSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final convertedSaving = convertedSnapshot.data!;
        double limit = (convertedSaving['limit'] as num).toDouble();
        double contribution =
            (convertedSaving['contribution'] as num).toDouble();
        double remaining = (convertedSaving['remaining'] as num).toDouble();

        // Calculate progress as the fraction of the target reached
        double progress =
            (limit > 0) ? (contribution / limit).clamp(0.0, 1.0) : 0.0;

        // Helper function for formatting amounts based on current currency.
        String formatAmount(double value) {
          if (currentCurrency == "MKD") {
            return value.toStringAsFixed(0) + " MKD";
          } else if (currentCurrency == "USD") {
            return "\$" + value.toStringAsFixed(2);
          } else if (currentCurrency == "EUR") {
            return "€" + value.toStringAsFixed(2);
          } else {
            return "$currentCurrency " + value.toStringAsFixed(2);
          }
        }

        String limitDisplay = formatAmount(limit);
        String contributionDisplay = formatAmount(contribution);
        String remainingDisplay = formatAmount(remaining);

        String emoji = saving['symbol'] ?? "💰";

        Color accentColor = Color(saving['accentColor'] ?? 0xFF007AFF);

        List<String> contributorImages = [];
        if (saving['contributors'] != null) {
          saving['contributors'].forEach((key, value) {
            if (value is Map &&
                value.containsKey('profileImageUrl') &&
                value['profileImageUrl'] != null) {
              contributorImages.add(value['profileImageUrl']);
            }
          });
        }

        return Card(
          color: Theme.of(context).colorScheme.tertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Avatar, Title, and Share button
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: accentColor.withOpacity(0.2),
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            saving['title'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Target: $limitDisplay',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 63, 62, 62),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => _showUniqueCodePopup(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Contribution and Remaining row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      contributionDisplay,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Remaining: $remainingDisplay',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 63, 62, 62),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                const SizedBox(height: 6),
                // Progress percentage
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}% saved',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Add Contribution button
                MainButton(
                  onTap: () => _showAddContributionPopup(context),
                  text: "Add Contribution",
                ),
                const SizedBox(height: 10),
                // Contributors' avatars (up to 3)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:
                      contributorImages.take(3).map((imageUrl) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(imageUrl),
                            onBackgroundImageError:
                                (_, __) => const Icon(Icons.person, size: 12),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddContributionPopup(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AddContributionPopup(
            userId: userId,
            uniqueCode: saving['uniqueCode'],
            remainingAmount: saving['remaining'],
            goalCurrency: saving['currency'] ?? "MKD",
          ),
    );
  }

  void _showUniqueCodePopup(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ShowUniqueCodePopup(uniqueCode: saving['uniqueCode']),
    );
  }
}
