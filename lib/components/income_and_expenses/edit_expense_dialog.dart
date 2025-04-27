import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditExpenseDialog extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> expenseData;
  final String docId;

  const EditExpenseDialog({
    Key? key,
    required this.userId,
    required this.expenseData,
    required this.docId,
  }) : super(key: key);

  @override
  State<EditExpenseDialog> createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends State<EditExpenseDialog> {
  late bool _isRecurring;
  late String _selectedCategory;
  late TextEditingController _amountController;

  // Expense emojis for visual flair (same as add transaction)
  final Map<String, String> expenseEmojis = {
    'Food': '🍕',
    'Transport': '🚗',
    'Rent': '🏠',
    'Entertainment': '🎬',
    'Others': '❓',
  };

  @override
  void initState() {
    super.initState();
    _isRecurring =
        (widget.expenseData['expenseType'] ?? 'Normal') == 'Recurring';
    _selectedCategory = widget.expenseData['category'] ?? 'Food';
    double amt =
        double.tryParse(widget.expenseData['amount']?.toString() ?? '0') ?? 0.0;
    _amountController = TextEditingController(
      text: amt.toStringAsFixed(0), // Format as whole number
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _updateExpense() async {
    final double newAmount = double.tryParse(_amountController.text) ?? 0.0;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('expenses')
        .doc(widget.docId)
        .update({
          'expenseType': _isRecurring ? 'Recurring' : 'Normal',
          'category': _selectedCategory,
          'amount': newAmount,
          'currency': 'MKD',
          'baseCurrency': 'MKD',
        });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Expense'),
      content: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Recurring toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recurring'),
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
              const SizedBox(height: 12),
              // Category dropdown
              SizedBox(
                width: 300,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCategory,
                  items:
                      expenseEmojis.keys.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text('${expenseEmojis[cat]} $cat'),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Amount text field (always in MKD)
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount (MKD)',
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateExpense,
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
