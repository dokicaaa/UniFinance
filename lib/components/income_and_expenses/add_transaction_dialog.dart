import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTransactionDialog extends StatefulWidget {
  final String userId;
  const AddTransactionDialog({Key? key, required this.userId})
    : super(key: key);

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  // Toggle between Income and Expense
  bool _isIncome = true;

  // Income fields (entered in MKD)
  final TextEditingController _incomeAmountController = TextEditingController();
  String _selectedSource = 'Job';
  String _selectedFrequency = 'Monthly';

  // Expense fields (entered in MKD)
  final TextEditingController _expenseAmountController =
      TextEditingController();
  bool _isRecurring = false;
  String _selectedCategory = 'Food';
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Emoji maps for visual flair
  final Map<String, String> incomeEmojis = {
    'Job': '💼',
    'Allowance': '💵',
    'Scholarships': '🎓',
  };

  final Map<String, String> expenseEmojis = {
    'Food': '🍕',
    'Transport': '🚗',
    'Rent': '🏠',
    'Entertainment': '🎬',
    'Others': '❓',
  };

  Future<void> _saveTransaction() async {
    if (_isIncome) {
      // Parse the amount as entered in MKD
      final amount = double.tryParse(_incomeAmountController.text) ?? 0.0;
      final docRef =
          FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('incomes')
              .doc();
      await docRef.set({
        'id': docRef.id,
        'source': _selectedSource,
        'amount': amount,
        'currency': 'MKD', // Always store in MKD
        'baseCurrency': 'MKD', // Mark that the base is MKD
        'frequency': _selectedFrequency,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      final amount = double.tryParse(_expenseAmountController.text) ?? 0.0;
      final docRef =
          FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('expenses')
              .doc();
      await docRef.set({
        'id': docRef.id,
        'expenseType': _isRecurring ? 'Recurring' : 'Normal',
        'category': _selectedCategory,
        'amount': amount,
        'currency': 'MKD', // Always store in MKD
        'baseCurrency': 'MKD',
        'startDate': _startDateController.text,
        'endDate': _endDateController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Optionally update the budget document if it exists.
      final budgetQuery =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .collection('budgets')
              .where('category', isEqualTo: _selectedCategory)
              .limit(1)
              .get();
      if (budgetQuery.docs.isNotEmpty) {
        final budgetDoc = budgetQuery.docs.first;
        final data = budgetDoc.data();
        double oldSpent = (data['spent'] ?? 0.0).toDouble();
        double limit = (data['limit'] ?? 0.0).toDouble();
        double newSpent = oldSpent + amount;
        double newRemaining = limit - newSpent;
        if (newRemaining < 0) newRemaining = 0;
        await budgetDoc.reference.update({
          'spent': newSpent,
          'remaining': newRemaining,
        });
      }
    }
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _incomeAmountController.dispose();
    _expenseAmountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isIncome ? 'Add Income' : 'Add Expense'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toggle for Income vs. Expense
            SizedBox(
              width: double.infinity,
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(8),
                isSelected: [_isIncome, !_isIncome],
                onPressed: (int index) {
                  setState(() {
                    _isIncome = (index == 0);
                  });
                },
                constraints: const BoxConstraints(minHeight: 50, minWidth: 130),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Income'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Expense'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_isIncome)
              // Income input fields (always in MKD)
              Column(
                children: [
                  DropdownButtonFormField<String>(
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: _incomeAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount (MKD)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedFrequency,
                    items:
                        const ['Daily', 'Weekly', 'Monthly', 'Yearly']
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
                ],
              )
            else
              // Expense input fields (always in MKD)
              Column(
                children: [
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
                  DropdownButtonFormField<String>(
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: _expenseAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount (MKD)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  // Optionally add date fields if needed.
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
        ElevatedButton(onPressed: _saveTransaction, child: const Text('Save')),
      ],
    );
  }
}
