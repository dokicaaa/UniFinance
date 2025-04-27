import 'dart:math';
import 'package:banking4students/pages/balance.dart';
import 'package:banking4students/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:banking4students/components/rounded_dropdown.dart';
import 'package:provider/provider.dart';

class TransactionsGraphic extends StatefulWidget {
  const TransactionsGraphic({Key? key}) : super(key: key);

  @override
  State<TransactionsGraphic> createState() => _TransactionsGraphicState();
}

class _TransactionsGraphicState extends State<TransactionsGraphic> {
  String _selectedFilter = "Week";
  final List<String> _filterOptions = ["Week", "Month"];

  // Dummy data for "Weekly" view (7 days)
  final List<Map<String, dynamic>> _weeklyData = [
    {"day": "S", "income": 500.0, "expense": 200.0},
    {"day": "M", "income": 600.0, "expense": 150.0},
    {"day": "T", "income": 550.0, "expense": 300.0},
    {"day": "W", "income": 700.0, "expense": 250.0},
    {"day": "T", "income": 650.0, "expense": 100.0},
    {"day": "F", "income": 800.0, "expense": 350.0},
    {"day": "S", "income": 900.0, "expense": 400.0},
  ];

  // Dummy data for "Monthly" view (6 "weeks")
  final List<Map<String, dynamic>> _monthlyData = [
    {"week": "W1", "income": 3000.0, "expense": 1000.0},
    {"week": "W2", "income": 3500.0, "expense": 1500.0},
    {"week": "W3", "income": 2800.0, "expense": 800.0},
    {"week": "W4", "income": 4000.0, "expense": 1200.0},
    {"week": "W5", "income": 3200.0, "expense": 900.0},
    {"week": "W6", "income": 3700.0, "expense": 1600.0},
  ];

  // Height of the chart area in pixels (max bar height is 150)
  final double chartMaxHeight = 150.0;

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    // Choose dummy data based on filter
    final data = _selectedFilter == "Week" ? _weeklyData : _monthlyData;

    // Determine maximum value for scaling the bars
    final maxIncome = data.map((d) => d['income'] as double).reduce(max);
    final maxExpense = data.map((d) => d['expense'] as double).reduce(max);
    final maxValue = max(maxIncome, maxExpense);

    // Sum total income and expense for the bottom row
    final totalIncome = data.fold(
      0.0,
      (sum, d) => sum + (d['income'] as double),
    );
    final totalExpense = data.fold(
      0.0,
      (sum, d) => sum + (d['expense'] as double),
    );

    return GestureDetector(
      onTap: () {
        navProvider.setSelectedIndex(1);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Theme.of(context).colorScheme.tertiary,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header row with title and RoundedPillDropdown filter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Overview",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  RoundedPillDropdown(
                    selectedValue: _selectedFilter,
                    options: _filterOptions,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedFilter = value;
                        });
                      }
                    },
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    textColor: Colors.white,
                    dropdownColor: Theme.of(context).colorScheme.secondary,
                    borderRadius: 25.0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // The bar chart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end, // Align from bottom
                children:
                    data.map((item) {
                      final double income = item['income'] as double;
                      final double expense = item['expense'] as double;
                      final double incomeBarHeight =
                          maxValue == 0
                              ? 0
                              : (income / maxValue) * chartMaxHeight;
                      final double expenseBarHeight =
                          maxValue == 0
                              ? 0
                              : (expense / maxValue) * chartMaxHeight;

                      // Show day label if weekly, or week label if monthly
                      final String label =
                          _selectedFilter == "Week"
                              ? (item['day'] as String)
                              : (item['week'] as String);

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Two bars side-by-side
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Income bar
                              Container(
                                width: 12,
                                height: incomeBarHeight,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Expense bar
                              Container(
                                width: 12,
                                height: expenseBarHeight,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(label, style: const TextStyle(fontSize: 14)),
                        ],
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              // Bottom row with total income and expense (always in MKD as whole numbers)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Income summary
                  Row(
                    children: [
                      const Icon(
                        Icons.arrow_upward,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "MKD ${totalIncome.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Expense summary
                  Row(
                    children: [
                      const Icon(
                        Icons.arrow_downward,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "MKD ${totalExpense.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
