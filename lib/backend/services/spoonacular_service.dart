import 'dart:convert';
import 'package:http/http.dart' as http;

class SpoonacularService {
  final String apiKey = '5cbc633fbbd840a29f5a29225a1ad55f';

  Future<List<Map<String, dynamic>>> searchRecipes(String query) async {
    final url = Uri.parse(
      'https://api.spoonacular.com/recipes/complexSearch?query=$query&number=10&apiKey=$apiKey&addRecipeInformation=true',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map<Map<String, dynamic>>((recipe) {
        return {
          'title': recipe['title'],
          'image_url': recipe['image'],
          'id': recipe['id'],
        };
      }).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }
}
