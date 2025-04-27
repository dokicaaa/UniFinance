import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddBudgetDialog extends StatefulWidget {
  final String userId;
  const AddBudgetDialog({Key? key, required this.userId}) : super(key: key);

  @override
  State<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  // Fields for the budget
  String _selectedFrequency = "Weekly";
  String _selectedCategory = "Food";
  final TextEditingController _amountController = TextEditingController(
    text: "0",
  );

  // Fixed lists; you can adjust or fetch dynamically if needed.
  final List<String> _frequencies = ["Daily", "Weekly", "Monthly", "Yearly"];
  final List<String> _categories = [
    "Food",
    "Transport",
    "Rent",
    "Entertainment",
    "Others",
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Budget"),
      content: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Frequency dropdown
              SizedBox(
                width: 300,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Frequency",
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedFrequency,
                  items:
                      _frequencies
                          .map(
                            (freq) => DropdownMenuItem(
                              value: freq,
                              child: Text(freq),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFrequency = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Category dropdown
              SizedBox(
                width: 300,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCategory,
                  items:
                      _categories
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Amount text field
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Budget Amount (MKD)",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _saveBudget,
          child: const Text("Save Budget"),
        ),
      ],
    );
  }

  Future<void> _saveBudget() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final docRef =
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('budgets')
            .doc();
    await docRef.set({
      'id': docRef.id,
      'userId': widget.userId,
      'category': _selectedCategory,
      'limit': amount,
      'spent': 0.0, // initial spent value
      'remaining': amount, // initially remaining equals limit
      'frequency': _selectedFrequency,
      'createdAt': FieldValue.serverTimestamp(),
    });
    Navigator.pop(context);
  }
}
