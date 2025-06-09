// backend/controllers/home_screen_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/recipe_home_api_service.dart';

class HomeScreenController {
  String userId = '';
  double caloriesTaken = 0;
  double userCaloriesGoal = 2200;
  double userProteinGoal = 90;
  double userFatsGoal = 70;
  double userCarbsGoal = 110;
  double totalProteinTaken = 0;
  double totalFatsTaken = 0;
  double totalCarbsTaken = 0;

  List<Map<String, dynamic>> recipes = [];
  int selectedRecipeIndex = 0;
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  final List<String> recipeTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }
  Future<void> initialize() async {
    await refreshAll();
  }

  Future<void> refreshAll() async {
    await _loadUserId();
    await loadUserCaloriesGoal();
    await loadCaloriesFromLogs();
    await fetchRecipesForSelectedType();
  }

  Future<void> updateRecipeType(int index) async {
    selectedRecipeIndex = index;
    await fetchRecipesForSelectedType();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
  }

  Future<void> loadUserCaloriesGoal() async {
    final doc = await FirebaseFirestore.instance
        .collection('UserCaloriesNeeded')
        .doc(userId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      userCaloriesGoal = (data['calories'] ?? 2200).toDouble();
      userProteinGoal = (data['protein'] ?? 90).toDouble();
      userFatsGoal = (data['fats'] ?? 70).toDouble();
      userCarbsGoal = (data['carbs'] ?? 110).toDouble();
    }
  }

  Future<void> loadCaloriesFromLogs() async {
    final today = DateTime.now();
    final docId = '${userId}_${DateFormat('yyyy-MM-dd').format(today)}';

    final doc = await FirebaseFirestore.instance
        .collection('CalorieLogs')
        .doc(docId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      caloriesTaken = (data['Calories taken'] ?? 0).toDouble();
      totalProteinTaken = (data['protein taken'] ?? 0).toDouble();
      totalFatsTaken = (data['Fatss taken'] ?? 0).toDouble();
      totalCarbsTaken = (data['Carbs taken'] ?? 0).toDouble();
    }
  }

  Future<void> fetchRecipesForSelectedType() async {

    _isLoading = true;
    final selectedType = recipeTypes[selectedRecipeIndex].toLowerCase();

    try {
      recipes = await SpoonacularService.fetchRecipes(selectedType);
    } catch (e) {
      print('Error fetching recipes: \$e');
    }

    _isLoading = false;
  }
}
