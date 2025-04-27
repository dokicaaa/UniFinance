import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:banking4students/utility/currency_converter.dart';

class TotalIncomeCard extends StatelessWidget {
  final String userId;
  const TotalIncomeCard({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1) Outer StreamBuilder: listens to user's doc to get the user’s selected currency
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          return _buildBody(context, errorText: "Error loading user currency");
        }
        if (!userSnapshot.hasData) {
          return _buildBody(context, isLoading: true);
        }

        // Extract the user’s currency (default to "MKD" if missing)
        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final String userCurrency = userData['currency'] ?? 'MKD';

        // 2) Inner StreamBuilder: listens to incomes and sums them
        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('incomes')
                  .snapshots(),
          builder: (context, incomeSnapshot) {
            if (incomeSnapshot.hasError) {
              return _buildBody(context, errorText: "Error loading income");
            }
            if (!incomeSnapshot.hasData) {
              return _buildBody(context, isLoading: true);
            }

            // Sum all income amounts in base currency (assumed "MKD")
            double totalIncomeMKD = 0.0;
            for (var doc in incomeSnapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              totalIncomeMKD += (data['amount'] ?? 0.0).toDouble();
            }

            // Convert from MKD to user’s currency
            final double totalIncomeConverted = convertCurrency(
              totalIncomeMKD,
              "MKD",
              userCurrency,
            );

            return _buildBody(
              context,
              totalValue: totalIncomeConverted,
              userCurrency: userCurrency,
            );
          },
        );
      },
    );
  }

  /// Builds the UI row with a colored box on the left and text on the right.
  Widget _buildBody(
    BuildContext context, {
    double? totalValue,
    bool isLoading = false,
    String? errorText,
    String? userCurrency,
  }) {
    if (isLoading) {
      return const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorText != null) {
      return Text(errorText);
    }

    final bool isMKD = (userCurrency == 'MKD');
    final String displayValue =
        isMKD
            ? totalValue!.toStringAsFixed(0) // no decimals for MKD
            : totalValue!.toStringAsFixed(2); // 2 decimals otherwise

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Colored square with upward arrow
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(Icons.arrow_upward, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 8),
        // Text label & total
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Income",
              style: TextStyle(color: Colors.grey[700], fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              "$userCurrency $displayValue",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
