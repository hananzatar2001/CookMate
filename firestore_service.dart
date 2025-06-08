import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// إضافة وصفة جديدة
  Future<void> addRecipe(Map<String, dynamic> recipeData) async {
    await _db.collection('recipes').doc(recipeData['id']).set({
      'id': recipeData['id'],
      'title': recipeData['title'],
      'image_url': recipeData['imageUrl'], // أو image_url حسب التوحيد
      'ingredients': recipeData['Ingredients'],
      'steps': recipeData['steps'],
      'source': recipeData['source'] ?? 'manual',
      'created_at': recipeData['createdAt'] is DateTime
          ? Timestamp.fromDate(recipeData['createdAt'])
          : recipeData['createdAt'],
    });
  }

  /// جلب الوصفات مع Pagination
  Future<List<Map<String, dynamic>>> getRecipesPaginated({
    DocumentSnapshot? startAfter,
    int limit = 10,
  }) async {
    Query query = _db
        .collection('recipes')
        .orderBy('created_at', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  /// جلب كل الوصفات بدون pagination
  Future<List<Map<String, dynamic>>> getAllRecipes() async {
    final snapshot = await _db.collection('recipes')
        .orderBy('created_at', descending: true).get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  /// حفظ إشعار جديد
  Future<void> saveNotification(Map<String, dynamic> data) async {
    await _db.collection('notifications').add(data);
  }

  /// جلب إشعارات مستخدم
  Future<List<Map<String, dynamic>>> loadUserNotifications(String userId) async {
    final snapshot = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  /// حفظ جدول وجبة في خطة الوجبات
  Future<void> addSchedule({
    required String userId,
    required String recipeId,
    required DateTime scheduledDateTime,
    required String mealType,
  }) async {
    await _db.collection('meal_plan').add({
      'user_id': _db.collection('users').doc(userId),         // reference
      'recipe_id': _db.collection('recipes').doc(recipeId),   // reference
      'plan_id': '',
      'meal_type': mealType,
      'date_scheduled': Timestamp.fromDate(scheduledDateTime),
    });
  }
}
