import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:banking4students/utility/currency_converter.dart';

class TotalExpensesCard extends StatelessWidget {
  final String userId;
  const TotalExpensesCard({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1) Outer StreamBuilder: listen to user's doc for the selected currency
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

        // Extract user’s currency (default to "MKD" if missing)
        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final String userCurrency = userData['currency'] ?? 'MKD';

        // 2) Inner StreamBuilder: listen to expenses
        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('expenses')
                  .snapshots(),
          builder: (context, expenseSnapshot) {
            if (expenseSnapshot.hasError) {
              return _buildBody(context, errorText: "Error loading expenses");
            }
            if (!expenseSnapshot.hasData) {
              return _buildBody(context, isLoading: true);
            }

            // Sum all expense amounts in base currency (assumed "MKD")
            double totalExpensesMKD = 0.0;
            for (var doc in expenseSnapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              totalExpensesMKD += (data['amount'] ?? 0.0).toDouble();
            }

            // Convert from MKD to user’s currency
            final double totalExpensesConverted = convertCurrency(
              totalExpensesMKD,
              "MKD",
              userCurrency,
            );

            return _buildBody(
              context,
              totalValue: totalExpensesConverted,
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
        // Colored square with downward arrow
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(Icons.arrow_downward, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 8),
        // Text label & total
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Expenses",
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
