import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:banking4students/models/budget.dart';
import 'package:banking4students/utility/currency_converter.dart';
import 'package:provider/provider.dart';
import 'package:banking4students/providers/navigation_provider.dart';

class DashboardBudgetCarousel extends StatefulWidget {
  const DashboardBudgetCarousel({Key? key}) : super(key: key);

  @override
  _DashboardBudgetCarouselState createState() =>
      _DashboardBudgetCarouselState();
}

class _DashboardBudgetCarouselState extends State<DashboardBudgetCarousel> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;

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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to view budgets.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('budgets')
              .snapshots(),
      builder: (context, budgetSnapshot) {
        if (budgetSnapshot.hasError) {
          return Center(child: Text('Error: ${budgetSnapshot.error}'));
        }
        if (!budgetSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = budgetSnapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No budgets available.'));
        }
        List<BudgetModel> budgets =
            docs.map((doc) => BudgetModel.fromFirestore(doc)).toList();

        return StreamBuilder<DocumentSnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.hasError) {
              return Center(child: Text('Error: ${userSnapshot.error}'));
            }
            if (!userSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final String currentCurrency = userData['currency'] ?? 'MKD';

            return Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: budgets.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final budget = budgets[index];
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
                              ? (convertedRemaining / convertedLimit).clamp(
                                0.0,
                                1.0,
                              )
                              : 0.0;

                      final String remainingDisplay = formatAmount(
                        convertedRemaining,
                        currentCurrency,
                      );
                      final String spentDisplay = formatAmount(
                        convertedSpent,
                        currentCurrency,
                      );
                      final String limitDisplay = formatAmount(
                        convertedLimit,
                        currentCurrency,
                      );

                      return InkWell(
                        onTap: () {
                          Provider.of<NavigationProvider>(
                            context,
                            listen: false,
                          ).setSelectedIndex(2);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          color: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Top row: Category and remaining amount.
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      budget.category,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: remainingDisplay,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: " left",
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Progress bar.
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                    vertical: 3,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 10,
                                      backgroundColor: const Color(0xFFD7E4ED),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Color(0xFF4E87FF),
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Spent and Budget rows.
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
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
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
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // **Carousel Indicators inside the card**
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(budgets.length, (
                                    index,
                                  ) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      width: _currentPage == index ? 10 : 8,
                                      height: _currentPage == index ? 10 : 8,
                                      decoration: BoxDecoration(
                                        color:
                                            _currentPage == index
                                                ? Colors.blue
                                                : Colors.grey[400],
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
