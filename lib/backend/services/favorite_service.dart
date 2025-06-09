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
    final recipeRef = _firestore.collection('Recipes').doc(recipeId);

    final querySnapshot = await _firestore
        .collection('Favorites')
        .where('user_id', isEqualTo: user_id)      // البحث باستخدام سترينج
        .where('recipe_id', isEqualTo: recipeRef)  // البحث باستخدام المرجع
        .get();

    for (var doc in querySnapshot.docs) {
      await _firestore.collection('Favorites').doc(doc.id).delete();
    }
  }}
