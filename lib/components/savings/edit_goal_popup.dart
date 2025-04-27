import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/database_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../components/savings/savings_currency_converter.dart';
import 'package:flutter/services.dart';

class EditGoalPopup extends StatelessWidget {
  final Map<String, dynamic> saving;

  const EditGoalPopup({Key? key, required this.saving}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controllers with default values (formatted as whole numbers)
    TextEditingController goalNameController = TextEditingController(
      text: saving['title'] ?? "",
    );
    TextEditingController goalAmountController = TextEditingController(
      text:
          saving['limit'] != null
              ? (saving['limit'] as num).toDouble().toStringAsFixed(0)
              : "",
    );
    TextEditingController emojiController = TextEditingController(
      text: saving['symbol'] ?? "",
    );
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Edit Goal"),
      content: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: goalNameController,
                  decoration: InputDecoration(
                    labelText: "Goal Name",
                    hintText: "Enter new goal name",
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FutureBuilder<String?>(
                future: dbProvider.getUserCurrency(
                  FirebaseAuth.instance.currentUser?.uid ?? "",
                ),
                builder: (context, snapshot) {
                  String userCurrency = snapshot.data ?? "MKD";
                  String goalCurrency = saving['currency'] ?? "MKD";

                  return SizedBox(
                    width: 300,
                    child: TextField(
                      controller: goalAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "New Goal Amount",
                        hintText: "Enter new goal amount",
                        border: const OutlineInputBorder(),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*$')),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: emojiController,
                  decoration: const InputDecoration(
                    labelText: "Emoji",
                    hintText: "Enter emoji",
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
          onPressed: () async {
            final userId = FirebaseAuth.instance.currentUser?.uid;
            final savingId =
                saving.containsKey('uniqueCode') ? saving['uniqueCode'] : null;
            if (userId == null || savingId == null) {
              print("❌ ERROR: User ID or Saving ID is NULL");
              return;
            }

            final dbProvider = Provider.of<DatabaseProvider>(
              context,
              listen: false,
            );
            final userCurrency =
                await dbProvider.getUserCurrency(userId) ?? "MKD";

            double newGoalAmount =
                double.tryParse(goalAmountController.text) ??
                (saving['limit'] as num).toDouble();
            // Convert Goal Amount properly
            double convertedGoalAmount = await SavingsCurrencyConverter()
                .convertAmount(userCurrency, saving['currency'], newGoalAmount);
            double convertedContribution = await SavingsCurrencyConverter()
                .convertAmount(
                  userCurrency,
                  saving['currency'],
                  (saving['contribution'] as num).toDouble(),
                );
            double newRemaining =
                (saving['remaining'] as num).toDouble() +
                (convertedGoalAmount - (saving['limit'] as num).toDouble());

            await dbProvider.updateSavingGoal(
              userId,
              savingId,
              goalNameController.text.isEmpty
                  ? saving['title']
                  : goalNameController.text,
              convertedContribution,
              convertedGoalAmount,
              emojiController.text.isEmpty
                  ? saving['symbol']
                  : emojiController.text,
              newRemaining,
              saving['currency'],
            );

            Provider.of<DatabaseProvider>(
              context,
              listen: false,
            ).notifyListeners();
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
