import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class IngredientService {
  static const String _apiKey = 'f688895a1e034a8087ffb5f77f44b38f';
  static const String _baseUrl = 'https://api.spoonacular.com';

  static Future<List<String>> fetchIngredients(String query) async {
    final url = Uri.parse('$_baseUrl/food/ingredients/search?query=$query&apiKey=$_apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List results = jsonDecode(response.body)['results'];
      return results.map((e) => e['name'].toString()).toList();
    } else {
      return [];
    }
  }
}
