import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addFavorite({
    required String user_id,
    required String recipeId,
  }) async {
    final CollectionReference favoritesCollection = _firestore.collection('Favorites');

    final userRef = _firestore.collection('users').doc(user_id);
    final recipeRef = _firestore.collection('Recipes').doc(recipeId);
    final docRef = favoritesCollection.doc();

    final favoriteData = {
      'favorite_id': docRef.id,
      'user_id': user_id,
      'recipe_id': recipeRef,
      'favorited_at': FieldValue.serverTimestamp(),
    };

    await docRef.set(favoriteData);
  }
  Future<void> removeFavorite(String user_id, String recipeId) async {
    final querySnapshot = await _firestore
        .collection('Favorites')
        .where('user_id', isEqualTo: user_id)
        .get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();

      // تحقق أن recipe_id هو DocumentReference وقارن الـ id مع recipeId
      if (data['recipe_id'] is DocumentReference) {
        final docRef = data['recipe_id'] as DocumentReference;
        if (docRef.id == recipeId) {
          await doc.reference.delete();
        }
      }

      // لو محفوظ كـ String (احتياط)
      else if (data['recipe_id'] is String && data['recipe_id'] == recipeId) {
        await doc.reference.delete();
      }
    }
  }

}
