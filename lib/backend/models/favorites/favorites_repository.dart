import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../config/database_config.dart';
import 'favorites.dart';

class FavoritesRepository {
  final FirebaseFirestore _firestore;

  FavoritesRepository(this._firestore);

  Future<Favorites?> loadFavorites(String userId) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection(DatabaseConfig.FAVORITES_COLLECTION)
              .where('userId', isEqualTo: userId)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        return Favorites.fromJson(data);
      } else {
        return Favorites(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          recipeIds: [],
        );
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      rethrow;
    }
  }

  Future<void> saveFavorites(Favorites favorites) async {
    try {
      await _firestore
          .collection(DatabaseConfig.FAVORITES_COLLECTION)
          .doc(favorites.id)
          .set(favorites.toJson());
    } catch (e) {
      debugPrint('Error saving favorites: $e');
      rethrow;
    }
  }

  Future<void> toggleFavorite(Favorites favorites, String recipeId) async {
    try {
      final updatedFavorites =
          favorites.recipeIds.contains(recipeId)
              ? favorites.removeRecipe(recipeId)
              : favorites.addRecipe(recipeId);

      await saveFavorites(updatedFavorites);
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      rethrow;
    }
  }
}
