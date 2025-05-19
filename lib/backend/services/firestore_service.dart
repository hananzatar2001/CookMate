import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// إضافة وصفة جديدة (تستخدمها RecipeController)
  Future<void> addRecipe(Map<String, dynamic> recipeData) async {
    await _db.collection('recipes').doc(recipeData['id']).set({
      'id': recipeData['id'],
      'title': recipeData['title'],
      'image_url': recipeData['imageUrl'],   // لاحظ تعديل اسم المفتاح
      'ingredients': recipeData['Ingredients'],
      'steps': recipeData['steps'],
      'createdAt': recipeData['createdAt'],
    });
  }

  /// جلب الوصفات مع Pagination
  Future<List<Map<String, dynamic>>> getRecipesPaginated({
    DocumentSnapshot? startAfter,
    int limit = 10,
  }) async {
    Query query = _db
        .collection('recipes')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  /// جلب كل الوصفات بدون pagination
  Future<List<Map<String, dynamic>>> getAllRecipes() async {
    final snapshot = await _db.collection('recipes').orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  /// حفظ إشعار جديد (يمكنك تعديل حسب الحاجة)
  Future<void> saveNotification(Map<String, dynamic> data) async {
    await _db.collection('notifications').add(data);
  }

  /// جلب إشعارات المستخدم
  Future<List<Map<String, dynamic>>> loadUserNotifications(String userId) async {
    final snapshot = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  /// حفظ الجدولة (Meal Plan)
  Future<void> addSchedule({
    required String recipeId,
    required String recipeTitle,
    required DateTime scheduledDateTime,
    required String mealType,
  }) async {
    await _db.collection('mealPlans').add({
      'recipeId': recipeId,
      'recipeTitle': recipeTitle,
      'scheduledDateTime': scheduledDateTime,
      'mealType': mealType,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
