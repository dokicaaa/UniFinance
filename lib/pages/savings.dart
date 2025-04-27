import 'package:flutter/material.dart';
import '../components/savings/savings_header.dart';
import '../components/savings/savings_list.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({Key? key}) : super(key: key);

  @override
  _SavingsPageState createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  String selectedCategory = 'Pending';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SavingsHeader(
              onFilterChanged: (category) {
                setState(() {
                  selectedCategory = category; // ✅ Update category
                });
              },
            ),
            SavingsList(filterCategory: selectedCategory), // ✅ Pass filter
          ],
        ),
      ),
    );
  }
}
