import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ إضافة إلى Favorites مع تخزين recipe_id كـ DocumentReference
  Future<void> addFavorite({
    required String user_id,
    required String recipeDocId, // يجب أن يكون ID حقيقي من MealPlans مثل: y8vSMBESvTIt6DdGeoIW
  }) async {
    final favoritesCollection = _firestore.collection('Favorites');

    final recipeRef = _firestore.collection('MealPlans').doc(recipeDocId); // ✅ هذا المرجع الصحيح
    final docRef = favoritesCollection.doc();

    final favoriteData = {
      'favorite_id': docRef.id,
      'user_id': user_id, // 👈 هذا يبقى String عادي
      'recipe_id': recipeRef, // ✅ لا تحوله لـ toString!
      'favorited_at': FieldValue.serverTimestamp(),
    };

    await docRef.set(favoriteData); // ✅ يتم تخزين DocumentReference فعليًا
  }

  // ✅ إزالة من Favorites باستخدام DocumentReference
  Future<void> removeFavorite(String user_id, String recipeDocId) async {
    final recipeRef = _firestore.collection('MealPlans').doc(recipeDocId);

    final querySnapshot = await _firestore
        .collection('Favorites')
        .where('user_id', isEqualTo: user_id) // ✅ String عادي
        .where('recipe_id', isEqualTo: recipeRef) // ✅ يجب أن يكون DocumentReference
        .get();

    for (var doc in querySnapshot.docs) {
      await _firestore.collection('Favorites').doc(doc.id).delete();
    }
  }
}
