import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> populateDummyBudgets(String userId) async {
  final budgetsCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('budgets');

  try {
    // Dummy budget for Food
    await budgetsCollection.add({
      'userId': userId,
      'category': 'Food',
      'limit': 300.0,
      'spent': 50.0,
      'remaining': 250.0,
    });
    // Dummy budget for Transport
    await budgetsCollection.add({
      'userId': userId,
      'category': 'Transport',
      'limit': 150.0,
      'spent': 20.0,
      'remaining': 130.0,
    });
    // Dummy budget for Rent
    await budgetsCollection.add({
      'userId': userId,
      'category': 'Rent',
      'limit': 1000.0,
      'spent': 1000.0,
      'remaining': 0.0,
    });
    // Dummy budget for Entertainment
    await budgetsCollection.add({
      'userId': userId,
      'category': 'Entertainment',
      'limit': 200.0,
      'spent': 80.0,
      'remaining': 120.0,
    });
    print("Dummy budgets populated successfully for user $userId");
  } catch (e) {
    print("Error populating dummy budgets: $e");
  }
}
