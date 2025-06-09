import 'dart:convert';
import 'package:http/http.dart' as http;

class IngredientService {
  static const String _apiKey = '9de4855ed18d45a1b734290013c839bd';
  static const String _baseUrl = 'https://api.spoonacular.com';

  static Future<List<Map<String, dynamic>>> fetchIngredients(String query) async {
    final url = Uri.parse('$_baseUrl/food/ingredients/search?query=$query&number=5&apiKey=$_apiKey');
    final response = await http.get(url);

    print("Ingredient Search Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final List results = jsonDecode(response.body)['results'];

      List<Map<String, dynamic>> detailedIngredients = [];

      for (var result in results) {
        final id = result['id'];
        final name = result['name'];

        final nutritionUrl = Uri.parse(
            '$_baseUrl/food/ingredients/$id/information?amount=100&unit=grams&apiKey=$_apiKey'
        );
        final nutritionRes = await http.get(nutritionUrl);

        print("Nutrition status for $name: ${nutritionRes.statusCode}");

        if (nutritionRes.statusCode == 200) {
          final info = jsonDecode(nutritionRes.body);
          final nutrients = info['nutrition']['nutrients'];

          final protein = nutrients.firstWhere((n) => n['name'] == 'Protein', orElse: () => {'amount': 0.0})['amount'];
          final fat = nutrients.firstWhere((n) => n['name'] == 'Fat', orElse: () => {'amount': 0.0})['amount'];
          final carbs = nutrients.firstWhere((n) => n['name'] == 'Carbohydrates', orElse: () => {'amount': 0.0})['amount'];
          final fiber = nutrients.firstWhere((n) => n['name'] == 'Fiber', orElse: () => {'amount': 0.0})['amount'];

          detailedIngredients.add({
            'name': name,
            'protein': protein,
            'fat': fat,
            'carbs': carbs,
            'fiber': fiber,
          });
        } else {
          print("Failed to fetch nutrition for $name: ${nutritionRes.body}");
        }
      }

      return detailedIngredients;
    } else {
      print("Ingredient fetch failed: ${response.body}");
      return [];
    }
  }
}
