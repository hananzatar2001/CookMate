class Recipe {
  final String? recipeId;
  final String userId;

import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String? recipeId;
  final String user_id;
  final String title;
  final List<String> steps;
  final List<Map<String, dynamic>> Ingredients;
  final String type;
  final String? image_url;
  final DateTime? date;
  final num calories;
  final num protein;
  final num carbs;
  final num fats;

  Recipe({
    this.recipeId,
    required this.userId,
    required this.user_id,
    required this.title,
    required this.steps,
    required this.Ingredients,
    required this.type,
    this.image_url,
    this.date,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });


  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recipe(
      recipeId: doc.id,
      user_id: data['user_id'] ?? '',
      title: data['title'] ?? '',
      steps: List<String>.from(data['steps'] ?? []),
      Ingredients: List<Map<String, dynamic>>.from(data['Ingredients'] ?? []),
      type: data['type'] ?? '',
      image_url: data['image_url'],
      date: data['date'] != null ? (data['date'] as Timestamp).toDate() : null,
      calories: data['calories'] ?? 0,
      protein: data['protein'] ?? 0,
      carbs: data['carbs'] ?? 0,
      fats: data['fats'] ?? 0,
    );
  }

}
