import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile_Recipe_view_model.dart';

class ProfileRecipeSectionService {
  static Future<Map<String, dynamic>> fetchUserRecipes({
    required String userId,
    DocumentSnapshot? lastDoc,
    int limit =10
  }) async {
    Query query = FirebaseFirestore.instance
        .collection('Recipes')
        .where('user_id', isEqualTo: userId)
        .orderBy(FieldPath.documentId)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snapshot = await query.get();
    final recipes = snapshot.docs
        .map((doc) => ProfileCollectionRecipesSectionModel.fromDoc(doc))
        .toList();

    return {
      'recipes': recipes,
      'lastDoc': snapshot.docs.isNotEmpty ? snapshot.docs.last : lastDoc,
      'hasMore': snapshot.docs.length == limit,
    };
  }
}
