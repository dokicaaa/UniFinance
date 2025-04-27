import '../../utility/currency_converter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsCurrencyConverter {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> convertSavings(Map<String, dynamic> saving) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return saving; // Exit if no user is logged in

    final userDoc = await _firestore.collection('users').doc(userId).get();
    String userCurrency = userDoc.data()?['currency'] ?? "MKD"; // Default to MKD
    String savingsCurrency = saving['currency'] ?? "MKD"; // Default to MKD

    if (userCurrency == savingsCurrency) return saving; // No conversion needed

  // 🔹 Convert values, ensuring they are treated as doubles
    double limit = (saving['limit'] as num).toDouble();
    double contribution = (saving['contribution'] as num).toDouble();
    double remaining = (saving['remaining'] as num).toDouble();

    // Convert amounts to user's currency
    double convertedLimit = await convertCurrency(limit, savingsCurrency, userCurrency);
    double convertedContribution = await convertCurrency(contribution, savingsCurrency, userCurrency);
    double convertedRemaining = await convertCurrency(remaining, savingsCurrency, userCurrency);;

    return {
      ...saving,
      'limit': convertedLimit,
      'contribution': convertedContribution,
      'remaining': convertedRemaining,
      'currency': userCurrency, // Display in user's currency
    };
  }

  Future<double> convertAmount(String fromCurrency, String toCurrency, double amount) async {
    return await convertCurrency(amount, fromCurrency, toCurrency);
  }
}