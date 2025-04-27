import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String id;
  final String userId;
  final String category;
  final double limit;
  final double spent;
  final double remaining;
  final String frequency; // e.g. Daily, Weekly, Monthly, Yearly

  BudgetModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.limit,
    required this.spent,
    required this.remaining,
    required this.frequency,
  });

  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BudgetModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      limit: (data['limit'] ?? 0.0).toDouble(),
      spent: (data['spent'] ?? 0.0).toDouble(),
      remaining: (data['remaining'] ?? 0.0).toDouble(),
      frequency: data['frequency'] ?? 'Weekly',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'category': category,
      'limit': limit,
      'spent': spent,
      'remaining': remaining,
      'frequency': frequency,
    };
  }
}
