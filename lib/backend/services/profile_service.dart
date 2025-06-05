import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileRecipeService {
  final _userCollection = FirebaseFirestore.instance.collection('User');
  final _recipesCollection = FirebaseFirestore.instance.collection('Recipes');

  /// Get User Info by Email & Password
  Future<Map<String, dynamic>?> getUserProfile(String email, String password) async {
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

  /// Get Recipes Uploaded by User (by user_id)
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserRecipes(String userId) {
    return _recipesCollection
        .where('user_id', isEqualTo: userId)
        .snapshots();
  }

  /// Get full user document stream by userId
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfileStream(String userId) {
    return _userCollection.doc(userId).snapshots();
  }

  /// Get user name only as a stream
  Stream<String> getUserName(String userId) {
    return getUserProfileStream(userId).map((doc) => doc.data()?['name'] ?? 'Name');
  }

  /// Get user bio as a stream
  Stream<String> getUserBio(String userId) {
    return getUserProfileStream(userId).map((doc) => doc.data()?['Bio'] ?? '');
  }

  /// Update user bio only
  Future<void> updateUserBio(String userId, String newBio) async {
    await _userCollection.doc(userId).update({'Bio': newBio});
  }


}
