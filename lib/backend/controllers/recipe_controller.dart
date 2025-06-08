/*
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
*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeDetailsController extends ChangeNotifier {
  final Map<String, dynamic> recipe;
  final String apiKey = 'eaf8e536e30445a4b4862cdcaa7dbb0f';
  final String ytApiKey = 'AIzaSyAn4XdXyZ-hLagS-je_kMEXw2M1afcajJ4';

  bool isSaved = false;
  bool isLoading = false;
  String? savedRecipeDocId;
  String? userId;

  double protein = 0, fat = 0, carbs = 0, fiber = 0;
  List<String> ingredients = [];
  String? videoUrl;
  String? youtubeVideoId;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedMeal = "Breakfast";

  RecipeDetailsController({required this.recipe}) {
    _init();
  }

  Future<void> _init() async {
    isLoading = true;
    notifyListeners();

    await loadUserId();
    await checkIfRecipeSaved();
    await fetchRecipeDetails();

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
  }

  Future<void> checkIfRecipeSaved() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('SaveRecipes')
        .where('recipe.id', isEqualTo: recipe['id'])
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      isSaved = true;
      savedRecipeDocId = snapshot.docs.first.id;
    }
  }

  Future<void> fetchRecipeDetails() async {
    final recipeId = recipe['id'];
    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/$recipeId/information?apiKey=$apiKey&includeNutrition=true');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final ingredientsData = data['extendedIngredients'] ?? [];
      ingredients = ingredientsData
          .map<String>((item) => item['original'].toString())
          .toList();

      final nutrients = data['nutrition']['nutrients'] ?? [];
      for (var item in nutrients) {
        switch (item['name']) {
          case 'Protein':
            protein = item['amount']?.toDouble() ?? 0;
            break;
          case 'Fat':
            fat = item['amount']?.toDouble() ?? 0;
            break;
          case 'Carbohydrates':
            carbs = item['amount']?.toDouble() ?? 0;
            break;
          case 'Fiber':
            fiber = item['amount']?.toDouble() ?? 0;
            break;
          case 'Calories':
            recipe['calories'] = item['amount']?.toDouble() ?? 0;
            break;
        }
      }

      videoUrl = data['sourceUrl'];
      await fetchYouTubeVideo(recipe['title'] ?? '');
    }
  }

  Future<void> fetchYouTubeVideo(String query) async {
    final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&q=${Uri.encodeComponent(query)}&type=video&maxResults=1&key=$ytApiKey');
    final response = await http.get(url);
    final data = json.decode(response.body);
    final items = data['items'];

    if (items != null && items.isNotEmpty) {
      youtubeVideoId = items[0]['id']['videoId'];
    }
  }

  Future<String?> saveOrDeleteRecipe() async {
    if (userId == null) return "You must be logged in";

    if (isSaved && savedRecipeDocId != null) {
      await FirebaseFirestore.instance
          .collection('SaveRecipes')
          .doc(savedRecipeDocId!)
          .delete();
      isSaved = false;
      savedRecipeDocId = null;
      notifyListeners();
      return "deleted";
    } else {
      final doc = await FirebaseFirestore.instance.collection('SaveRecipes').add({
        'userId': userId,
        'recipe': recipe,
        'ingredients': ingredients,
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
        'fiber': fiber,
        'savedAt': DateTime.now().toIso8601String(),
      });
      savedRecipeDocId = doc.id;
      isSaved = true;
      notifyListeners();
      return "saved";
    }
  }

  Future<String?> addToMealPlan() async {
    if (userId == null) return "You must be logged in";

    try {
      final mealDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      await FirebaseFirestore.instance.collection('MealPlans').add({
        'userId': userId,
        'recipe': recipe,
        'mealType': selectedMeal,
        'dateTime': mealDateTime.toIso8601String(),
        'addedAt': DateTime.now().toIso8601String(),
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
        'fiber': fiber,
        'calories': recipe['calories'] ?? 0,

      });

      return "added";
    } catch (e) {
      return "error";
    }
  }

  void setMeal(DateTime date, TimeOfDay time, String meal) {
    selectedDate = date;
    selectedTime = time;
    selectedMeal = meal;
    notifyListeners();
  }
}
