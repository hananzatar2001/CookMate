import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/app_database.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static const String DEFAULT_DATA_PATH = 'assets/data/app_data.json';
  final AppDatabase _database = AppDatabase();
  bool _isInitialized = false;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> initialize({String assetPath = DEFAULT_DATA_PATH}) async {
    if (_isInitialized) return;

    try {
      _database.setJsonFilePath(assetPath);

      await Firebase.initializeApp();

      await Future.delayed(const Duration(milliseconds: 500));

      bool hasData = false;
      try {
        hasData = await _checkFirebaseDataExists();
      } catch (e) {
        print('Error checking Firebase data: $e');
      }

      if (!hasData) {
        print('No data found in Firebase. Loading from JSON file...');
        await loadFromAsset(assetPath);
      } else {
        print('Data found in Firebase, using existing data');
      }

      _isInitialized = true;
      print('Database initialization complete');
    } catch (e) {
      print('Error initializing Firebase: $e');

      try {
        print('Attempting to load from JSON as fallback...');
        await loadFromAsset(assetPath);
        print('Successfully loaded fallback data');
      } catch (jsonError) {
        print('Error loading from JSON fallback: $jsonError');
      }

      _isInitialized = true;
    }
  }

  Future<bool> _checkFirebaseDataExists() async {
    try {
      final jsonData = await _database.exportToJson();
      final Map<String, dynamic> data = jsonDecode(jsonData);

      bool hasRecipes =
          data['recipes'] != null && (data['recipes'] as List).isNotEmpty;
      bool hasUsers = data['user'] != null;
      bool hasFavorites = data['favorites'] != null;

      return hasRecipes && hasUsers;
    } catch (e) {
      print('Error checking Firebase data: $e');
      return false;
    }
  }

  Future<void> loadFromAsset(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      print('Successfully loaded JSON string from $assetPath');

      await _database.importFromJson(jsonString);
      print('Successfully imported data from $assetPath');
    } catch (e) {
      print('Error loading data from asset: $e');
      rethrow;
    }
  }

  Future<String> exportToJson() async {
    return _database.exportToJson();
  }

  AppDatabase get database {
    if (!_isInitialized) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _database;
  }

  Future<String> saveData() async {
    final jsonData = await exportToJson();
    return jsonData;
  }

  Future<void> resetToDefaultData() async {
    await loadFromAsset(DEFAULT_DATA_PATH);
  }
}
