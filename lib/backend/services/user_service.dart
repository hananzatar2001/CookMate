import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Future<void> saveUserCalories(UserModel user) async {
    // Safely parse string values to int (or provide defaults)
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

}

