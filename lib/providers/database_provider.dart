import 'package:banking4students/utility/currency_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:banking4students/models/user.dart';
import 'package:rxdart/rxdart.dart';
import '../components/savings/savings_currency_converter.dart';
import '../utility/generate_unique_code.dart';

class DatabaseProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== FRIENDS SYSTEM ========== //
  // Add these methods to your DatabaseProvider class
  Future<void> addFriend(String currentUserId, String friendUserId) async {
    try {
      if (currentUserId == friendUserId) throw Exception("Can't add yourself");

      // Check if friend already exists
      final friendRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('friends')
          .doc(friendUserId);

      final existingFriend = await friendRef.get();
      if (existingFriend.exists) {
        throw Exception('This user is already your friend');
      }

      final friendDoc =
          await _firestore.collection('users').doc(friendUserId).get();
      if (!friendDoc.exists) throw Exception("User not found");

      final friendData = friendDoc.data()!;
      final currentUserDoc =
          await _firestore.collection('users').doc(currentUserId).get();

      final batch = _firestore.batch();

      // Add to current user's friends
      batch.set(friendRef, {
        'uid': friendUserId,
        'name': friendData['name'],
        'surname': friendData['surname'],
        'email': friendData['email'],
        'profileImageUrl': friendData['profileImageUrl'],
        'addedAt': Timestamp.now(),
      });

      // Add reciprocal document
      batch.set(
        _firestore
            .collection('users')
            .doc(friendUserId)
            .collection('friends')
            .doc(currentUserId),
        {
          'uid': currentUserId,
          'name': currentUserDoc['name'],
          'surname': currentUserDoc['surname'],
          'email': currentUserDoc['email'],
          'profileImageUrl': currentUserDoc['profileImageUrl'],
          'addedAt': Timestamp.now(),
        },
      );

      // Update counters
      batch.update(_firestore.collection('users').doc(currentUserId), {
        'friendsCount': FieldValue.increment(1),
      });
      batch.update(_firestore.collection('users').doc(friendUserId), {
        'friendsCount': FieldValue.increment(1),
      });

      await batch.commit();
      notifyListeners();
    } catch (e) {
      print("Error adding friend: $e");
      rethrow;
    }
  }

  Future<void> deleteFriend(String currentUserId, String friendUserId) async {
    try {
      final batch = _firestore.batch();

      // Remove from current user's friends
      batch.delete(
        _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('friends')
            .doc(friendUserId),
      );

      // Remove reciprocal document
      batch.delete(
        _firestore
            .collection('users')
            .doc(friendUserId)
            .collection('friends')
            .doc(currentUserId),
      );

      // Update counters
      batch.update(_firestore.collection('users').doc(currentUserId), {
        'friendsCount': FieldValue.increment(-1),
      });
      batch.update(_firestore.collection('users').doc(friendUserId), {
        'friendsCount': FieldValue.increment(-1),
      });

      await batch.commit();
      notifyListeners();
    } catch (e) {
      print("Error deleting friend: $e");
      rethrow;
    }
  }

  Stream<List<UserModel>> getFriends(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => UserModel.fromFriendDoc(doc.data()))
                  .toList(),
        );
  }

  Future<void> updateUserProfilePicture(
    String userId,
    String newProfileImageUrl,
  ) async {
    await _firestore.collection('users').doc(userId).update({
      'profileImageUrl': newProfileImageUrl,
    });

    void notifyListeners() {
      super.notifyListeners();
    }

    // ✅ Update all savings where this user is a contributor
    await updateContributorProfilePicture(userId, newProfileImageUrl);
  }

  // Update contributors' profile pictures in all savings goals
  Future<void> updateContributorProfilePicture(
    String userId,
    String newProfileImageUrl,
  ) async {
    try {
      // ✅ Step 1: Update profile picture in user's Firestore document
      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': newProfileImageUrl,
      });

      // ✅ Step 2: Get all `uniqueCode`s from savings this user has joined
      final userDoc = await _firestore.collection('users').doc(userId).get();
      List<String> joinedCodes = List<String>.from(
        userDoc.data()?['joinedSavings'] ?? [],
      );

      if (joinedCodes.isEmpty) return; // ✅ No joined goals, exit early

      // ✅ Step 3: Find savings using `uniqueCode`
      final query =
          await _firestore
              .collectionGroup('savings')
              .where(
                'uniqueCode',
                whereIn: joinedCodes,
              ) // 🔥 Uses `uniqueCode` instead of `contributors`
              .get();

      for (var doc in query.docs) {
        final goalId = doc.id;
        final ownerId = doc['ownerId'];

        // ✅ Step 4: Update only the contributor's profile picture inside the savings goal
        await _firestore
            .collection('users')
            .doc(ownerId)
            .collection('savings')
            .doc(goalId)
            .update({
              'contributors.$userId.profileImageUrl': newProfileImageUrl,
            });
      }

      notifyListeners(); // ✅ Refresh UI
    } catch (e) {
      print("⚠️ Error updating contributor profile pictures: $e");
    }
  }

  Stream<Map<String, dynamic>?> getUserDocStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.exists ? snapshot.data() : null);
  }

  Stream<List<Map<String, dynamic>>> getCombinedTransactions(
    String userId, {
    int? limit,
  }) {
    final incomeStream = _firestore
        .collection('users')
        .doc(userId)
        .collection('incomes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['docId'] = doc.id;
                data['type'] = 'income';
                data['baseCurrency'] = 'USD';
                return data;
              }).toList(),
        );
    final expenseStream = _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['docId'] = doc.id;
                data['type'] = 'expense';
                data['baseCurrency'] = 'USD';
                return data;
              }).toList(),
        );
    return Rx.combineLatest2<
      List<Map<String, dynamic>>,
      List<Map<String, dynamic>>,
      List<Map<String, dynamic>>
    >(incomeStream, expenseStream, (incomes, expenses) {
      final merged = [...incomes, ...expenses];
      merged.sort((a, b) {
        final aTime =
            a['createdAt'] != null
                ? (a['createdAt'] as Timestamp).toDate()
                : DateTime(0);
        final bTime =
            b['createdAt'] != null
                ? (b['createdAt'] as Timestamp).toDate()
                : DateTime(0);
        return bTime.compareTo(aTime);
      });
      if (limit != null) {
        return merged.take(limit).toList();
      }
      return merged;
    });
  }

  // Get user savings
  Stream<List<Map<String, dynamic>>> getUserSavings(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('savings')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> savings = snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

    final userDoc = await _firestore.collection('users').doc(userId).get();
    List<String> joinedCodes = List<String>.from(userDoc.data()?['joinedSavings'] ?? []);

    if (joinedCodes.isNotEmpty) {
      final joinedGoalsQuery = await _firestore
          .collectionGroup('savings')
          .where('uniqueCode', whereIn: joinedCodes)
          .get();

      List<Map<String, dynamic>> joinedSavings = joinedGoalsQuery.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      savings.addAll(joinedSavings);
    }

    return savings;
  });
}

  // Add a new saving goal
  Future<void> addSavingGoal(
    String userId,
    String goalName,
    double limit,
    String symbol,
    String currency,
  ) async {
    try {
      final uniqueCode = generateUniqueCode();
      print(
        "📌 Adding Saving Goal: $goalName | Amount: $limit | Currency: $currency",
      );

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final profileImageURL = userDoc.data()?['profileImageUrl'] ?? "";

      final newSaving = {
        'title': goalName,
        'limit': limit,
        'remaining': limit,
        'contribution': 0,
        'symbol': symbol.isEmpty ? '💰' : symbol,
        'ownerId': userId,
        'uniqueCode': uniqueCode,
        'completed': false,
        'currency': currency,
        'contributors': {
          userId: {'profileImageUrl': profileImageURL, 'isOwner': true},
        },
        'createdAt': Timestamp.now(),
      };

      // ✅ Add debug message before Firestore write
      print("✅ Writing to Firestore...");
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('savings')
          .add(newSaving);

      print("✅ Saving Goal Successfully Added!");
      notifyListeners();
    } catch (e) {
      print("❌ Error adding saving goal: $e");
    }
  }

  // Update a saving goal
  Future<void> updateSavingGoal(
    String userId,
    String uniqueCode, // Ensure uniqueCode is used
    String newTitle,
    double newContribution,
    double newLimit,
    String newSymbol,
    double newRemaining,
    String newCurrency,
  ) async {
    try {
      print(
        "📌 Updating Saving Goal: Unique Code -> $uniqueCode for User: $userId",
      );

      // 🔹 Query Firestore to find the document by `uniqueCode`
      final querySnapshot =
          await _firestore
              .collectionGroup(
                'savings',
              ) // Searches all user savings collections
              .where('uniqueCode', isEqualTo: uniqueCode)
              .limit(1) // Ensures we only get one result
              .get();

      if (querySnapshot.docs.isEmpty) {
        print("❌ ERROR: Saving goal not found in Firestore!");
        return;
      }

      final goalDoc = querySnapshot.docs.first;
      final goalId = goalDoc.id;
      final ownerId = goalDoc['ownerId'];

      print("✅ Found Goal ID: $goalId in Firestore!");

      await _firestore
          .collection('users')
          .doc(ownerId)
          .collection('savings')
          .doc(goalId)
          .update({
            'title': newTitle,
            'limit': newLimit,
            'remaining': newRemaining,
            'symbol': newSymbol,
            'currency': newCurrency,
            'contribution': newContribution,
          });

      print("✅ Saving Goal Updated Successfully!");
      notifyListeners();
    } catch (e) {
      print("❌ Error updating saving goal: $e");
    }
  }

  Future<double> convertSavingsAmount(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) async {
    if (fromCurrency == toCurrency) {
      return amount; // No conversion needed
    }

    double convertedAmount = await convertCurrency(
      amount,
      fromCurrency,
      toCurrency,
    );
    return convertedAmount;
  }

  Future<String?> getUserCurrency(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data()?['currency'] ??
        "MKD"; // Default to MKD if no currency is set
  }

  // Join a saving goal
  Future<void> joinSavingGoal(String userId, String uniqueCode) async {
    print("📌 joinSavingGoal called with userId: $userId, uniqueCode: $uniqueCode");

    try {
      final query = await _firestore
          .collectionGroup('savings')
          .where('uniqueCode', isEqualTo: uniqueCode)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final goalDoc = query.docs.first;
        final ownerId = goalDoc['ownerId'];

        final userDoc = await _firestore.collection('users').doc(userId).get();
        final profileImageURL = userDoc.data()?['profileImageUrl'] ?? "";

        await goalDoc.reference.update({
          'contributors.$userId': {
            'profileImageUrl': profileImageURL,
            'isOwner': false,
          },
        });

        await _firestore.collection('users').doc(userId).update({
          'joinedSavings': FieldValue.arrayUnion([uniqueCode]),
        });

        print("✅ Joined saving goal successfully");
        notifyListeners();
      } else {
        print("❌ No goal found with uniqueCode: $uniqueCode");
      }
    } catch (e) {
      print("⚠️ Error joining saving goal: $e");
    }
  }

  // Leave a saving goal
  Future<void> leaveSavingGoal(String userId, String uniqueCode) async {
    try {
      final query =
          await _firestore
              .collectionGroup('savings')
              .where('uniqueCode', isEqualTo: uniqueCode)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        final goalDoc = query.docs.first;
        final goalId = goalDoc.id;
        final ownerId = goalDoc['ownerId'];

        await _firestore
            .collection('users')
            .doc(ownerId)
            .collection('savings')
            .doc(goalId)
            .update({'contributors.$userId': FieldValue.delete()});

        await _firestore.collection('users').doc(userId).update({
          'joinedSavings': FieldValue.arrayRemove([uniqueCode]),
        });

        notifyListeners(); // ✅ Ensure UI updates
      }
    } catch (e) {
      print("⚠️ Error leaving saving goal: $e");
    }
  }

  // Delete a saving goal
  Future<void> deleteSavingGoal(String userId, String uniqueCode) async {
    try {
      final query =
          await _firestore
              .collectionGroup('savings')
              .where('uniqueCode', isEqualTo: uniqueCode)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        final goalDoc = query.docs.first;
        final goalId = goalDoc.id;
        final ownerId = goalDoc['ownerId'];

        if (ownerId != userId) {
          print("❌ You are not the owner of this saving goal!");
          return;
        }

        final contributors =
            goalDoc['contributors'] as Map<String, dynamic>? ?? {};

        for (String contributorId in contributors.keys) {
          await _firestore.collection('users').doc(contributorId).update({
            'joinedSavings': FieldValue.arrayRemove([uniqueCode]),
          });
        }

        await _firestore
            .collection('users')
            .doc(ownerId)
            .collection('savings')
            .doc(goalId)
            .delete();

        notifyListeners(); // ✅ Ensure UI updates
      }
    } catch (e) {
      print("⚠️ Error deleting saving goal: $e");
    }
  }

  // Add contribution to a saving goal
  Future<void> addContribution(
    String userId,
    String uniqueCode,
    double amount,
  ) async {
    final query =
        await _firestore
            .collectionGroup('savings')
            .where('uniqueCode', isEqualTo: uniqueCode)
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      final goalDoc = query.docs.first;
      final goalId = goalDoc.id;
      final ownerId = goalDoc['ownerId'];
      final goalCurrency = goalDoc['currency'] ?? "MKD";

      // Fetch user currency
      String userCurrency = await getUserCurrency(userId) ?? "MKD";

      // ✅ Convert user contribution amount to the goal's currency
      double convertedAmount = await convertSavingsAmount(
        amount,
        userCurrency,
        goalCurrency,
      );

      // ✅ Ensure Firestore values are cast to `double`
      double previousRemaining = (goalDoc['remaining'] as num).toDouble();
      double previousContribution = (goalDoc['contribution'] as num).toDouble();

      double newRemaining = (previousRemaining - convertedAmount).clamp(
        0,
        double.infinity,
      );
      double newContribution = previousContribution + convertedAmount;

      bool isCompleted = newRemaining == 0;

      await _firestore
          .collection('users')
          .doc(ownerId)
          .collection('savings')
          .doc(goalId)
          .update({
            'remaining': newRemaining,
            'contribution': newContribution,
            'completed': isCompleted,
          });

      print("✅ Contribution added successfully!");
      notifyListeners(); // ✅ Ensure UI updates
    } else {
      print("❌ ERROR: Saving goal not found in Firestore!");
    }
  }
}
