import 'package:cloud_firestore/cloud_firestore.dart';
class CalorieLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<Map<String, dynamic>> calculateDailyIntake(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    try {
      final snapshot = await _firestore
          .collection('MealPlans')
          .where('user_id', isEqualTo: userId)
          .get();

      double totalCalories = 0;
      double totalProtein = 0;
      double totalFats = 0;
      double totalCarbs = 0;
      int recipeCount = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final Timestamp? ts = data['addedAt'];
        final dt = ts?.toDate();

        if (dt != null && !dt.isBefore(startOfDay) && !dt.isAfter(endOfDay)) {
          totalCalories += (data['calories'] ?? 0).toDouble();
          totalProtein += (data['protein'] ?? 0).toDouble();
          totalFats += (data['fat'] ?? 0).toDouble();
          totalCarbs += (data['carbs'] ?? 0).toDouble();
          recipeCount++;
        }
      }

      return {
        'calories': totalCalories,
        'protein': totalProtein,
        'fat': totalFats,
        'carbs': totalCarbs,
        'recipe_count': recipeCount,
      };
    } catch (e) {
      print('❌ Error calculating daily intake: $e');
      return {
        'calories': 0,
        'protein': 0,
        'fat': 0,
        'carbs': 0,
        'recipe_count': 0,
      };
    }
  }

  Future<void> saveDailyNutritionSummary(String userId, DateTime date) async {
    try {
      final result = await calculateDailyIntake(userId, date);

      final startOfDay = DateTime(date.year, date.month, date.day);
      final logDocId = '${userId}_${startOfDay.toIso8601String().split('T')[0]}';

      await _firestore.collection('CalorieLogs').doc(logDocId).set({
        'user_id': userId,
        'log_date': Timestamp.fromDate(startOfDay),
        'Calories taken': result['calories'],
        'protein taken': result['protein'],
        'Fats taken': result['fat'],
        'Carbs taken': result['carbs'],
        'recipe_count': result['recipe_count'],
      });

      print('✅ Daily summary saved successfully.');
    } catch (e) {
      print('❌ Error saving daily summary: $e');
    }
  }
  Future<List<Map<String, dynamic>>> getLogsFromMealPlans(String userId, DateTime date, String mealType) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    try {
      final snapshot = await _firestore
          .collection('MealPlans')
          .where('user_id', isEqualTo: userId)
          .where('mealType', isEqualTo: mealType)
          .get();

      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        DateTime? dt;
        final rawDate = data['addedAt'];
        if (rawDate is Timestamp) {
          dt = rawDate.toDate();
        } else if (rawDate is String) {
          dt = DateTime.tryParse(rawDate);
        }
        return dt != null && !dt.isBefore(startOfDay) && dt.isBefore(endOfDay);
      }).toList();

      return filteredDocs.map((doc) {
        final data = doc.data();

        String? recipeId;
        if (data['recipe_id'] is String) {
          recipeId = data['recipe_id'];
        }

        DateTime? dt;
        final rawDate = data['addedAt'];
        if (rawDate is Timestamp) {
          dt = rawDate.toDate();
        } else if (rawDate is String) {
          dt = DateTime.tryParse(rawDate);
        }

        return {
          'id': doc.id,
          'recipe_id': recipeId ?? '',
          'title': data['title'] ?? '',
          'calories': (data['calories'] ?? 0).toDouble(),
          'Protein': (data['protein'] ?? 0).toDouble(),
          'Fatss': (data['fat'] ?? 0).toDouble(),
          'Carbs': (data['carbs'] ?? 0).toDouble(),
          'image_url': (data['image_url'] ?? '').toString(),
          'date': dt,
        };
      }).toList();
    } catch (e) {
      print('❌ Error fetching meal plans: $e');
      return [];
    }
  }
  Future<void> printDailyNutritionSummary(String userId, DateTime date, String mealType) async {
    // أولاً تجيب وصفات الوجبة
    final logs = await getLogsFromMealPlans(userId, date, mealType);

    // اطبع كل وصفة ومعلوماتها
    print('--- hananRecipes for $mealType on ${date.toIso8601String().split("T")[0]} ---');
    for (var recipe in logs) {
      print('hananRecipe: ${recipe['title']}');
      print('hananCalories: ${recipe['calories']}');
      print('hananCarbs: ${recipe['Carbs']}');
      print('hananFats: ${recipe['Fatss']}');
      print('hananProtein: ${recipe['Protein']}');
      print('--------------------------------------');
    }

    // بعدين احسب واخذ الكالوريز اليومية من NutritionCalculator
    final result = await calculateDailyIntake(userId, date);

    // اطبع الCalories taken and macros taken
    print('Calories taken: ${result['calories']}');
    print('Carbs taken: ${result['carbs']}');
    print('Fats taken: ${result['fat']}');
    print('Protein taken: ${result['protein']}');
  }
  Future<void> deleteMealPlan(String id) async {
    try {
      await _firestore.collection('MealPlans').doc(id).delete();
      print('✅ MealPlan with id $id deleted successfully.');
    } catch (e) {
      print('❌ Error deleting MealPlan with id $id: $e');
      rethrow;  // ترمي الخطأ للأعلى عشان يتعامل معها الواجهة مثلاً
    }
  }

}
