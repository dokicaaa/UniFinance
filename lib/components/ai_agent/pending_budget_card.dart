import 'package:flutter/material.dart';

class PendingBudgetCard extends StatefulWidget {
  final List<dynamic> pendingBudgets;
  final Function(String, double) onConfirm;
  final Function(String) onDecline;

  const PendingBudgetCard({
    Key? key,
    required this.pendingBudgets,
    required this.onConfirm,
    required this.onDecline,
  }) : super(key: key);

  @override
  _PendingBudgetCardState createState() => _PendingBudgetCardState();
}

class _PendingBudgetCardState extends State<PendingBudgetCard> {
  String? _loadingCategory; // Track which budget is being created

  @override
  Widget build(BuildContext context) {
    if (widget.pendingBudgets.isEmpty) return const SizedBox.shrink();

    return Column(
      children:
          widget.pendingBudgets.map((budget) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "⚠️ No Budget for ${budget["category"]}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(budget["message"]),
                    const SizedBox(height: 10),

                    // Buttons with loader
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _loadingCategory == budget["category"]
                            ? const CircularProgressIndicator() // Show loader when clicked
                            : ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  _loadingCategory =
                                      budget["category"]; // Show loader
                                });

                                await widget.onConfirm(
                                  budget["category"],
                                  budget["suggested_budget"]
                                      .toDouble(), // Ensure correct type
                                );

                                setState(() {
                                  _loadingCategory =
                                      null; // Remove loader after completion
                                });
                              },
                              child: const Text("Yes"),
                            ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () {
                            widget.onDecline(budget["category"]);
                          },
                          child: const Text("No"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
