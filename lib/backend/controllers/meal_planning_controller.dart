/*


class MealPlanningController {
  Future<List<Recipe>> fetchRecipesByDateAndType(DateTime date, String type, String user_id) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final querySnapshot = await _firestore
        .collection('Recipes')
        .where('type', isEqualTo: type)
        .where('user_id', isEqualTo: user_id)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Recipe(
        recipe_id: data['recipeId'] ?? doc.id,
        user_id: data['user_id'] ?? '',
        title: data['title'] ?? '',
        steps: List<String>.from(data['steps'] ?? []),
        Ingredients: [],
        type: data['type'] ?? '',
        image_url: data['image_url'] ?? '',
        date: data['date'] != null ? (data['date'] as Timestamp).toDate() : null,
        calories: data['calories'] ?? 0,
        protein: data['Protein'] ?? 0,
        carbs: data['Carbs'] ?? 0,
        fats: data['Fats'] ?? 0,
      );
    }).toList();
  }


}

*/
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../backend/models/recipe_model.dart';

class MealPlanningController {
  Future<List<Recipe>> fetchAllMealsByDateAndType(DateTime date, String type, String userId) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    List<Recipe> allMeals = [];

    // Get from Recipes collection
    final recipeSnapshots = await _firestore
        .collection('Recipes')
        .where('type', isEqualTo: type)
        .where('user_id', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    allMeals.addAll(recipeSnapshots.docs.map((doc) {
      final data = doc.data();
      return Recipe(
        recipe_id: data['recipeId'] ?? doc.id,
        user_id: data['user_id'] ?? '',
        title: data['title'] ?? '',
        steps: List<String>.from(data['steps'] ?? []),
        Ingredients: [],
        type: data['type'] ?? '',
        image_url: data['image_url'] ?? '',
        date: data['date'] != null ? (data['date'] as Timestamp).toDate() : null,
        calories: data['calories'] ?? 0,
        protein: data['Protein'] ?? 0,
        carbs: data['Carbs'] ?? 0,
        fats: data['Fats'] ?? 0,
      );
    }));

    // Get from MealPlans collection
    final mealPlansSnapshot = await _firestore
        .collection('MealPlans')
        .where('mealType', isEqualTo: type)
        .where('user_id', isEqualTo: userId)
        .get();

    for (final doc in mealPlansSnapshot.docs) {
      final data = doc.data();

      final dateTimeStr = data['dateTime'] ?? '';
      DateTime? mealDate;
      try {
        mealDate = DateTime.parse(dateTimeStr);
      } catch (_) {}

      if (mealDate != null &&
          mealDate.isAfter(startOfDay) &&
          mealDate.isBefore(endOfDay)) {
        allMeals.add(
          Recipe(
            recipe_id: data['id'] ?? doc.id,
            user_id: data['user_id'] ?? '',
            title: data['title'] ?? '',
            steps: [],
            Ingredients: [],
            type: data['mealType'] ?? '',
            image_url: data['image_url']?.trim() ?? '',
            date: mealDate,
            calories: (data['calories'] ?? 0).toDouble(),
            protein: (data['protein'] ?? 0).toDouble(),
            carbs: (data['carbs'] ?? 0).toDouble(),
            fats: (data['fat'] ?? 0).toDouble(),
          ),
        );
      }
    }

    return allMeals;
  }
}
