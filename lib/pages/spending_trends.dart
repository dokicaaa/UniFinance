import 'package:banking4students/components/income_and_expenses/balance_overview.dart';
import 'package:banking4students/models/user.dart';
import 'package:banking4students/services/auth/auth_service.dart';
import 'package:banking4students/utility/category_color.dart';
import 'package:banking4students/utility/currency_converter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SpendingTrendsPage extends StatelessWidget {
  const SpendingTrendsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Spending Trends")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Listen to the user's document to retrieve the current currency.
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        }

        final userData = UserModel.fromFirestore(snapshot.data!);
        final String currentCurrency = userData.currency;

        return Scaffold(
          appBar: AppBar(title: const Text("Spending Trends")),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Pie chart remains unchanged.
                  BalanceOverview(userId: user.uid, clickable: false),
                  const SizedBox(height: 16),

                  // "Categories" header.
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Grid of category cards.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SpendingCategoriesGrid(
                      userId: user.uid,
                      currentCurrency: currentCurrency,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SpendingCategoriesGrid extends StatelessWidget {
  final String userId;
  final String selectedTimeRange;
  final String currentCurrency;

  const SpendingCategoriesGrid({
    Key? key,
    required this.userId,
    this.selectedTimeRange = "Weekly",
    required this.currentCurrency,
  }) : super(key: key);

  /// Determine the start date based on the selected time range.
  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (selectedTimeRange) {
      case "Daily":
        return DateTime(now.year, now.month, now.day);
      case "Weekly":
        return now.subtract(const Duration(days: 7));
      case "Monthly":
        return DateTime(now.year, now.month, 1);
      case "Yearly":
        return DateTime(now.year, 1, 1);
      default:
        return DateTime(1970);
    }
  }

  @override
  Widget build(BuildContext context) {
    final startDate = _getStartDate();

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('expenses')
              .where('createdAt', isGreaterThanOrEqualTo: startDate)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Error loading expenses."),
          );
        }
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("No expenses yet."),
          );
        }

        // Group expenses by category.
        final Map<String, double> categorySums = {};
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final category = data['category'] ?? 'Others';
          final amount = (data['amount'] ?? 0.0).toDouble();
          categorySums[category] = (categorySums[category] ?? 0) + amount;
        }

        // Convert map to a list.
        final List<Map<String, dynamic>> categoryData =
            categorySums.entries
                .map((e) => {'category': e.key, 'amount': e.value})
                .toList();

        // Calculate total spending (for percentages).
        final double totalSpending = categoryData.fold(
          0.0,
          (sum, item) => sum + (item['amount'] as double),
        );

        // Build a 2-column grid of CategoryCard widgets.
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categoryData.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.7,
          ),
          itemBuilder: (context, index) {
            final cat = categoryData[index]['category'] as String;
            final amt = categoryData[index]['amount'] as double;
            final double percentage =
                (totalSpending > 0)
                    ? (amt / totalSpending * 100).toDouble()
                    : 0.0;

            return CategoryCard(
              category: cat,
              amount: amt,
              percentage: percentage,
              currentCurrency: currentCurrency,
            );
          },
        );
      },
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String category;
  final double amount;
  final double percentage;
  final String currentCurrency;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.amount,
    required this.percentage,
    required this.currentCurrency,
  }) : super(key: key);

  // Category emojis.
  static const Map<String, String> categoryEmojis = {
    'Food': '🍕',
    'Transport': '🚗',
    'Rent': '🏠',
    'Entertainment': '🎬',
    'Others': '❓',
  };

  @override
  Widget build(BuildContext context) {
    // Use the category color as background.
    final Color bgColor = getExpenseColor(category);
    // Get the emoji for the category.
    final String emoji = categoryEmojis[category] ?? '❓';

    // Convert the amount using your currency_converter logic.
    final double convertedAmount = convertCurrency(
      amount,
      "USD",
      currentCurrency,
    );
    final bool isMKD = currentCurrency == "MKD";
    final String amountStr =
        isMKD
            ? convertedAmount.toStringAsFixed(0)
            : convertedAmount.toStringAsFixed(2);

    return Container(
      decoration: BoxDecoration(
        color: bgColor, // Use category color for background.
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        height: 80,
        child: Stack(
          children: [
            // Top-right: Percentage box.
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF304674),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Text(
                  "${percentage.toStringAsFixed(1)}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            // Top-left: White box for emoji with centered emoji.
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),
              ),
            ),

            // Right center: Money spent in bigger, bold white text.
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  "$currentCurrency $amountStr",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Bottom-right: Category name in white.
            Positioned(
              bottom: 8,
              right: 8,
              child: Text(
                category,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
