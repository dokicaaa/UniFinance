import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BudgetSummaryCard extends StatefulWidget {
  final List<dynamic> budgetUpdates;

  const BudgetSummaryCard({Key? key, required this.budgetUpdates})
    : super(key: key);

  @override
  _BudgetSummaryCardState createState() => _BudgetSummaryCardState();
}

class _BudgetSummaryCardState extends State<BudgetSummaryCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    // If there's no budget updates, don't render anything
    if (widget.budgetUpdates.isEmpty) return const SizedBox.shrink();

    // Build pages for each budget update
    final pages =
        widget.budgetUpdates.map((budget) {
          return _buildBudgetPage(budget);
        }).toList();

    return Card(
      color: Theme.of(context).colorScheme.tertiary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 180,
        width: double.infinity,
        child: Column(
          children: [
            // The horizontal PageView for budget updates
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: pages,
              ),
            ),
            // Page indicators (dots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentPage == index ? Colors.blue : Colors.blue[200],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Builds a single "page" for one budget update
  Widget _buildBudgetPage(dynamic budget) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category title with a wallet icon
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.wallet,
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  budget["category"] ?? "Unknown Category",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Last Week’s Spending
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.shoppingCart,
                  size: 18,
                  color: Colors.blue,
                ),
                const SizedBox(width: 6),
                Text(
                  "Last Week’s Spending: \$${budget["last_week_spending"] ?? 0}",
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Budget Amount (if available) - now in green
            if (budget["final_budget"] != null)
              Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.moneyBillWave,
                    size: 18,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Budget: \$${budget["final_budget"]}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 4),

            // Budget Action: within budget - now in green
            if (budget["action"] == "within budget")
              Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.checkCircle,
                    size: 18,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "You stayed within budget!",
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ],
              ),

            // Budget Action: no budget set remains blue (or adjust if needed)
            if (budget["action"] == "no budget")
              Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.exclamationTriangle,
                    size: 18,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "No budget set for this category",
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
