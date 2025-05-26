import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../config/database_config.dart';
import 'meal_plan.dart';

class MealPlanRepository {
  final FirebaseFirestore _firestore;

  MealPlanRepository(this._firestore);

  Future<MealPlan?> loadMealPlan(String userId) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection(DatabaseConfig.MEAL_PLANS_COLLECTION)
              .where('userId', isEqualTo: userId)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        return MealPlan.fromJson(data);
      } else {
        return MealPlan(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          records: [],
        );
      }
    } catch (e) {
      debugPrint('Error loading meal plans: $e');
      rethrow;
    }
  }

  Future<void> saveMealPlan(MealPlan mealPlan) async {
    try {
      await _firestore
          .collection(DatabaseConfig.MEAL_PLANS_COLLECTION)
          .doc(mealPlan.id)
          .set(mealPlan.toJson());
    } catch (e) {
      debugPrint('Error saving meal plan: $e');
      rethrow;
    }
  }

  MealPlan? getMealPlanByDate(MealPlan? userMealPlan, DateTime date) {
    if (userMealPlan == null) return null;

    final record = userMealPlan.getRecordForDate(date);
    if (record == null || record.recipeIds.isEmpty) return null;

    return MealPlan(
      id: userMealPlan.id,
      userId: userMealPlan.userId,
      records: [record],
    );
  }

  MealPlan convertLegacyMealPlan(Map<String, dynamic> legacyMealPlan) {
    final id = legacyMealPlan['id'] as String;
    final userId = legacyMealPlan['userId'] as String;
    final date =
        legacyMealPlan['date'] is Timestamp
            ? (legacyMealPlan['date'] as Timestamp).toDate()
            : DateTime.parse(legacyMealPlan['date']);
    final meals = legacyMealPlan['meals'] as Map<String, dynamic>;

    final List<String> recipeIds = [];
    meals.forEach((mealType, ids) {
      if (ids is List) {
        recipeIds.addAll(List<String>.from(ids));
      }
    });

    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final records = [MealPlanRecord(date: dateStr, recipeIds: recipeIds)];

    return MealPlan(id: id, userId: userId, records: records);
  }
}
