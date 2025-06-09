import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RecipeDetailsController extends ChangeNotifier {
  final Map<String, dynamic> recipe;
  final String apiKey = '5cbc633fbbd840a29f5a29225a1ad55f'; // Spoonacular
  final String ytApiKey = 'AIzaSyAn4XdXyZ-hLagS-je_kMEXw2M1afcajJ4'; // YouTube

  bool isSaved = false;
  bool isLoading = false;
  String? savedRecipeDocId;
  String? user_id;

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

    if (recipe.containsKey('source') && recipe['source'] == 'firestore') {
      await fetchRecipeDetailsFromFirestore();
    } else {
      await fetchRecipeDetailsFromApi();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    user_id = prefs.getString('userId');
  }

  Future<void> checkIfRecipeSaved() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('SaveRecipes')
        .where('id', isEqualTo: recipe['id'])
        .where('userId', isEqualTo: user_id)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      isSaved = true;
      savedRecipeDocId = snapshot.docs.first.id;
    }
  }

  Future<void> fetchRecipeDetailsFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Recipes')
          .where('recipe_id', isEqualTo: recipe['id'])
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();

        protein = (data['Protein'] ?? 0).toDouble();
        fat = (data['Fats'] ?? 0).toDouble();
        carbs = (data['Carbs'] ?? 0).toDouble();
        fiber = (data['Fiber'] ?? 0).toDouble(); // إذا الحقل موجود
        recipe['calories'] = (data['calories'] ?? 0).toDouble();

        ingredients = List<String>.from(data['Ingredients'] ?? []);

        recipe['type'] = data['type'] ?? 'unknown';
        recipe['image_url'] = data['image_url'] ?? '';
        recipe['title'] = data['title'] ?? '';
        videoUrl = data['sourceUrl'] ?? null;
      }
    } catch (e) {
      print('Error fetching recipe from Firestore: $e');
    }
  }

  Future<void> fetchRecipeDetailsFromApi() async {
    final recipeId = recipe['id'];
    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/$recipeId/information?apiKey=$apiKey&includeNutrition=true');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      recipe['type'] = (data['dishTypes'] as List?)?.isNotEmpty == true
          ? data['dishTypes'][0]
          : 'unknown';

      final ingredientsData = data['extendedIngredients'] ?? [];
      ingredients = ingredientsData
          .map<String>((item) => item['original'].toString())
          .toList();

      final nutrients = data['nutrition']['nutrients'] ?? [];
      for (var item in nutrients) {
        switch (item['name']) {
          case 'Protein':
            protein = (item['amount']?.toDouble() ?? 0);
            break;
          case 'Fat':
            fat = (item['amount']?.toDouble() ?? 0);
            break;
          case 'Carbohydrates':
            carbs = (item['amount']?.toDouble() ?? 0);
            break;
          case 'Fiber':
            fiber = (item['amount']?.toDouble() ?? 0);
            break;
          case 'Calories':
            recipe['calories'] = (item['amount']?.toDouble() ?? 0);
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
    try {
      final response = await http.get(url);
      final data = json.decode(response.body);
      final items = data['items'];

      if (items != null && items.isNotEmpty) {
        youtubeVideoId = items[0]['id']['videoId'];
        notifyListeners();
      }
    } catch (e) {
      print('YouTube fetch error: $e');
    }
  }

  String getRecipeImage() {
    if (recipe.containsKey('image_url') &&
        recipe['image_url'] != null &&
        recipe['image_url'] != '') {
      return recipe['image_url'];
    }
    if (recipe.containsKey('image') &&
        recipe['image'] != null &&
        recipe['image'] != '') {
      return recipe['image'];
    }
    return '';
  }

  Map<String, dynamic> getRecipeDataForSaving() {
    return {
      'id': recipe['id'],
      'title': recipe['title'],
      'image_url': getRecipeImage(),
      'type': recipe['type'] ?? 'unknown',
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'fiber': fiber,
      'calories': recipe['calories'] ?? 0,
    };
  }

  Future<String?> saveOrDeleteRecipe() async {
    if (user_id == null) return "You must be logged in";

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
      final doc =
      await FirebaseFirestore.instance.collection('SaveRecipes').add({
        'userId': user_id,
        ...getRecipeDataForSaving(),
        'ingredients': ingredients,
        'savedAt': DateTime.now(),
      });
      savedRecipeDocId = doc.id;
      isSaved = true;
      notifyListeners();
      return "saved";
    }
  }

  Future<String?> addToMealPlan() async {
    if (user_id == null) return "You must be logged in";

    try {
      final mealDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      await FirebaseFirestore.instance.collection('MealPlans').add({
        'user_id': user_id,
        ...getRecipeDataForSaving(),
        'mealType': selectedMeal,
        'dateTime': mealDateTime,
        'addedAt': DateTime.now(),
      });

      return "added";
    } catch (e) {
      print('Error adding to meal plan: $e');
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
