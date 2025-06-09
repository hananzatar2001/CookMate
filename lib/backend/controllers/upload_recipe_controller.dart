import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';
import '../services/RecipeService.dart';
import '../services/CloudinaryService.dart';

class RecipeController {
  final RecipeService _recipeService = RecipeService();

  Future<void> uploadRecipe(Recipe recipe, File? imageFile) async {
    if (recipe.title.isEmpty || recipe.steps.isEmpty || recipe.Ingredients.isEmpty) {
      throw Exception("Missing required fields.");
    }

    num totalProtein = 0;
    num totalCarbs = 0;
    num totalFats = 0;

    for (var ingredient in recipe.Ingredients) {
      totalProtein += (ingredient['protein'] ?? 0);
      totalCarbs += (ingredient['carbs'] ?? 0);
      totalFats += (ingredient['fat'] ?? 0);
    }

    num totalCalories = (totalProtein * 4) + (totalCarbs * 4) + (totalFats * 9);

    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await CloudinaryService.uploadImage(imageFile);
    }

    final recipe_id = "${recipe.user_id}_${const Uuid().v4()}";

    final updatedRecipe = Recipe(
      recipe_id: recipe_id,
      user_id: recipe.user_id,
      title: recipe.title,
      steps: recipe.steps,
      Ingredients: recipe.Ingredients,
      type: recipe.type,
      image_url: imageUrl ?? recipe.image_url,
      date: recipe.date,
      calories: totalCalories,
      protein: totalProtein,
      carbs: totalCarbs,
      fats: totalFats,
    );

    await _recipeService.uploadRecipe(updatedRecipe);

    // حفظ إشعار في كوليكشن Notifications على Firestore
    await FirebaseFirestore.instance.collection('Notifications').add({
      'message': 'Your recipe "${recipe.title}" has been uploaded successfully.',
      'time': Timestamp.now(),
      'type': 'recipeUpload',
      'userId': recipe.user_id,
      'recipeId': recipe_id,
      'isRead': false,
    });
  }
}
