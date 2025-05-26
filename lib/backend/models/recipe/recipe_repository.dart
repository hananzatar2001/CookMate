import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../config/database_config.dart';
import 'recipe.dart';

class RecipeRepository {
  final FirebaseFirestore _firestore;

  RecipeRepository(this._firestore);

  Future<List<Recipe>> loadRecipes() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection(DatabaseConfig.RECIPES_COLLECTION).get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Recipe.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error loading recipes: $e');
      rethrow;
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      await _firestore
          .collection(DatabaseConfig.RECIPES_COLLECTION)
          .doc(recipe.id)
          .set(recipe.toJson());
    } catch (e) {
      debugPrint('Error adding recipe: $e');
      rethrow;
    }
  }

  Future<void> updateRecipe(Recipe updatedRecipe) async {
    try {
      await _firestore
          .collection(DatabaseConfig.RECIPES_COLLECTION)
          .doc(updatedRecipe.id)
          .update(updatedRecipe.toJson());
    } catch (e) {
      debugPrint('Error updating recipe: $e');
      rethrow;
    }
  }

  Future<void> removeRecipe(String id) async {
    try {
      await _firestore
          .collection(DatabaseConfig.RECIPES_COLLECTION)
          .doc(id)
          .delete();
    } catch (e) {
      debugPrint('Error removing recipe: $e');
      rethrow;
    }
  }

  List<Recipe> getByMealType(List<Recipe> recipes, String mealType) {
    return recipes.where((recipe) => recipe.mealType == mealType).toList();
  }

  Recipe? getRecipeById(List<Recipe> recipes, String id) {
    try {
      return recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }
}
