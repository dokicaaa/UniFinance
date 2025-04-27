import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/database_provider.dart';
import '../../components/savings/savings_currency_converter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AddGoalPopup extends StatefulWidget {
  @override
  _AddGoalPopupState createState() => _AddGoalPopupState();
}

class _AddGoalPopupState extends State<AddGoalPopup> {
  String goalName = "";
  double goalAmount = 0;
  String emoji = "💰";
  String selectedOption = "create"; // Default to "Create New Goal"
  TextEditingController codeController = TextEditingController();
  TextEditingController goalAmountController = TextEditingController();
  TextEditingController goalNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    goalAmountController.text = "0";
    goalNameController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
    final currencyConverter = SavingsCurrencyConverter();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Add New Goal"),
      content: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ChoiceChip(
                    label: const Text("Create"),
                    selected: selectedOption == "create",
                    onSelected: (selected) {
                      setState(() {
                        selectedOption = "create";
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text("Join"),
                    selected: selectedOption == "join",
                    onSelected: (selected) {
                      setState(() {
                        selectedOption = "join";
                      });
                    },
                  ),
                ],
              ),
              if (selectedOption == "create")
                Column(
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: goalNameController,
                        decoration: const InputDecoration(
                          labelText: "Goal Name",
                          hintText: "Enter goal name",
                          border: OutlineInputBorder(),
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
                        return SizedBox(
                          width: 300,
                          child: TextField(
                            controller: goalAmountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*$'),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: "Enter Amount ($userCurrency)",
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: "Emoji",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          emoji = value;
                        },
                      ),
                    ),
                  ],
                ),
              if (selectedOption == "join")
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: "Enter Unique Code",
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
            if (userId != null) {
              final dbProvider = Provider.of<DatabaseProvider>(
                context,
                listen: false,
              );
              final userCurrency =
                  await dbProvider.getUserCurrency(userId) ?? "MKD";

              if (selectedOption == "create") {
                goalAmount = double.tryParse(goalAmountController.text) ?? 0;
                if (goalAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid goal amount"),
                    ),
                  );
                  return;
                }
                Map<String, dynamic> convertedGoalData = await currencyConverter
                    .convertSavings({
                      'limit': goalAmount,
                      'currency': userCurrency,
                    });
                double convertedGoalAmount = convertedGoalData['limit'];

                if (goalNameController.text.isNotEmpty) {
                  await dbProvider.addSavingGoal(
                    userId,
                    goalNameController.text,
                    convertedGoalAmount,
                    emoji,
                    userCurrency,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Saving Goal Added Successfully!"),
                    ),
                  );
                }
              } else if (selectedOption == "join") {
                if (codeController.text.isNotEmpty) {
                  await dbProvider.joinSavingGoal(userId, codeController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Joined Saving Goal Successfully!"),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a valid code")),
                  );
                }
              }
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
