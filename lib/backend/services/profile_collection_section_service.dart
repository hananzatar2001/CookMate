import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile_Recipe_view_model.dart';

class ProfileCollectionService {
  static Future<Map<String, dynamic>> fetchRecipes({
    required String userId,
    DocumentSnapshot? lastFavoriteDoc,
    DocumentSnapshot? lastSavedDoc,
    int limit = 9,
    Set<String>? loadedRecipeIds,
  }) async {
    final List<ProfileCollectionRecipesSectionModel> recipes = [];
    loadedRecipeIds ??= {};

    final favoritesQuery = FirebaseFirestore.instance
        .collection('Favorites')
        .where('user_id', isEqualTo: userId)
        .orderBy(FieldPath.documentId)
        .limit(limit);

    final savedQuery = FirebaseFirestore.instance
        .collection('SaveRecipes')
        .where('userId', isEqualTo: userId)
        .orderBy(FieldPath.documentId)
        .limit(limit);

    final favoritesSnap = lastFavoriteDoc == null
        ? await favoritesQuery.get()
        : await favoritesQuery.startAfterDocument(lastFavoriteDoc).get();

    final savedSnap = lastSavedDoc == null
        ? await savedQuery.get()
        : await savedQuery.startAfterDocument(lastSavedDoc).get();


    for (var doc in favoritesSnap.docs) {
      try {
        if (doc.data().containsKey('recipe_id')) {
          final ref = doc['recipe_id'] as DocumentReference;
          if (!loadedRecipeIds.contains(ref.id)) {
            final recipeDoc = await ref.get();
            if (recipeDoc.exists) {
              recipes.add(ProfileCollectionRecipesSectionModel.fromDoc(recipeDoc));
              loadedRecipeIds.add(ref.id);
            }
          }
        }
      } catch (e) {
        print(' Error loading recipe from Favorites: $e');
      }
    }


    for (var doc in savedSnap.docs) {
      try {
        if (doc.data().containsKey('recipe')) {
          final recipeMap = doc['recipe'];
          final id = recipeMap['id'].toString();
          if (!loadedRecipeIds.contains(id)) {
            recipes.add(ProfileCollectionRecipesSectionModel.fromMap(recipeMap));
            loadedRecipeIds.add(id);
          }
        }
      } catch (e) {
        print(' Error loading recipe from SaveRecipes: $e');
      }
    }

    return {
      'recipes': recipes,
      'lastFavoriteDoc': favoritesSnap.docs.isNotEmpty ? favoritesSnap.docs.last : lastFavoriteDoc,
      'lastSavedDoc': savedSnap.docs.isNotEmpty ? savedSnap.docs.last : lastSavedDoc,
      'hasMore': favoritesSnap.docs.length == limit || savedSnap.docs.length == limit,
    };
  }
}
