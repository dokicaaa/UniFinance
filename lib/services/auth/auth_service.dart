import 'dart:async'; // Import for StreamSubscription
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? _user;
  StreamSubscription<User?>? _authListener; // Track the listener

  AuthService() {
    _authListener = _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String name,
    String surname,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String userId = userCredential.user!.uid;

      // Default profile picture URL
      String defaultProfileUrl =
          "https://firebasestorage.googleapis.com/v0/b/banking4students-32a97.firebasestorage.app/o/default_avatar.png?alt=media&token=e9332c5e-dc73-4705-b821-1198ee7b4597";

      // Create user document WITHOUT default achievements.
      await _firestore.collection("users").doc(userId).set({
        'uid': userId,
        'email': email,
        'name': name,
        'surname': surname,
        'profileImageUrl': defaultProfileUrl,
        'currency': 'MKD',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("User created with default profile image.");
    } catch (e) {
      print("Firestore Error: ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  Future<String> uploadProfileImage(File imageFile) async {
    try {
      String filePath = "profile_pictures/${_user!.uid}.jpg";
      UploadTask uploadTask = _storage.ref().child(filePath).putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Update Firestore with the profile image URL
      await _firestore.collection("users").doc(_user!.uid).update({
        'profileImageUrl': downloadUrl,
      });

      notifyListeners(); // Notify UI of change
      return downloadUrl;
    } catch (e) {
      throw Exception("Failed to upload profile image: $e");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  @override
  void dispose() {
    _authListener?.cancel(); // Cancel listener when AuthService is disposed
    super.dispose();
  }
}
