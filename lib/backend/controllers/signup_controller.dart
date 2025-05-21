import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;


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

      print(' User added to Firestore');
      return null;
    } catch (e) {
      print(' Firestore Error: $e');
      return 'Failed to add user: $e';
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
//s