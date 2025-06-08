/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CalorieLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // استرجاع جميع السجلات من CalorieLogs لمستخدم معين
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

  // حفظ ملخص التغذية اليومي من MealPlans فقط
  Future<void> saveDailyNutritionSummary(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    try {
      final mealPlanSnapshot = await _firestore
          .collection('MealPlans')
          .where('user_id', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> items = [];

      for (var doc in mealPlanSnapshot.docs) {
        final data = doc.data();
        final Timestamp? ts = data['addedAt'];
        final dt = ts?.toDate();


        if (dt != null && !dt.isBefore(startOfDay) && !dt.isAfter(endOfDay)) {
          String recipeId = '';
          if (data['recipe_id'] is DocumentReference) {
            recipeId = (data['recipe_id'] as DocumentReference).id;
          } else if (data['recipe_id'] is String) {
            recipeId = data['recipe_id'];
          }

          if (recipeId.isNotEmpty) {
            items.add({
              'id': recipeId,
              'calories': (data['calories'] ?? 0).toDouble(),
              'protein': (data['protein'] ?? 0).toDouble(),
              'Fatsss': (data['Fatss'] ?? 0).toDouble(),
              'Carbs': (data['Carbs'] ?? 0).toDouble(),
            });
          }
        }
      }

      // حذف التكرارات بناء على ID
      final uniqueItems = <String, Map<String, dynamic>>{};
      for (var item in items) {
        uniqueItems[item['id']] = item;
      }

      double totalCalories = 0;
      double totalProtein = 0;
      double totalFatss = 0;
      double totalCarbs = 0;

      for (var item in uniqueItems.values) {
        totalCalories += item['calories'];
        totalProtein += item['Protein'];
        totalFatss += item['Fatss'];
        totalCarbs += item['Carbs'];
      }

      final logDocId = '${userId}_${DateFormat('yyyy-MM-dd').format(startOfDay)}';

      print('🧮 Summary values before saving:');
      print('Calories taken: $totalCalories');
      print('Protein taken: $totalProtein');
      print('Fatss taken: $totalFatss');
      print('Carbs taken: $totalCarbs');
      print('Recipe count: ${uniqueItems.length}');

      await _firestore.collection('CalorieLogs').doc(logDocId).set({
        'user_id': userId,
        'log_date': Timestamp.fromDate(startOfDay),
        'Calories taken': totalCalories,
        'protein taken': totalProtein,
        'Fatss taken': totalFatss,
        'Carbs taken': totalCarbs,
        'recipe_count': uniqueItems.length,
      });


      print('✅ Daily summary saved from MealPlans only.');
    } catch (e) {
      print('❌ Error in saveDailyNutritionSummary (MealPlans only): $e');
    }
  }

  // استرجاع البيانات المجمعة من MealPlans فقط
  Future<List<Map<String, dynamic>>> getCombinedRecipesAndMealPlans(
      String userId, DateTime date)
  async {
    try {
      final mealPlans = await getLogsFromMealPlans(userId, date, "");

      List<Map<String, dynamic>> combinedList = [];

      for (var mp in mealPlans) {
        combinedList.add({
          'recipe_id': mp['recipe_id'] ?? '',
          'title': mp['title'] ?? '',
          'calories': mp['calories'] ?? 0,
          'Protein': mp['Protein'] ?? 0,
          'Fatss': mp['Fatss'] ?? 0,
          'Carbs': mp['Carbs'] ?? 0,
          'image_url': mp['image_url'] ?? '',
          'type': 'MealPlan',
          'date': mp['date'],
          'source': 'MealPlans',
        });
      }

      return combinedList;
    } catch (e) {
      print('Error combining MealPlans: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLogsFromMealPlans(
      String userId, DateTime date, String type)
  async {

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    try {
      final snapshot = await _firestore
          .collection('MealPlans')
          .where('user_id', isEqualTo: userId)
          .where('mealType', isEqualTo: type) // تصفية حسب نوع الوجبة
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();

        // تحويل التاريخ من Timestamp أو String إلى DateTime
        DateTime? dt;
        final rawDate = data['dateTime'];
        if (rawDate is Timestamp) {
          dt = rawDate.toDate();
        } else if (rawDate is String) {
          dt = DateTime.tryParse(rawDate);
        }

        // تجاهل البيانات التي خارج تاريخ اليوم المحدد
        if (dt == null || dt.isBefore(startOfDay) || dt.isAfter(endOfDay)) {
          return null;
        }

        // استخراج ID الوصفة
        String? recipeId;
        if (data['recipe_id'] is DocumentReference) {
          recipeId = (data['recipe_id'] as DocumentReference).id;
        } else if (data['recipe_id'] is String) {
          recipeId = data['recipe_id'];
        }

        return {
          'source': 'MealPlans',
          'id': doc.id,
          'recipe_id': recipeId,
          'title': data['title'],
          'calories': (data['calories'] ?? 0).toDouble(),
          'Protein': (data['Protein'] ?? 0).toDouble(),
          'Fatss': (data['Fats'] ?? 0).toDouble(),
          'Carbs': (data['Carbs'] ?? 0).toDouble(),
          'image_url': (data['image_url'] ?? '').trim(),
          'date': dt,
        };
      }).where((e) => e != null).cast<Map<String, dynamic>>().toList();

    } catch (e) {
      print('❌ Error fetching MealPlans by type: $e');
      return [];
    }
  }

}
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CalorieLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // استرجاع جميع السجلات من CalorieLogs لمستخدم معين
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

  // حفظ ملخص التغذية اليومي من MealPlans فقط
  Future<void> saveDailyNutritionSummary(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    try {
      final mealPlanSnapshot = await _firestore
          .collection('MealPlans')
          .where('user_id', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> items = [];

      for (var doc in mealPlanSnapshot.docs) {
        final data = doc.data();
        final Timestamp? ts = data['addedAt'];
        final dt = ts?.toDate();

        if (dt != null && !dt.isBefore(startOfDay) && !dt.isAfter(endOfDay)) {
          String recipeId = '';
          if (data['recipe_id'] is DocumentReference) {
            recipeId = (data['recipe_id'] as DocumentReference).id;
          } else if (data['recipe_id'] is String) {
            recipeId = data['recipe_id'];
          }

          if (recipeId.isNotEmpty) {
            final calories = (data['calories'] ?? 0).toDouble();
            final protein = (data['protein'] ?? 0).toDouble();
            final fat = (data['fat'] ?? 0).toDouble();
            final carbs = (data['carbs'] ?? 0).toDouble();

            print('Recipe ID: $recipeId \t Calories: $calories \t Protein: $protein \t Fat: $fat \t Carbs: $carbs');

            items.add({
              'id': recipeId,
              'calories': calories,
              'protein': protein,
              'fat': fat,
              'carbs': carbs,
            });
          }
        }
      }


      // حذف التكرارات بناءً على ID
      final uniqueItems = <String, Map<String, dynamic>>{};
      for (var item in items) {
        uniqueItems[item['id']] = item;
      }

      double totalCalories = 0;
      double totalProtein = 0;
      double totalFat = 0;
      double totalCarbs = 0;

      for (var item in uniqueItems.values) {
        totalCalories += item['calories'];
        totalProtein += item['protein'];
        totalFat += item['fat'];
        totalCarbs += item['carbs'];
      }

      final logDocId = '${userId}_${DateFormat('yyyy-MM-dd').format(startOfDay)}';

      print('🧮 Summary values before saving:');
      print('Calories taken: $totalCalories');
      print('Protein taken: $totalProtein');
      print('Fat taken: $totalFat');
      print('Carbs taken: $totalCarbs');
      print('Recipe count: ${uniqueItems.length}');

      await _firestore.collection('CalorieLogs').doc(logDocId).set({
        'user_id': userId,
        'log_date': Timestamp.fromDate(startOfDay),
        'calories_taken': totalCalories,
        'protein_taken': totalProtein,
        'fat_taken': totalFat,
        'carbs_taken': totalCarbs,
        'recipe_count': uniqueItems.length,
      });

      print('✅ Daily summary saved from MealPlans only.');
    } catch (e) {
      print('❌ Error in saveDailyNutritionSummary (MealPlans only): $e');
    }
  }

  // استرجاع البيانات المجمعة من MealPlans فقط
  Future<List<Map<String, dynamic>>> getCombinedRecipesAndMealPlans(
      String userId, DateTime date)
  async {
    try {
      final mealPlans = await getLogsFromMealPlans(userId, date, "");

      return mealPlans.map((mp) => {
        'recipe_id': mp['recipe_id'] ?? '',
        'title': mp['title'] ?? '',
        'calories': mp['calories'] ?? 0,
        'protein': mp['protein'] ?? 0,
        'fat': mp['fat'] ?? 0,
        'carbs': mp['carbs'] ?? 0,
        'image_url': mp['image_url'] ?? '',
        'type': 'MealPlan',
        'date': mp['date'],
        'source': 'MealPlans',
      }).toList();
    } catch (e) {
      print('Error combining MealPlans: $e');
      return [];
    }
  }

  // استرجاع وجبات يوم معين حسب النوع
  Future<List<Map<String, dynamic>>> getLogsFromMealPlans(
      String userId, DateTime date, String type)
  async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    try {
      final snapshot = await _firestore
          .collection('MealPlans')
          .where('user_id', isEqualTo: userId)
          .where('mealType', isEqualTo: type)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();

        DateTime? dt;
        final rawDate = data['dateTime'];
        if (rawDate is Timestamp) {
          dt = rawDate.toDate();
        } else if (rawDate is String) {
          dt = DateTime.tryParse(rawDate);
        }

        if (dt == null || dt.isBefore(startOfDay) || dt.isAfter(endOfDay)) {
          return null;
        }

        String? recipeId;
        if (data['recipe_id'] is DocumentReference) {
          recipeId = (data['recipe_id'] as DocumentReference).id;
        } else if (data['recipe_id'] is String) {
          recipeId = data['recipe_id'];
        }

        return {
          'source': 'MealPlans',
          'id': doc.id,
          'recipe_id': recipeId,
          'title': data['title'],
          'calories': (data['calories'] ?? 0).toDouble(),
          'protein': (data['protein'] ?? 0).toDouble(),
          'fat': (data['fat'] ?? 0).toDouble(),
          'carbs': (data['carbs'] ?? 0).toDouble(),
          'image_url': (data['image_url'] ?? '').trim(),
          'date': dt,
        };
      }).where((e) => e != null).cast<Map<String, dynamic>>().toList();
    } catch (e) {
      print('❌ Error fetching MealPlans by type: $e');
      return [];
    }
  }
}
