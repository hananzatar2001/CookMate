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

    // Fetch from Favorites
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

    // Load from Favorites
    for (var doc in favoritesSnap.docs) {
      try {
        final recipeField = doc.data()['recipe_id'];

        DocumentReference? ref;

        if (recipeField is DocumentReference) {
          ref = recipeField;
        } else if (recipeField is String && recipeField.contains('/')) {
          ref = FirebaseFirestore.instance.doc(recipeField);
        }

        if (ref != null && !loadedRecipeIds.contains(ref.id)) {
          final recipeDoc = await ref.get();
          if (recipeDoc.exists) {
            recipes.add(ProfileCollectionRecipesSectionModel.fromDoc(recipeDoc));
            loadedRecipeIds.add(ref.id);
          }
        }
      } catch (e) {
        print(' Error loading from Favorites: $e');
      }
    }



    // Load from SaveRecipes
// Load from SaveRecipes
    for (var doc in savedSnap.docs) {
      try {
        if (!loadedRecipeIds.contains(doc.id)) {
          recipes.add(ProfileCollectionRecipesSectionModel.fromDoc(doc));
          loadedRecipeIds.add(doc.id);
        }
      } catch (e, stackTrace) {
        print(' Error loading from SaveRecipes: $e');
        print(' StackTrace: $stackTrace');
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
