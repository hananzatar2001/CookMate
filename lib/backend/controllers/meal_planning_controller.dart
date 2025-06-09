import 'package:cloud_firestore/cloud_firestore.dart';
import '../../backend/models/recipe_model.dart';

class MealPlanningController {
  Future<List<Recipe>> fetchAllMealsByDateAndType(DateTime date, String type, String userId) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    List<Recipe> allMeals = [];

    final mealPlansSnapshot = await _firestore
        .collection('MealPlans')
        .where('mealType', isEqualTo: type)
        .where('user_id', isEqualTo: userId)
        .get();

    for (final doc in mealPlansSnapshot.docs) {
      final data = doc.data();

      DateTime? mealDate;
      if (data['dateTime'] is Timestamp) {
        mealDate = (data['dateTime'] as Timestamp).toDate();
      } else if (data['dateTime'] is String) {
        try {
          mealDate = DateTime.parse(data['dateTime']);
        } catch (_) {}
      }

      if (mealDate != null &&
          mealDate.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
          mealDate.isBefore(endOfDay)) {
        allMeals.add(
          Recipe(
            recipe_id: data['id']?.toString() ?? doc.id, // تأكد أن id من نوع String
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

    print("📦 Found ${allMeals.length} meals for $type on $date");
    return allMeals;
  }

}
