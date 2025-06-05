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
