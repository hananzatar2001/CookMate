import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String name;
  final String description;
  final int calories;
  final String weight;
  final String imageUrl;
  final String mealType;
  final int protein;
  final int carbs;
  final int fat;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.calories,
    required this.weight,
    required this.imageUrl,
    required this.mealType,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      calories: json['calories'] ?? 0,
      weight: json['weight'] ?? '0g',
      imageUrl: json['imageUrl'] ?? '',
      mealType: json['mealType'] ?? 'Other',
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fat: json['fat'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'calories': calories,
      'weight': weight,
      'imageUrl': imageUrl,
      'mealType': mealType,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    int? calories,
    String? weight,
    String? imageUrl,
    String? mealType,
    int? protein,
    int? carbs,
    int? fat,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      calories: calories ?? this.calories,
      weight: weight ?? this.weight,
      imageUrl: imageUrl ?? this.imageUrl,
      mealType: mealType ?? this.mealType,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }
}
