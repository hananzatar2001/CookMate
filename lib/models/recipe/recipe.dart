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
  final int fiber;
  final List<Ingredient>? ingredients;
  final List<String>? possibleIngredients;
  final List<String>? keywords;
  final List<String>? steps;

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
    this.fiber = 0,
    this.ingredients,
    this.possibleIngredients,
    this.keywords,
    this.steps,
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
      fiber: json['fiber'] ?? 0,
      ingredients:
          json['ingredients'] != null
              ? (json['ingredients'] as List)
                  .map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
                  .toList()
              : null,
      possibleIngredients:
          json['possilbeIngredients'] != null
              ? List<String>.from(json['possilbeIngredients'])
              : null,
      keywords:
          json['keywords'] != null ? List<String>.from(json['keywords']) : null,
      steps: json['steps'] != null ? List<String>.from(json['steps']) : null,
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
      'fiber': fiber,
      'ingredients': ingredients?.map((i) => i.toJson()).toList(),
      'possilbeIngredients': possibleIngredients,
      'keywords': keywords,
      'steps': steps,
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
    int? fiber,
    List<Ingredient>? ingredients,
    List<String>? possibleIngredients,
    List<String>? keywords,
    List<String>? steps,
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
      fiber: fiber ?? this.fiber,
      ingredients: ingredients ?? this.ingredients,
      possibleIngredients: possibleIngredients ?? this.possibleIngredients,
      keywords: keywords ?? this.keywords,
      steps: steps ?? this.steps,
    );
  }
}

class Ingredient {
  final String name;
  final double amount;
  final String unit;
  final String imageUrl;

  Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
    required this.imageUrl,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] ?? '',
      amount:
          (json['amount'] is int)
              ? (json['amount'] as int).toDouble()
              : json['amount'] ?? 0.0,
      unit: json['unit'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'amount': amount, 'unit': unit, 'imageUrl': imageUrl};
  }
}
