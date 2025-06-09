import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cloudinary_helper_eman.dart';

class ProfileRecipeService {
  final _userCollection = FirebaseFirestore.instance.collection('User');
  final _recipesCollection = FirebaseFirestore.instance.collection('Recipes');


  Future<Map<String, dynamic>?> getUserProfile(String email,
      String password) async {
    final querySnapshot = await _userCollection
        .where('email', isEqualTo: email)
        .where('password_hash', isEqualTo: password)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data();
    } else {
      return null;
    }
  }


  Stream<QuerySnapshot<Map<String, dynamic>>> getUserRecipes(String userId) {
    return _recipesCollection
        .where('user_id', isEqualTo: userId)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfileStream(
      String userId) {
    return _userCollection.doc(userId).snapshots();
  }


  Stream<String> getUserName(String userId) {
    return getUserProfileStream(userId).map((doc) =>
    doc.data()?['name'] ?? 'Name');
  }

  Stream<String> getUserBio(String userId) {
    return getUserProfileStream(userId).map((doc) => doc.data()?['Bio'] ?? '');
  }


  Future<void> updateUserBio(String userId, String newBio) async {
    await _userCollection.doc(userId).update({'Bio': newBio});
  }

  Future<void> updateUserProfilePicture(String userId, File file) async {
    final imageUrl = await CloudinaryHelperEman.upload(file);
    if (imageUrl != null) {
      await _userCollection.doc(userId).update({'profile_picture': imageUrl});
      print(" Profile picture updated!");
    }
  }



}