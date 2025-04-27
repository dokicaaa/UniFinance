import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddIncomeDialog extends StatefulWidget {
  final String userId;
  final String userCurrency; // The user’s currency from Firestore

  const AddIncomeDialog({
    Key? key,
    required this.userId,
    required this.userCurrency,
  }) : super(key: key);

  @override
  State<AddIncomeDialog> createState() => _AddIncomeDialogState();
}

class _AddIncomeDialogState extends State<AddIncomeDialog> {
  final _amountController = TextEditingController();
  String _selectedSource = 'Job';
  String _selectedFrequency = 'Monthly';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Income'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Source dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Source'),
              value: _selectedSource,
              items: ['Job', 'Allowance', 'Scholarships'].map((source) {
                return DropdownMenuItem<String>(
                  value: source,
                  child: Text(source),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSource = value!;
                });
              },
            ),

            // Amount
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),

            // Frequency dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Frequency'),
              value: _selectedFrequency,
              items: ['Daily', 'Weekly', 'Monthly', 'Yearly'].map((freq) {
                return DropdownMenuItem<String>(
                  value: freq,
                  child: Text(freq),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFrequency = value!;
                });
              },
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
          onPressed: _saveIncome,
          child: const Text('Save Changes'),
        ),
      ],
    );
  }

  Future<void> _saveIncome() async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('incomes')
        .doc();

    await docRef.set({
      'id': docRef.id,
      'source': _selectedSource,
      'amount': double.tryParse(_amountController.text) ?? 0.0,
      'currency': widget.userCurrency, // Use user’s currency from constructor
      'frequency': _selectedFrequency,
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.of(context).pop();
  }
}
