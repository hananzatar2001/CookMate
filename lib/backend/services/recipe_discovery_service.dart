import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeDiscoveryService {
  final String apiKey = '5cbc633fbbd840a29f5a29225a1ad55f';

  Future<List<Map<String, dynamic>>> fetchFromAPI({
    required int offset,
    required int pageSize,
    String query = '',
  }) async {
    final url = Uri.https('api.spoonacular.com', '/recipes/complexSearch', {
      'apiKey': apiKey,
      'query': query,
      'number': '$pageSize',
      'offset': '$offset',
    });

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map<Map<String, dynamic>>((e) => {
        'id': e['id'],
        'title': e['title'],
        'image_url': e['image'],
        'source': 'api',
      }).toList();
    } else {
      throw Exception('Failed to load API recipes');
    }
  }

  Future<List<Map<String, dynamic>>> fetchFromFirestore({String query = ''}) async {
    Query<Map<String, dynamic>> firestoreQuery = FirebaseFirestore.instance
        .collection('Recipes')
        .orderBy('title')
        .limit(50);

    if (query.isNotEmpty) {
      final capitalized = query[0].toUpperCase() + query.substring(1);
      firestoreQuery = firestoreQuery
          .where('title', isGreaterThanOrEqualTo: capitalized)
          .where('title', isLessThan: capitalized + 'z');
    }

    final docs = await firestoreQuery.get();

    return docs.docs.map((doc) {
      final data = doc.data();
      return {
        'id': data['recipe_id'] ?? doc.id,
        'title': data['title'] ?? '',
        'image_url': data['image_url'] ?? '',
        'calories': data['calories'] ?? '',
        'carbohydrates': data['carbohydrates'] ?? '',
        'fat': data['fat'] ?? '',
        'protein': data['protein'] ?? '',
        'ingredients': data['ingredients'] ?? [],
        'instructions': data['instructions'] ?? '',
        'source': 'firestore',
        'data': data,
      };
    }).toList();
  }
}
