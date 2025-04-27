import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:banking4students/services/auth/auth_service.dart';
import 'package:banking4students/components/income_and_expenses/balance_overview.dart';
import 'package:banking4students/components/income_and_expenses/transactions_list.dart';

class BalancePage extends StatelessWidget {
  const BalancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    if (user == null) {
      return const Center(child: Text('Please log in to view expenses.'));
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: height),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    // OverviewCard (top 40%)
                    Container(child: BalanceOverview(userId: user.uid)),
                    Container(
                      child: TransactionsList(
                        userId: user.uid,
                        limit: 5,
                        showSeeAll: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
