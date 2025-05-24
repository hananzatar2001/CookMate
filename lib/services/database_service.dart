import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/app_database.dart';
import '../config/database_config.dart';
import 'data_initializer.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  final AppDatabase _database = AppDatabase();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final DataInitializer _dataInitializer;
  bool _isInitialized = false;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal() {
    _dataInitializer = DataInitializer(_firestore);
  }

  Future<void> initialize({
    String assetPath = DatabaseConfig.DEFAULT_DATA_PATH,
  }) async {
    if (_isInitialized) return;

    try {
      _database.setJsonFilePath(assetPath);
      _dataInitializer = DataInitializer(_firestore, jsonFilePath: assetPath);

      await Firebase.initializeApp();

      await Future.delayed(
        const Duration(milliseconds: DatabaseConfig.FIREBASE_INIT_TIMEOUT_MS),
      );

      bool isFirebaseAvailable = _isFirebaseAvailable();

      if (!isFirebaseAvailable) {
        debugPrint('Firebase is not available');

        if (DatabaseConfig.FALLBACK_TO_JSON) {
          debugPrint('Falling back to JSON data loading per configuration');
          await loadFromAsset(assetPath);
        } else {
          debugPrint(
            'Not falling back to JSON as per configuration. Using empty data.',
          );

          _database.loadSampleData();
        }

        _isInitialized = true;
        return;
      }

      bool isEmpty = false;
      try {
        isEmpty = await _dataInitializer.isDataEmpty();
      } catch (e) {
        debugPrint('Error checking if data is empty: $e');
        isEmpty = true;
      }

      if (isEmpty && DatabaseConfig.INITIALIZE_FROM_JSON) {
        debugPrint(
          'No data found in Firebase. Loading from JSON file as per configuration...',
        );
        await _dataInitializer.loadAndImportJsonFile();
      } else if (isEmpty) {
        debugPrint(
          'No data found in Firebase. Not initializing from JSON as per configuration.',
        );

        _database.loadSampleData();
      } else {
        debugPrint('Data found in Firebase, using existing data');
      }

      _isInitialized = true;
      debugPrint('Database initialization complete');
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');

      if (DatabaseConfig.FALLBACK_TO_JSON) {
        try {
          debugPrint(
            'Attempting to load from JSON as fallback per configuration',
          );
          await loadFromAsset(assetPath);
          debugPrint('Successfully loaded fallback data');
        } catch (jsonError) {
          debugPrint('Error loading from JSON fallback: $jsonError');

          _database.loadSampleData();
        }
      } else {
        debugPrint(
          'Not falling back to JSON as per configuration. Using empty data.',
        );

        _database.loadSampleData();
      }

      _isInitialized = true;
    }
  }

  bool _isFirebaseAvailable() {
    try {
      FirebaseFirestore.instance.collection('test');
      return true;
    } catch (e) {
      debugPrint('Firebase not available: $e');
      return false;
    }
  }

  Future<void> loadFromAsset(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      debugPrint('Successfully loaded JSON string from $assetPath');

      await _database.importFromJson(jsonString);
      debugPrint('Successfully imported data from $assetPath');
    } catch (e) {
      debugPrint('Error loading data from asset: $e');
      rethrow;
    }
  }

  Future<String> exportToJson() async {
    return _database.exportToJson();
  }

  Future<void> importFromJson(
    String jsonString, {
    bool overwriteExisting = false,
  }) async {
    return _dataInitializer.importFromJson(
      jsonString,
      overwriteExisting: overwriteExisting,
    );
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
    await loadFromAsset(DatabaseConfig.DEFAULT_DATA_PATH);
  }

  bool get isInitialized => _isInitialized;
}
