import 'package:banking4students/components/savings/add_saving_goal.dart';
import 'package:banking4students/pages/bill_splitting.dart';
import 'package:flutter/material.dart';
import 'package:banking4students/components/income_and_expenses/add_transaction_dialog.dart';
import 'package:banking4students/components/budget/add_budget_dialog.dart';
import 'package:image_picker/image_picker.dart';

class AddNewBottomSheet extends StatelessWidget {
  final String userId;
  final String currentCurrency;
  final void Function(String) onItemAdded;
  // Called when an item is successfully added.
  // We'll pass a message (e.g. "Transaction added").

  const AddNewBottomSheet({
    Key? key,
    required this.userId,
    required this.currentCurrency,
    required this.onItemAdded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ImagePicker _picker = ImagePicker();
    return Padding(
      // Some vertical padding to avoid the bottom edge of the screen
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row: "Add new" on the left, close icon on the right
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  "Add new",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // 1) Transactions
          InkWell(
            onTap: () {
              Navigator.pop(context); // Dismiss this bottom sheet
              showDialog(
                context: context,
                builder: (ctx) => AddTransactionDialog(userId: userId),
              ).then((result) {
                if (result == true) {
                  onItemAdded("Transaction added");
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text("💸", style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Transactions",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Add your expenses, incomes, bills, and transfers easily.",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2) Budget
          InkWell(
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (ctx) => AddBudgetDialog(userId: userId),
              ).then((result) {
                if (result == true) {
                  onItemAdded("Budget added");
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text("📊", style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Budget",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Set a budget for all categories – rent, groceries, etc.",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3) Savings
          InkWell(
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (ctx) => AddGoalPopup(),
              ).then((result) {
                if (result == true) {
                  onItemAdded("Saving goal added");
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text("💰", style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Savings",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Plan ahead and save for big expenses months in advance.",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4) Split a Bill
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BillSplittingPage(autoScan: true),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text("🤝", style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Split a Bill",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Easily share expenses with others.",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
