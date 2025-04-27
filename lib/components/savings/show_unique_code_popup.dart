import 'package:flutter/material.dart';

class ShowUniqueCodePopup extends StatelessWidget {
  final String uniqueCode;

  const ShowUniqueCodePopup({Key? key, required this.uniqueCode})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        "Share this code with your friends!",
        style: TextStyle(fontSize: 20),
      ),
      content: Row(
        children: [
          Text("Code: ", style: TextStyle(fontSize: 18)),
          Text(uniqueCode, style: TextStyle(fontSize: 18)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Close"),
        ),
      ],
    );
  }
}
