import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String surname;
  final String profileImageUrl;
  final String currency;
  final Timestamp createdAt;
  final int friendsCount;
  final int rank;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.surname,
    required this.profileImageUrl,
    required this.currency,
    required this.createdAt,
    required this.friendsCount,
    required this.rank,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      surname: data['surname'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      currency: data['currency'] ?? 'MKD',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      friendsCount: data['friendsCount'] ?? 0,
      rank: data['rank'] ?? 0,
    );
  }

  factory UserModel.fromFriendDoc(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      surname: data['surname'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      currency: data['currency'] ?? 'MKD',
      createdAt: data['addedAt'] ?? Timestamp.now(),
      friendsCount: 0,
      rank: 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'surname': surname,
      'profileImageUrl': profileImageUrl,
      'currency': currency,
      'createdAt': createdAt,
      'friendsCount': friendsCount,
      'rank': rank,
    };
  }
}
