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

      // استخراج ID من المرجع
      String? extractedRecipeId;
      if (data['recipe_id'] is DocumentReference) {
        extractedRecipeId = (data['recipe_id'] as DocumentReference).id;
      } else if (data['recipe_id'] is String) {
        extractedRecipeId = data['recipe_id'];
      }

      return {
        'source': 'MealPlans',
        'id': doc.id,
        'recipe_id': extractedRecipeId,
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
      // جلب الوصفات ضمن اليوم
      final recipeSnapshot = await _firestore
          .collection('Recipes')
          .where('user_id', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      // جلب وجبات الخطط (MealPlans) كاملة للمستخدم (لاحقاً نفلتر حسب التاريخ)
      final mealPlanSnapshot = await _firestore
          .collection('MealPlans')
          .where('user_id', isEqualTo: userId)
          .get();

      // نجمع كل العناصر من الوصفات ووجبات الخطط في قائمة واحدة مع استخراج recipe_id
      List<Map<String, dynamic>> combinedItems = [];

      // إضافة الوصفات
      for (var doc in recipeSnapshot.docs) {
        final data = doc.data();
        combinedItems.add({
          'id': doc.id,  // استخدم الـ doc id كمعرف
          'calories': (data['calories'] ?? 0).toDouble(),
          'protein': (data['Protein'] ?? 0).toDouble(),
          'fats': (data['Fats'] ?? 0).toDouble(),
          'carbs': (data['Carbs'] ?? 0).toDouble(),
        });
      }

      // إضافة وجبات الخطط ضمن نفس اليوم
      for (var doc in mealPlanSnapshot.docs) {
        final data = doc.data();
        final dateTimeString = data['dateTime'] ?? '';
        final dt = DateTime.tryParse(dateTimeString);
        if (dt != null && !dt.isBefore(startOfDay) && !dt.isAfter(endOfDay)) {
          String recipeId = '';
          if (data['recipe_id'] is DocumentReference) {
            recipeId = (data['recipe_id'] as DocumentReference).id;
          } else if (data['recipe_id'] is String) {
            recipeId = data['recipe_id'];
          }
          if (recipeId.isNotEmpty) {
            combinedItems.add({
              'id': recipeId,
              'calories': (data['calories'] ?? 0).toDouble(),
              'protein': (data['protein'] ?? 0).toDouble(),
              'fats': (data['fat'] ?? 0).toDouble(),
              'carbs': (data['carbs'] ?? 0).toDouble(),
            });
          }
        }
      }

      // حذف التكرار بحسب الـ id (recipe_id)
      final uniqueItemsMap = <String, Map<String, dynamic>>{};
      for (var item in combinedItems) {
        uniqueItemsMap[item['id']] = item; // لو نفس الـ id موجود، يتم استبداله (يبقي واحد فقط)
      }
      final uniqueItems = uniqueItemsMap.values.toList();

      // حساب القيم الكلية بدون تكرار
      double totalCalories = 0;
      double totalProtein = 0;
      double totalFats = 0;
      double totalCarbs = 0;

      for (var item in uniqueItems) {
        totalCalories += item['calories'];
        totalProtein += item['protein'];
        totalFats += item['fats'];
        totalCarbs += item['carbs'];
      }

      // حفظ الملخص اليومي
      final logDocId = '${userId}_${DateFormat('yyyy-MM-dd').format(startOfDay)}';
      await _firestore.collection('CalorieLogs').doc(logDocId).set({
        'user_id': userId,
        'log_date': Timestamp.fromDate(startOfDay),
        'Calories taken': totalCalories,
        'protein taken': totalProtein,
        'fats taken': totalFats,
        'carbs taken': totalCarbs,
        'recipe_count': uniqueItems.length, // عدد الوصفات/الوجبات الفريدة فقط
      });

      print('✅ Daily nutrition summary saved (without duplicates) for $userId on $startOfDay');
    } catch (e) {
      print('❌ Error in saveDailyNutritionSummary: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCombinedRecipesAndMealPlans(
      String userId, DateTime date) async {

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    try {
      // جلب وصفات Recipes لليوم
      final recipes = await getRecipesForDate(userId, date);

      // جلب وصفات MealPlans لليوم (بدون نوع محدد، تقدر تعدل لو تحتاج)
      final mealPlans = await getLogsFromMealPlans(userId, date, "");

      // دمج القائمتين
      List<Map<String, dynamic>> combinedList = [];

      combinedList.addAll(recipes);

      // من MealPlans نحول العناصر عشان تكون نفس صيغة Recipes للعرض
      for (var mp in mealPlans) {
        // استخراج الـ recipe_id بشكل صحيح
        String? mpRecipeId;
        if (mp['recipe_id'] is DocumentReference) {
          mpRecipeId = (mp['recipe_id'] as DocumentReference).id;
        } else if (mp['recipe_id'] is String) {
          mpRecipeId = mp['recipe_id'];
        } else {
          mpRecipeId = null;
        }

        if (mpRecipeId != null) {
          bool existsInRecipes = recipes.any((r) => r['recipe_id'] == mpRecipeId);
          if (!existsInRecipes) {
            combinedList.add({
              'recipe_id': mpRecipeId,
              'title': mp['title'] ?? '',
              'calories': mp['calories'] ?? 0,
              'Protein': mp['Protein'] ?? 0,
              'Fats': mp['Fats'] ?? 0,
              'Carbs': mp['Carbs'] ?? 0,
              'image_url': mp['image_url'] ?? '',
              'type': 'MealPlan',
              'date': mp['date'],
              'source': 'MealPlans',
            });
          }
        }
      }

      return combinedList;

    } catch (e) {
      print('Error combining recipes and meal plans: $e');
      return [];
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
          'title': data['title'] ?? '',
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
          'title': data['title'] ?? '',
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
