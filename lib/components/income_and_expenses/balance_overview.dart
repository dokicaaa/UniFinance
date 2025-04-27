import 'package:banking4students/components/income_and_expenses/total_expenses_card.dart';
import 'package:banking4students/components/income_and_expenses/total_income_card.dart';
import 'package:banking4students/pages/spending_trends.dart';
import 'package:banking4students/services/auth/auth_service.dart';
import 'package:banking4students/utility/category_color.dart';
import 'package:banking4students/components/rounded_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BalanceOverview extends StatefulWidget {
  final String userId;
  final bool clickable; // Determines if the widget is clickable

  const BalanceOverview({Key? key, required this.userId, this.clickable = true})
    : super(key: key);

  @override
  State<BalanceOverview> createState() => _BalanceOverviewState();
}

class _BalanceOverviewState extends State<BalanceOverview> {
  // Selected time range for filtering the expenses.
  String _selectedTimeRange = "Weekly";
  final List<String> _timeRangeOptions = [
    "Daily",
    "Weekly",
    "Monthly",
    "Yearly",
  ];

  /// Get a starting date based on the selected time range.
  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedTimeRange) {
      case "Daily":
        return DateTime(now.year, now.month, now.day);
      case "Weekly":
        return now.subtract(Duration(days: 7));
      case "Monthly":
        return DateTime(now.year, now.month, 1);
      case "Yearly":
        return DateTime(now.year, 1, 1);
      default:
        return DateTime(1970);
    }
  }

  /// Stream expenses filtered by the selected time range and group them by category.
  Stream<List<Map<String, dynamic>>> _getCategoryDataStream() {
    final startDate = _getStartDate();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('expenses')
        .where('createdAt', isGreaterThanOrEqualTo: startDate)
        .snapshots()
        .map((snapshot) {
          final Map<String, double> categorySums = {};
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final category = data['category'] ?? 'Others';
            final amount = (data['amount'] ?? 0.0).toDouble();
            categorySums[category] = (categorySums[category] ?? 0) + amount;
          }
          return categorySums.entries
              .map((e) => {'category': e.key, 'amount': e.value})
              .toList();
        });
  }

  /// Calculate total spending from the grouped data.
  double _totalSpending(List<Map<String, dynamic>> data) {
    return data.fold(0.0, (sum, item) => sum + (item['amount'] as double));
  }

  /// Build pie chart sections from the grouped expense data.
  List<PieChartSectionData> _buildPieChartSections(
    List<Map<String, dynamic>> data,
  ) {
    final total = _totalSpending(data);
    if (total == 0) return [];

    return data
        .asMap()
        .map((index, item) {
          final category = item['category'] as String;
          final amount = item['amount'] as double;
          final percentage = (amount / total * 100).toStringAsFixed(1);
          final color = getExpenseColor(category);

          return MapEntry(
            index,
            PieChartSectionData(
              color: color,
              value: amount,
              // Turn off the default title inside the slice
              showTitle: false,
              radius: 60,
              // Create a 'badge' widget to display the percentage outside the slice
              badgeWidget: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white, // Background of the label
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Text color
                  ),
                ),
              ),
              // Position the badge outside the slice; tweak this value as needed
              badgePositionPercentageOffset: 1.3,
            ),
          );
        })
        .values
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;
    if (user == null) {
      return const Center(child: Text('Please log in to view expenses.'));
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getCategoryDataStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Error: ${snapshot.error}"),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Card(
            child: SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final data = snapshot.data!;
        if (data.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("No expenses yet."),
            ),
          );
        }

        final sections = _buildPieChartSections(data);

        // The content widget that will be optionally wrapped in a GestureDetector.
        final content = Card(
          color: Theme.of(context).colorScheme.tertiary,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header: Title and dropdown for filtering.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Spending Trends",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    RoundedPillDropdown(
                      selectedValue: _selectedTimeRange,
                      options: _timeRangeOptions,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedTimeRange = value;
                          });
                        }
                      },
                      backgroundColor: Colors.blue,
                      textColor: Colors.white,
                      dropdownColor: Colors.blue[300],
                      borderRadius: 20.0,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Doughnut chart.
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 50,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );

        // Wrap content in a GestureDetector if clickable.
        if (widget.clickable) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SpendingTrendsPage()),
              );
            },
            child: Padding(padding: const EdgeInsets.all(5), child: content),
          );
        } else {
          return Padding(padding: const EdgeInsets.all(5), child: content);
        }
      },
    );
  }
}
