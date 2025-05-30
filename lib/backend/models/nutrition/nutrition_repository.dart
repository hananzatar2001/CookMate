import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../config/database_config.dart';
import 'nutrition.dart';
import '../user/user.dart';

class NutritionRepository {
  final FirebaseFirestore _firestore;

  NutritionRepository(this._firestore);

  Future<Nutrition?> loadNutrition(String userId) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection(DatabaseConfig.NUTRITION_COLLECTION)
              .where('userId', isEqualTo: userId)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        return Nutrition.fromJson(data);
      } else {
        return Nutrition(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          records: [],
        );
      }
    } catch (e) {
      debugPrint('Error loading nutrition data: $e');
      rethrow;
    }
  }

  Future<void> saveNutrition(Nutrition nutrition) async {
    try {
      await _firestore
          .collection(DatabaseConfig.NUTRITION_COLLECTION)
          .doc(nutrition.id)
          .set(nutrition.toJson());
    } catch (e) {
      debugPrint('Error saving nutrition: $e');
      rethrow;
    }
  }

  Nutrition convertLegacyNutrition(
    Map<String, dynamic> legacyNutrition,
    User? currentUser,
  ) {
    final id = legacyNutrition['id'] as String;
    final userId = legacyNutrition['userId'] as String;
    final date =
        legacyNutrition['date'] is Timestamp
            ? (legacyNutrition['date'] as Timestamp).toDate()
            : DateTime.parse(legacyNutrition['date']);

    final consumedCalories = legacyNutrition['consumedCalories'] as int? ?? 0;
    final consumedProtein = legacyNutrition['consumedProtein'] as int? ?? 0;
    final consumedCarbs = legacyNutrition['consumedCarbs'] as int? ?? 0;
    final consumedFat = legacyNutrition['consumedFat'] as int? ?? 0;
    final consumedFiber = legacyNutrition['consumedFiber'] as int? ?? 0;

    final targetCalories = currentUser?.dailyCalorieTarget ?? 2000;
    final targetProtein = currentUser?.dailyProteinTarget ?? 100;
    final targetCarbs = currentUser?.dailyCarbsTarget ?? 250;
    final targetFat = currentUser?.dailyFatTarget ?? 65;
    final targetFiber = currentUser?.dailyFiberTarget ?? 25;

    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final records = [
      NutritionRecord(
        date: dateStr,
        consumedCalories: consumedCalories,
        consumedProtein: consumedProtein,
        consumedCarbs: consumedCarbs,
        consumedFat: consumedFat,
        consumedFiber: consumedFiber,
        targetCalories: targetCalories,
        targetProtein: targetProtein,
        targetCarbs: targetCarbs,
        targetFat: targetFat,
        targetFiber: targetFiber,
      ),
    ];

    return Nutrition(id: id, userId: userId, records: records);
  }
}
