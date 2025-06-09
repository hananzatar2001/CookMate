import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';

class UserService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String?> addUserWithCheck({
    required String userId,
    required String name,
    required String email,
    required String originalPassword,
  }) async {
    try {
      final querySnapshot = await firestore
          .collection('User')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return 'This email is already registered';
      }

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: originalPassword,
      );

      final passwordHash = hashPassword(originalPassword);

      await firestore.collection('User').doc(userId).set({
        'user_id': userId,
        'name': name,
        'email': email,
        'password_hash': passwordHash,
        'profile_picture': '',
        'Age': 0,
        'Weight': 0.0,
        'Height': 0.0,
        'Gender': '',
        'Specific allergies': '',
        'Diseases': '',
        'Are you a vegetarian?': false,
      });

      return null;
    } catch (e) {
      return 'Failed to register user: $e';
    }
  }

  Future<String?> getUserIdByEmail(String email) async {
    try {
      final querySnapshot = await firestore
          .collection('User')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
