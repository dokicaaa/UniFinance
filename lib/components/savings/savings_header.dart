import 'package:flutter/material.dart';
import '../savings/add_saving_goal.dart';
import '../rounded_dropdown.dart';

class SavingsHeader extends StatefulWidget {
  final Function(String) onFilterChanged;

  const SavingsHeader({Key? key, required this.onFilterChanged}) : super(key: key);

  @override
  _SavingsHeaderState createState() => _SavingsHeaderState();
}

class _SavingsHeaderState extends State<SavingsHeader> {
  String selectedCategory = 'Pending';
  List<String> savingsCategories = ['Pending', 'Completed', 'All'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RoundedPillDropdown(
          selectedValue: selectedCategory,
          options: savingsCategories,
          onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedCategory = value;
                              widget.onFilterChanged(selectedCategory);
                            });
                          }
                        },
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        dropdownColor: Colors.blue[300],
                        borderRadius: 20.0,
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AddGoalPopup(),
            );
          },
        ),
      ],
    );
  }
}
