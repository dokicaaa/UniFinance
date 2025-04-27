import 'package:banking4students/components/whole_components/net_balance_widget.dart';
import 'package:flutter/material.dart';
import 'package:banking4students/components/income_and_expenses/total_income_card.dart';
import 'package:banking4students/components/income_and_expenses/total_expenses_card.dart';
import 'package:banking4students/components/income_and_expenses/transactions_list.dart';

/// A page that shows the net balance at the top, a row with Income & Expense cards,
/// and then your TransactionsList below it, matching the style of your screenshot.
class TransactionPage extends StatelessWidget {
  final String userId;
  const TransactionPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Optional: An AppBar if you want it
      appBar: AppBar(
        title: const Text("Overview"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter logic if needed
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The net balance
            NetBalanceWidget(userId: userId),
            TransactionsList(userId: userId, showSeeAll: false),
          ],
        ),
      ),
    );
  }
}
