import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../services/recipe_home_api_service.dart';
import 'package:flutter/material.dart';

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

  final List<String> recipeTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> error = ValueNotifier(null);
  final ValueNotifier<List<NotificationModel>> notifications = ValueNotifier([]);

  /// Initialize with context to show snackBar if userId is missing
  Future<bool> initializeWithContext(BuildContext context) async {
    final success = await _loadUserIdWithContext(context);
    if (!success) return false;

    await refreshAll();
    return true;
  }

  Future<bool> _loadUserIdWithContext(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');

    if (id == null || id.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID does not exist. Please login again.')),
        );
      }
      return false;
    }

    userId = id;
    return true;
  }

  Future<void> refreshAll() async {
    await loadUserCaloriesGoal();
    await loadCaloriesFromLogs();
    await fetchRecipesForSelectedType();
  }

  Future<void> updateRecipeType(int index) async {
    selectedRecipeIndex = index;
    await fetchRecipesForSelectedType();
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
      totalFatsTaken = (data['Fats taken'] ?? 0).toDouble();
      totalCarbsTaken = (data['Carbs taken'] ?? 0).toDouble();
    }
  }

  Future<void> fetchRecipesForSelectedType() async {
    isLoading.value = true;
    final selectedType = recipeTypes[selectedRecipeIndex].toLowerCase();

    try {
      recipes = await SpoonacularService.fetchRecipes(selectedType);
    } catch (e) {
      print('Error fetching recipes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNotifications(String userId) async {
    if (userId.isEmpty) {
      error.value = 'User ID is empty';
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('time', descending: true)
          .get();

      notifications.value =
          snapshot.docs.map((doc) => NotificationModel.fromDocument(doc)).toList();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
