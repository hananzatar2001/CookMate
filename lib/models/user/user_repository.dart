import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../config/database_config.dart';
import 'user.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  Future<User?> loadUser() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection(DatabaseConfig.USERS_COLLECTION)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error loading user: $e');
      rethrow;
    }
  }

  Future<void> saveUser(User user) async {
    try {
      await _firestore
          .collection(DatabaseConfig.USERS_COLLECTION)
          .doc(user.id)
          .set(user.toJson());
    } catch (e) {
      debugPrint('Error setting user: $e');
      rethrow;
    }
  }

  Future<bool> validateUserCredentials(String email, String password) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection(DatabaseConfig.USERS_COLLECTION)
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) {
        return false;
      }

      final userData = snapshot.docs.first.data() as Map<String, dynamic>;
      final user = User.fromJson(userData);

      return user.password == password;
    } catch (e) {
      debugPrint('Error validating credentials: $e');
      return false;
    }
  }

  String hashPassword(String password) {
    return password;
  }
}
