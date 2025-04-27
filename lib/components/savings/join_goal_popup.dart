import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/database_provider.dart';

class JoinGoalPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController codeController = TextEditingController();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text("Join Saving Goal"),
      content: TextField(
        controller: codeController,
        decoration: InputDecoration(labelText: "Enter Unique Code"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            final userId = FirebaseAuth.instance.currentUser?.uid;
            if (userId != null) {
              final code = codeController.text.trim();
              if (code.isNotEmpty) {
                await Provider.of<DatabaseProvider>(context, listen: false)
                    .joinSavingGoal(userId, code);
              }
            }
            Navigator.pop(context);
          },
          child: Text("Join"),
        ),
      ],
    );
  }
}