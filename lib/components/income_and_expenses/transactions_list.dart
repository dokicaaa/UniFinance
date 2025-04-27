import 'package:banking4students/components/income_and_expenses/add_transaction_dialog.dart';
import 'package:banking4students/components/income_and_expenses/edit_income_dialog.dart';
import 'package:banking4students/components/income_and_expenses/total_expenses_card.dart';
import 'package:banking4students/components/income_and_expenses/total_income_card.dart';
import 'package:banking4students/pages/transactions.dart';
import 'package:banking4students/services/auth/auth_service.dart';
import 'package:banking4students/providers/database_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:banking4students/utility/category_color.dart';
import 'package:banking4students/utility/currency_converter.dart';
import 'package:provider/provider.dart';
import 'package:banking4students/components/income_and_expenses/edit_expense_dialog.dart';

class TransactionsList extends StatefulWidget {
  final String userId;
  final int? limit;
  final bool showSeeAll;

  const TransactionsList({
    Key? key,
    required this.userId,
    this.limit,
    required this.showSeeAll,
  }) : super(key: key);

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  /// Manually format DateTime as dd/MM/yy.
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().substring(2);
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          return Text("Error: ${userSnapshot.error}");
        }
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final String currentCurrency = userData['currency'] ?? 'MKD';

        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row with Income and Expense cards.
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TotalIncomeCard(userId: user!.uid),
                    TotalExpensesCard(userId: user.uid),
                  ],
                ),
              ),
              // Header: Title and plus button.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Transactions",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 30),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) =>
                                AddTransactionDialog(userId: widget.userId),
                      );
                    },
                  ),
                ],
              ),
              // "See all" row.
              if (widget.showSeeAll)
                GestureDetector(
                  onTap: () {
                    if (user == null) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TransactionPage(userId: user.uid),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "See all",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              // Transactions list.
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: dbProvider.getCombinedTransactions(
                  widget.userId,
                  limit: widget.limit,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No transactions yet.');
                  }
                  final transactions = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final data = transactions[index];
                      final String type = data['type'] ?? 'income';
                      final String source =
                          data['source'] ?? data['category'] ?? 'Unknown';
                      final double amount = (data['amount'] ?? 0.0).toDouble();
                      final String baseCurrency = 'MKD';
                      final double convertedAmount = convertCurrency(
                        amount,
                        baseCurrency,
                        currentCurrency,
                      );

                      String displayAmount;
                      if (currentCurrency == "MKD") {
                        displayAmount =
                            "${type == 'income' ? "+" : "-"}${convertedAmount.toStringAsFixed(0)} MKD";
                      } else if (currentCurrency == "USD") {
                        displayAmount =
                            "${type == 'income' ? "+" : "-"}\$${convertedAmount.toStringAsFixed(2)}";
                      } else if (currentCurrency == "EUR") {
                        displayAmount =
                            "${type == 'income' ? "+" : "-"}€${convertedAmount.toStringAsFixed(2)}";
                      } else {
                        displayAmount =
                            "${type == 'income' ? "+" : "-"}\$${convertedAmount.toStringAsFixed(2)} $currentCurrency";
                      }

                      final Color circleColor =
                          type == 'income'
                              ? getIncomeColor(source)
                              : getExpenseColor(source);
                      final Color textColor =
                          type == 'income' ? Colors.green : Colors.red;

                      return Dismissible(
                        key: Key(data['docId']),
                        direction: DismissDirection.horizontal,
                        background: Container(
                          color: Theme.of(context).colorScheme.primary,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            bool confirm = await showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text("Confirm Deletion"),
                                    content: const Text(
                                      "Are you sure you want to delete this transaction?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                            );
                            if (confirm) {
                              if (type == 'expense') {
                                double expenseAmount =
                                    (data['amount'] ?? 0.0).toDouble();
                                final budgetQuery =
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(widget.userId)
                                        .collection('budgets')
                                        .where(
                                          'category',
                                          isEqualTo: data['category'],
                                        )
                                        .limit(1)
                                        .get();
                                if (budgetQuery.docs.isNotEmpty) {
                                  final budgetDoc = budgetQuery.docs.first;
                                  final budgetData = budgetDoc.data();
                                  double oldSpent =
                                      (budgetData['spent'] ?? 0.0).toDouble();
                                  double limit =
                                      (budgetData['limit'] ?? 0.0).toDouble();
                                  double newSpent = oldSpent - expenseAmount;
                                  if (newSpent < 0) newSpent = 0;
                                  double newRemaining = limit - newSpent;
                                  if (newRemaining < 0) newRemaining = 0;
                                  await budgetDoc.reference.update({
                                    'spent': newSpent,
                                    'remaining': newRemaining,
                                  });
                                }
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(widget.userId)
                                    .collection('expenses')
                                    .doc(data['docId'])
                                    .delete();
                              } else if (type == 'income') {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(widget.userId)
                                    .collection('incomes')
                                    .doc(data['docId'])
                                    .delete();
                              }
                              return true;
                            }
                            return false;
                          } else {
                            if (type == 'income') {
                              await showDialog(
                                context: context,
                                builder:
                                    (context) => EditIncomeDialog(
                                      userId: widget.userId,
                                      incomeData: data,
                                      docId: data['docId'],
                                    ),
                              );
                            } else {
                              await showDialog(
                                context: context,
                                builder:
                                    (context) => EditExpenseDialog(
                                      userId: widget.userId,
                                      expenseData: data,
                                      docId: data['docId'],
                                    ),
                              );
                            }
                            return false;
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left side: Circle + Title + Date.
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: circleColor,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        source,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                      if (data['createdAt'] != null)
                                        Text(
                                          _formatDate(
                                            (data['createdAt'] as Timestamp)
                                                .toDate(),
                                          ),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              // Right side: Amount with custom formatting.
                              Text(
                                displayAmount,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
