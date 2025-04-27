import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:banking4students/models/budget.dart';
import 'package:banking4students/components/budget/budget_card.dart';
import 'package:banking4students/components/budget/add_budget_dialog.dart';
import 'package:banking4students/components/rounded_dropdown.dart';
import 'package:banking4students/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({Key? key}) : super(key: key);

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  // Default frequency filter.
  String _selectedFrequency = "Weekly";
  final List<String> _frequencyOptions = [
    "Daily",
    "Weekly",
    "Monthly",
    "Yearly",
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;
    if (user == null) {
      return const Center(child: Text('Please log in to view budgets.'));
    }

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
        // Default to MKD now
        final currentCurrency = userData['currency'] ?? 'MKD';

        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Top row: Rounded dropdown and plus button.
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RoundedPillDropdown(
                        selectedValue: _selectedFrequency,
                        options: _frequencyOptions,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedFrequency = value;
                            });
                          }
                        },
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        dropdownColor: Colors.blue[300],
                        borderRadius: 20.0,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AddBudgetDialog(userId: user.uid),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Budget list as a Column of cards.
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('budgets')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No budgets available. Tap the + button to add one.",
                        ),
                      );
                    }
                    // Convert docs to BudgetModel and filter by frequency.
                    List<BudgetModel> budgets =
                        docs
                            .map((doc) => BudgetModel.fromFirestore(doc))
                            .toList();
                    budgets =
                        budgets
                            .where((b) => b.frequency == _selectedFrequency)
                            .toList();

                    return Column(
                      children:
                          budgets.map((budget) {
                            return Dismissible(
                              key: Key(budget.id),
                              direction: DismissDirection.horizontal,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 20),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              secondaryBackground: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                bool confirm = await showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text("Confirm Deletion"),
                                        content: const Text(
                                          "Are you sure you want to delete this budget?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                );
                                if (confirm) {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .collection('budgets')
                                      .doc(budget.id)
                                      .delete();
                                }
                                return confirm;
                              },
                              child: BudgetCard(
                                budget: budget,
                                currentCurrency: currentCurrency,
                              ),
                            );
                          }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
