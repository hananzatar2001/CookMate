// services/recipe_home_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class SpoonacularService {
  static const String _apiKey = 'bcd268acac3a458792fde6e585f99504';
  static const String _baseUrl = 'https://api.spoonacular.com/recipes/complexSearch';

  static Future<List<Map<String, dynamic>>> fetchRecipes(String type, {int number = 6}) async {
    final uri = Uri.parse("$_baseUrl?apiKey=$_apiKey&type=$type&number=$number&addRecipeNutrition=true");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];

      return results.map((recipe) {
        return {
          'id': recipe['id'].toString(),
          'title': recipe['title'],
          'image': recipe['image'] ?? '',
          'calories': recipe['nutrition']?['nutrients']?[0]?['amount']?.toString() ?? '0',
        };
      }).toList();
    } else {
      throw Exception('Failed to load recipes: ${response.statusCode}');
    }
  }
}
