import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditIncomeDialog extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> incomeData;
  final String docId;

  const EditIncomeDialog({
    Key? key,
    required this.userId,
    required this.incomeData,
    required this.docId,
  }) : super(key: key);

  @override
  State<EditIncomeDialog> createState() => _EditIncomeDialogState();
}

class _EditIncomeDialogState extends State<EditIncomeDialog> {
  late TextEditingController _amountController;
  late String _selectedSource;
  late String _selectedFrequency;

  // Income emojis for visual flair (same as add transaction)
  final Map<String, String> incomeEmojis = {
    'Job': '💼',
    'Allowance': '💵',
    'Scholarships': '🎓',
  };

  @override
  void initState() {
    super.initState();
    _selectedSource = widget.incomeData['source'] ?? 'Job';
    _selectedFrequency = widget.incomeData['frequency'] ?? 'Monthly';
    double amt =
        double.tryParse(widget.incomeData['amount']?.toString() ?? '0') ?? 0.0;
    _amountController = TextEditingController(
      text: amt.toStringAsFixed(0), // Format as whole number
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _updateIncome() async {
    final double newAmount = double.tryParse(_amountController.text) ?? 0.0;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('incomes')
        .doc(widget.docId)
        .update({
          'source': _selectedSource,
          'amount': newAmount,
          'currency': 'MKD',
          'baseCurrency': 'MKD',
          'frequency': _selectedFrequency,
        });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Income'),
      content: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Source dropdown
              SizedBox(
                width: 300,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Source',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedSource,
                  items:
                      incomeEmojis.keys.map((source) {
                        return DropdownMenuItem(
                          value: source,
                          child: Text('${incomeEmojis[source]} $source'),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSource = value!;
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
              const SizedBox(height: 12),
              // Frequency dropdown
              SizedBox(
                width: 300,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedFrequency,
                  items:
                      const ['Daily', 'Weekly', 'Monthly', 'Yearly'].map((
                        freq,
                      ) {
                        return DropdownMenuItem(value: freq, child: Text(freq));
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFrequency = value!;
                    });
                  },
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
          onPressed: _updateIncome,
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
