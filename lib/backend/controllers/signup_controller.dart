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
    required String passwordHash,
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
        password: passwordHash,
      );


      final encryptedPassword = hashPassword(passwordHash);


      await firestore.collection('User').doc(userId).set({
        'user_id': userId,
        'name': name,
        'email': email,
        'password_hash': encryptedPassword,
        'profile_picture': '',
        'Age': 0,
        'Weight': 0.0,
        'Height': 0.0,
        'Gender': '',
        'Specific allergies': '',
        'Diseases': '',
        'Are you a vegetarian?': false,
      });

      print(' User added to Firebase Auth & Firestore');
      return null;
    } catch (e) {
      print('Registration Error: $e');
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
      print(' Error fetching user ID: $e');
      return null;
    }
  }
}
