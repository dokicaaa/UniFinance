import 'package:banking4students/pages/savings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/database_provider.dart';
import '../savings/savings_currency_converter.dart';
import '../savings/savings_card.dart';
import '../savings/edit_goal_popup.dart';
import '../../providers/navigation_provider.dart';

class SavingsList extends StatefulWidget {
  final String filterCategory;

  const SavingsList({super.key, required this.filterCategory});

  @override
  _SavingsListState createState() => _SavingsListState();
}

class _SavingsListState extends State<SavingsList> {
  @override
  void initState() {
    super.initState();
    _refreshSavings();
  }

  void _refreshSavings() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text("Error: User not logged in"));
    }

    return StreamBuilder<Map<String, dynamic>?>(
      stream: Provider.of<DatabaseProvider>(context, listen: false).getUserDocStream(userId),
      builder: (context, userDocSnapshot) {
        if (userDocSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (userDocSnapshot.hasError) {
          return Center(child: Text("Error loading user data: ${userDocSnapshot.error}"));
        }
        if (userDocSnapshot.data == null) {
          return const Center(child: Text("No user data found"));
        }

        final userData = userDocSnapshot.data!;
        final String userCurrency = userData['currency'] ?? 'USD';
        final currencyConverter = SavingsCurrencyConverter();

        return Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: Provider.of<DatabaseProvider>(context, listen: true).getUserSavings(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                print("⚠️ Error loading savings: ${snapshot.error}");
                return Center(child: Text('Error loading savings goals: ${snapshot.error}'));
              }

              var savings = snapshot.data ?? [];

              // Filter savings based on the selected category
              if (widget.filterCategory == 'Pending') {
                savings = savings.where((goal) => (goal['remaining'] ?? 0) > 0).toList();
              } else if (widget.filterCategory == 'Completed') {
                savings = savings.where((goal) => (goal['remaining'] ?? 0) == 0).toList();
              }
  
              if (savings.isEmpty) {
                return const Center(child: Text('No savings goals found.'));
              }

              return ListView.builder(
                itemCount: savings.length,
                itemBuilder: (context, index) {
                  var saving = savings[index];

                  if (!saving.containsKey('uniqueCode')) {
                    return const SizedBox.shrink();
                  }

                  return FutureBuilder<Map<String, dynamic>>(
                    future: currencyConverter.convertSavings(saving),
                    builder: (context, convertedSnapshot) {
                      if (!convertedSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final convertedSaving = convertedSnapshot.data!;

                      bool isOwner = convertedSaving['ownerId'] == userId;

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Dismissible(
                          key: Key(convertedSaving['uniqueCode'] ?? 'unknown_key'),
                          direction: isOwner ? DismissDirection.horizontal : DismissDirection.endToStart,
                          background: _swipeActionButton(
                            context,
                            color: Colors.blue,
                            icon: Icons.edit,
                            text: "Edit",
                            isLeft: true,
                            isVisible: isOwner,
                          ),
                          secondaryBackground: _swipeActionButton(
                            context,
                            color: Colors.red,
                            icon: isOwner ? Icons.delete : Icons.exit_to_app,
                            text: isOwner ? "Delete" : "Leave",
                            isLeft: false,
                            isVisible: true,
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              _showDeleteOrLeaveDialog(context, userId, convertedSaving, isOwner);
                            }else if(direction == DismissDirection.startToEnd){
                              _showEditGoalDialog(context, convertedSaving);
                            }
                            // Prevent the automatic dismissal
                            return false;
                          },
                          child: SavingsCard(
                            saving: convertedSaving,
                            userId: userId,
                            currentCurrency: userCurrency,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _swipeActionButton(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String text,
    required bool isLeft,
    required bool isVisible,
  }) {
    return isVisible
        ? Container(
            alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: color,
            child: Row(
              mainAxisAlignment: isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                if (!isLeft) 
                Spacer(),
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  void _showEditGoalDialog(BuildContext context, Map<String, dynamic> saving) {
    showDialog(
      context: context,
      builder: (context) {
        return EditGoalPopup(saving: saving);
      },
    );
  }

  void _showDeleteOrLeaveDialog(BuildContext context, String userId, Map<String, dynamic> saving, bool isOwner) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(isOwner ? "Delete Saving Goal" : "Leave Saving Goal"),
          content: Text(
            isOwner
                ? "Are you sure you want to delete this saving goal? This action cannot be undone."
                : "Are you sure you want to leave this saving goal?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);

                if (isOwner) {
                  await Provider.of<DatabaseProvider>(context, listen: false)
                      .deleteSavingGoal(userId, saving['uniqueCode']);
                } else {
                  await Provider.of<DatabaseProvider>(context, listen: false)
                      .leaveSavingGoal(userId, saving['uniqueCode']);
                }

                // Refresh data
                _refreshSavings();

                // Set a new valid screen after deletion
                navigationProvider.setScreen(SavingsPage());

                // Close the dialog
                Navigator.pop(context);
              },
              child: Text(isOwner ? "Delete" : "Leave"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }
}
