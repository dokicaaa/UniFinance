import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final String note;
  final Timestamp date;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      note: data['note'] ?? '',
      date: data['date'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'category': category,
      'note': note,
      'date': date,
    };
  }
}
