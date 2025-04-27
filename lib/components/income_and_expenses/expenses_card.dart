import 'package:banking4students/components/income_and_expenses/edit_expense_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:banking4students/components/income_and_expenses/expenses_dialog.dart';
import 'package:banking4students/utility/category_color.dart';

class ExpenseCard extends StatefulWidget {
  final String userId;
  const ExpenseCard({Key? key, required this.userId}) : super(key: key);

  @override
  State<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard> {
  String _userCurrency = ""; // Initially empty

  @override
  void initState() {
    super.initState();
    _fetchUserCurrency();
  }

  // Fetch the user document once to get the currency
  Future<void> _fetchUserCurrency() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        _userCurrency = data['currency'] ?? 'USD';
      });
    }
  }

  // Show the "Add Expense" popup
  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AddExpenseDialog(userId: widget.userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If the currency hasn't been fetched yet, show a loading indicator
    if (_userCurrency.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      color: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top row: Title + Plus Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Expenses',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add Expense',
                  onPressed: _showAddExpenseDialog,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // List of Expenses
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userId)
                      .collection('expenses')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No expenses yet.');
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;

                    final expenseType = data['expenseType'] ?? 'Normal';
                    final category = data['category'] ?? 'Others';
                    final amount = data['amount'] ?? 0.0;
                    final startDate = data['startDate'] ?? '';
                    final endDate = data['endDate'] ?? '';

                    return ListTile(
                      leading: SizedBox(
                        height: double.infinity,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: getExpenseColor(category),
                        ),
                      ),
                      title: Text('$category: $amount $_userCurrency'),
                      subtitle: Text(
                        'Type: $expenseType\n$startDate → $endDate',
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await showDialog(
                              context: context,
                              builder:
                                  (context) => EditExpenseDialog(
                                    userId: widget.userId,
                                    expenseData: data,
                                    docId: docId,
                                  ),
                            );
                          } else if (value == 'delete') {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.userId)
                                .collection('expenses')
                                .doc(docId)
                                .delete();
                          }
                        },
                        itemBuilder:
                            (context) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
