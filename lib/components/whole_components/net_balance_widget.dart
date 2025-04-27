import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

/// A widget that calculates net = sum(incomes) - sum(expenses)
/// and displays it at the top in a style similar to your screenshot.
class NetBalanceWidget extends StatelessWidget {
  final String userId;
  const NetBalanceWidget({Key? key, required this.userId}) : super(key: key);

  /// Sums all incomes for the user.
  Stream<double> _sumIncomes() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('incomes')
        .snapshots()
        .map((snapshot) {
          double total = 0.0;
          for (var doc in snapshot.docs) {
            final data = doc.data();
            total += (data['amount'] ?? 0.0).toDouble();
          }
          return total;
        });
  }

  /// Sums all expenses for the user.
  Stream<double> _sumExpenses() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .snapshots()
        .map((snapshot) {
          double total = 0.0;
          for (var doc in snapshot.docs) {
            final data = doc.data();
            total += (data['amount'] ?? 0.0).toDouble();
          }
          return total;
        });
  }

  /// Combines incomes and expenses into a single net value: net = incomes - expenses
  Stream<double> _netBalanceStream() {
    return Rx.combineLatest2<double, double, double>(
      _sumIncomes(),
      _sumExpenses(),
      (inc, exp) => inc - exp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: _netBalanceStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final netBalance = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total Net Balance",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "The net balance of every Income and Expense",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Text(
                "\$${netBalance.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
