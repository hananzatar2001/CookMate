/*
class Recipe {
  final String userId;
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
    required this.userId,
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

  Recipe copyWith({
    String? imageUrl,
    num? calories,
    num? protein,
    num? carbs,
    num? fats,
  }) {
    return Recipe(
      userId: userId,
      title: title,
      steps: steps,
      Ingredients: Ingredients,
      type: type,
      image_url: imageUrl ?? this.image_url,
      date: date,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
    );
  }
}*/


class Recipe {
  final String? recipeId;
  final String userId;
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
}
