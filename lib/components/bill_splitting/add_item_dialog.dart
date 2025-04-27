import 'package:flutter/material.dart';

class AddItemDialog extends StatefulWidget {
  const AddItemDialog({Key? key}) : super(key: key);

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null), // Return null
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            final price = double.tryParse(_priceController.text) ?? 0.0;
            if (name.isNotEmpty) {
              // Return the new item as a map
              Navigator.of(context).pop({"name": name, "price": price});
            } else {
              // If no name, just close or show an error
              Navigator.of(context).pop(null);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
