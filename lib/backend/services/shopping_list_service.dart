import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingListService {
  final CollectionReference shoppingList =
  FirebaseFirestore.instance.collection('ShoppingList');

  Future<List<String>> getShoppingList(String userId) async {
    final doc = await shoppingList.doc(userId).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data() as Map<String, dynamic>;
      final List<dynamic> products = data['products'] ?? [];
      return products.cast<String>();
    }
    return [];
  }
  bool isValidInput(String input) {
    final regex = RegExp(r'^[a-zA-Z0-9 ]+$');
    return regex.hasMatch(input);
  }
  Future<void> addItem(String userId, String item) async {
    final docRef = shoppingList.doc(userId);
    await docRef.set({
      'products': FieldValue.arrayUnion([item]),
      'user_id': userId,
    }, SetOptions(merge: true));

  }
  Future<void> removeItem(String userId, String item) async {
    final docRef = shoppingList.doc(userId);
    await docRef.update({
      'products': FieldValue.arrayRemove([item]),
    });
  }
}