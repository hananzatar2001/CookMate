import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('User').doc(uid).get();
      if (!doc.exists) {
        print(" No document for UID $uid");
        return null;
      }
      print(" User found: ${doc.data()}");
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print(" Error fetching user: $e");
      return null;
    }
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('User').doc(user.userId).update(user.toMap());
  }
/*
  Future<void> saveUserCalories(UserModel user) async {
    final int age = int.tryParse(user.Age.toString()) ?? 0;
    final int Weight = int.tryParse(user.Weight.toString()) ?? 0;
    final int height = int.tryParse(user.Height.toString()) ?? 0;

    double Calories;
    if (user.Gender.toLowerCase() == 'male') {
      Calories = 10 * Weight + 6.25 * height - 5 * age + 5;
    } else {
      Calories = 10 * Weight + 6.25 * height - 5 * age - 161;
    }

    await _firestore.collection('User').doc(user.userId).update({
      'Calories': Calories.round(),
    });
  }
*/

  Future<void> saveUserCalories(UserModel user) async {
    final int age = int.tryParse(user.Age.toString()) ?? 0;
    final int weight = int.tryParse(user.Weight.toString()) ?? 0;
    final int height = int.tryParse(user.Height.toString()) ?? 0;

    double calories;
    if (user.Gender.toLowerCase() == 'male') {
      calories = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      calories = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    double protein = weight * 1.8;
    double fats = (calories * 0.25) / 9;
    double carbs = (calories - (protein * 4 + fats * 9)) / 4;

    await _firestore.collection('UserCaloriesNeeded').doc(user.userId).set({
      'user_id': _firestore.collection('User').doc(user.userId),
      'calories': calories.round(),
      'protein': protein.round(),
      'fats': fats.round(),
      'carbs': carbs.round(),
    });
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final snapshot = await _firestore
          .collection('User')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      return UserModel.fromMap(doc.data(), doc.id);
    } catch (e) {
      print("Error getting user by email: $e");
      return null;
    }
  }

}

