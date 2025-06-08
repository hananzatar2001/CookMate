import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CalorieLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // استرجاع جميع سجلات المستخدم من CalorieLogs
  Future<List<Map<String, dynamic>>> getLogsByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('CalorieLogs')
          .where('user_id', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching calorie logs: $e');
      return [];
    }
  }

  Future<void> uploadRecipeAndUpdateCalories({
    required String userId,
    required String recipeName,
    required int recipeCalories,
    double protein = 0,
    double fats = 0,
    double carbs = 0,
    String type = "Other",
  })
  async {
    final now = DateTime.now();
    print('📝 Uploading recipe: $recipeName with $recipeCalories kcal at $now');

    try {
      await _firestore.collection('Recipes').add({
        'user_id': userId,
        'recipe_name': recipeName,
        'calories': recipeCalories,
        'Protein': protein,
        'Fats': fats,
        'Carbs': carbs,
        'date': now,
        'type': type,
      });
      print('Recipe uploaded successfully.');

      await saveDailyNutritionSummary(userId, now);
    } catch (e) {
      print('Error uploading recipe: $e');
    }
  }


  Future<List<Map<String, dynamic>>> getLogsFromMealPlans(
      String userId, DateTime date, String type)
  async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(Duration(days: 1));

    final snapshot = await _firestore
        .collection('MealPlans')
        .where('user_id', isEqualTo: userId)
        .where('mealType', isEqualTo: type)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final dt = DateTime.tryParse(data['dateTime'] ?? '');
      return {
        'source': 'MealPlans',
        'id': doc.id,  // استخدم معرف المستند هنا بدلًا من data['id']
        'title': data['title'],
        'calories': (data['calories'] ?? 0).toDouble(),
        'Protein': (data['protein'] ?? 0).toDouble(),
        'Fats': (data['fat'] ?? 0).toDouble(),
        'Carbs': (data['carbs'] ?? 0).toDouble(),
        'image_url': (data['image_url'] ?? '').trim(),
        'date': dt,
      };
    }).where((e) {
      final dt = e['date'] as DateTime?;
      return dt != null && dt.isAfter(start) && dt.isBefore(end);
    }).toList();


  }

  // حساب وتحديث ملخص التغذية اليومي في CalorieLogs
  Future<void> saveDailyNutritionSummary(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    try {
      // Fetch Recipes
      final recipeSnapshot = await _firestore
          .collection('Recipes')
          .where('user_id', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      // Fetch MealPlans
      final mealPlanSnapshot = await _firestore
          .collection('MealPlans')
          .where('user_id', isEqualTo: userId)
          .get();

      // Prepare accumulators
      double totalCalories = 0;
      double totalProtein = 0;
      double totalFats = 0;
      double totalCarbs = 0;
      int recipeCount = recipeSnapshot.docs.length;

      // Process Recipes
      for (var doc in recipeSnapshot.docs) {
        final data = doc.data();
        totalCalories += (data['calories'] ?? 0).toDouble();
        totalProtein += (data['Protein'] ?? 0).toDouble();
        totalFats += (data['Fats'] ?? 0).toDouble();
        totalCarbs += (data['Carbs'] ?? 0).toDouble();
      }

      // Process MealPlans (only entries within the same day)
      for (var doc in mealPlanSnapshot.docs) {
        final data = doc.data();
        final dateTimeString = data['dateTime'] ?? '';
        final dt = DateTime.tryParse(dateTimeString);
        if (dt != null && dt.isAfter(startOfDay) && dt.isBefore(endOfDay)) {
          totalCalories += (data['calories'] ?? 0).toDouble();
          totalProtein += (data['protein'] ?? 0).toDouble();
          totalFats += (data['fat'] ?? 0).toDouble();
          totalCarbs += (data['carbs'] ?? 0).toDouble();
        }
      }

      // Save the log
      final logDocId = '${userId}_${DateFormat('yyyy-MM-dd').format(startOfDay)}';
      await _firestore.collection('CalorieLogs').doc(logDocId).set({
        'user_id': userId,
        'log_date': Timestamp.fromDate(startOfDay),
        'Calories taken': totalCalories,
        'protein taken': totalProtein,
        'fats taken': totalFats,
        'carbs taken': totalCarbs,
        'recipe_count': recipeCount,
      });

      print('✅ Daily nutrition summary saved (including MealPlans) for $userId on $startOfDay');
    } catch (e) {
      print('❌ Error in saveDailyNutritionSummary: $e');
    }
  }

  // استرجاع وصفات يوم معين
  Future<List<Map<String, dynamic>>> getRecipesForDate(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    try {
      final snapshot = await _firestore
          .collection('Recipes')
          .where('user_id', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'recipe_id': doc.id,
          'title': data['recipe_name'] ?? '',
          'calories': (data['calories'] ?? 0).toDouble(),
          'Protein': (data['Protein'] ?? 0).toDouble(),
          'Fats': (data['Fats'] ?? 0).toDouble(),
          'Carbs': (data['Carbs'] ?? 0).toDouble(),
          'image_url': (data['image_url'] ?? '').trim(),
          'type': data['type'] ?? '',
          'date': (data['date'] as Timestamp?)?.toDate(),
          'source': 'Recipes',
        };
      }).toList();
    } catch (e) {
      print('Error fetching recipes for date: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecipesForDateAndType(String userId, DateTime date, String type) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    try {
      print('Fetching recipes for $type between $startOfDay and $endOfDay for user $userId');
      final snapshot = await _firestore
          .collection('Recipes')
          .where('user_id', isEqualTo: userId)
          .where('type', isEqualTo: type)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      print('Found ${snapshot.docs.length} $type recipes.');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'recipe_id': doc.id,
          'title': data['recipe_name'] ?? '',
          'calories': (data['calories'] ?? 0).toDouble(),
          'Protein': (data['Protein'] ?? 0).toDouble(),
          'Fats': (data['Fats'] ?? 0).toDouble(),
          'Carbs': (data['Carbs'] ?? 0).toDouble(),
          'image_url': (data['image_url'] ?? '').trim(),
          'type': data['type'] ?? '',
          'date': (data['date'] as Timestamp?)?.toDate(),
          'source': 'Recipes',
        };
      }).toList();
    } catch (e) {
      print('Error fetching recipes for type "$type": $e');
      return [];
    }
  }


}
