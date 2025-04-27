import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/database_provider.dart';
import '../savings/savings_currency_converter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AddContributionPopup extends StatefulWidget {
  final String userId;
  final String uniqueCode;
  final double remainingAmount;
  final String goalCurrency; // The currency of the saving goal

  const AddContributionPopup({
    Key? key,
    required this.userId,
    required this.uniqueCode,
    required this.remainingAmount,
    required this.goalCurrency,
  }) : super(key: key);

  @override
  _AddContributionPopupState createState() => _AddContributionPopupState();
}

class _AddContributionPopupState extends State<AddContributionPopup> {
  TextEditingController contributionController = TextEditingController();
  String? errorMessage;

  void _addContribution(double amount) async {
    if (amount <= 0) {
      setState(() {
        errorMessage = "Enter a valid amount!";
      });
      return;
    }

    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
    String userCurrency =
        await dbProvider.getUserCurrency(widget.userId) ?? "MKD";

    // Convert contribution amount to saving goal's currency
    double convertedAmount = await dbProvider.convertSavingsAmount(
      amount,
      userCurrency,
      widget.goalCurrency,
    );
    convertedAmount = convertedAmount.toDouble();

    if (convertedAmount > widget.remainingAmount) {
      setState(() {
        errorMessage = "You cannot contribute more than the remaining amount!";
      });
      return;
    }

    await dbProvider.addContribution(
      widget.userId,
      widget.uniqueCode,
      convertedAmount,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Add Contribution"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder<String?>(
            future: dbProvider.getUserCurrency(
              FirebaseAuth.instance.currentUser?.uid ?? "",
            ),
            builder: (context, snapshot) {
              String userCurrency = snapshot.data ?? "MKD";
              return SizedBox(
                width: 300,
                child: TextField(
                  controller: contributionController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Amount ($userCurrency)",
                    errorText: errorMessage,
                    border: const OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*$')),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          FutureBuilder<String?>(
            future: dbProvider.getUserCurrency(
              FirebaseAuth.instance.currentUser?.uid ?? "",
            ),
            builder: (context, snapshot) {
              String userCurrency = snapshot.data ?? "MKD";
              return TextButton(
                onPressed: () => _addContribution(widget.remainingAmount),
                child: Text(
                  "Pay Full ($userCurrency ${widget.remainingAmount.toStringAsFixed(0)})",
                ),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            double contribution =
                double.tryParse(contributionController.text) ?? 0.0;
            _addContribution(contribution);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
