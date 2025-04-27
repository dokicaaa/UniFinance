import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddExpenseDialog extends StatefulWidget {
  final String userId;
  const AddExpenseDialog({Key? key, required this.userId}) : super(key: key);

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  bool _isRecurring = false;
  String _selectedCategory = 'Food';
  final TextEditingController _amountController = TextEditingController();

  // For demonstration, store start/end as text. (No real date logic yet)
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Expense'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Expense Type (Switch)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Expense Type'),
                Switch(
                  value: _isRecurring,
                  onChanged: (value) {
                    setState(() {
                      _isRecurring = value;
                    });
                  },
                ),
              ],
            ),

            // Category dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Category'),
              value: _selectedCategory,
              items: ['Food', 'Transport', 'Rent', 'Entertainment', 'Others']
                  .map((cat) => DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),

            // Amount
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),

            const SizedBox(height: 10),

            // Row for Start / End date
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startDateController,
                    decoration: const InputDecoration(labelText: 'Start Date'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _endDateController,
                    decoration: const InputDecoration(labelText: 'End Date'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveExpense,
          child: const Text('Add New Expense'),
        ),
      ],
    );
  }

  Future<void> _saveExpense() async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('expenses')
        .doc();

    await docRef.set({
      'id': docRef.id,
      'expenseType': _isRecurring ? 'Recurring' : 'Normal',
      'category': _selectedCategory,
      'amount': double.tryParse(_amountController.text) ?? 0.0,
      'startDate': _startDateController.text, // For now, just store as text
      'endDate': _endDateController.text,     // For now, just store as text
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.of(context).pop(); // Close the dialog
  }
}
