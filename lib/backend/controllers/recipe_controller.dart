import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/firestore_service.dart';

class RecipeController {
  final FirestoreService firestoreService;
  final String apiKey = '5cbc633fbbd840a29f5a29225a1ad55f'; // مفتاح Spoonacular API

  RecipeController(this.firestoreService);

  // جلب وصفات من Spoonacular API بناءً على البحث
  Future<void> fetchAndAddRecipes(String query) async {
    final url = Uri.parse(
      'https://api.spoonacular.com/recipes/complexSearch?query=$query&number=10&addRecipeInformation=true&apiKey=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> recipes = data['results'];

      for (var recipe in recipes) {
        final id = recipe['id'].toString();
        final title = recipe['title'] ?? 'No Title';
        final imageUrl = recipe['image'] ?? '';
        final ingredients = (recipe['extendedIngredients'] as List)
            .map((e) => e['original'].toString())
            .toList();

        final instructions = (recipe['analyzedInstructions'] as List).isNotEmpty
            ? (recipe['analyzedInstructions'][0]['steps'] as List)
            .map((s) => s['step'].toString())
            .toList()
            : <String>[];

        await firestoreService.addRecipe({
          'id': id,
          'title': title,
          'imageUrl': imageUrl,
          'Ingredients': ingredients,
          'steps': instructions,
          'createdAt': DateTime.now(),
        });
      }
    } else {
      throw Exception('Failed to fetch recipes from API');
    }
  }

  // جلب كل الوصفات من Firestore
  Future<List<Map<String, dynamic>>> getAllRecipes() async {
    return await firestoreService.getAllRecipes();
  }

  // جلب الوصفات بشكل تدريجي (pagination)
  Future<List<Map<String, dynamic>>> getRecipesPaginated({int limit = 10}) async {
    return await firestoreService.getRecipesPaginated(limit: limit);
  }
}
