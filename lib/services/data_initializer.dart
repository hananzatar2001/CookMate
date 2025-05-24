import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user/user.dart';
import '../models/recipe/recipe.dart';
import '../models/meal_plan/meal_plan.dart';
import '../models/nutrition/nutrition.dart';
import '../models/notification/notification.dart';
import '../models/notification/notification_user.dart';
import '../models/favorites/favorites.dart';
import '../config/database_config.dart';

class DataInitializer {
  final FirebaseFirestore _firestore;
  final String? _jsonFilePath;

  DataInitializer(this._firestore, {String? jsonFilePath})
    : _jsonFilePath = jsonFilePath;

  Future<bool> isDataEmpty() async {
    try {
      bool hasRecipes = await _collectionExists(
        DatabaseConfig.RECIPES_COLLECTION,
      );
      bool hasUsers = await _collectionExists(DatabaseConfig.USERS_COLLECTION);

      return !hasRecipes || !hasUsers;
    } catch (e) {
      debugPrint('Error checking if data is empty: $e');

      return true;
    }
  }

  Future<bool> _collectionExists(String collectionPath) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection(collectionPath).limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if collection exists: $e');
      return false;
    }
  }

  Future<void> loadAndImportJsonFile() async {
    try {
      if (_jsonFilePath == null) {
        debugPrint('No JSON file path set for default data loading');
        return;
      }

      final jsonString = await rootBundle.loadString(_jsonFilePath!);
      debugPrint('Successfully loaded JSON string from $_jsonFilePath');

      try {
        await importFromJson(jsonString, overwriteExisting: false);
        debugPrint('Successfully imported default data from JSON file');
      } catch (importError) {
        debugPrint('Error importing JSON data: $importError');
        rethrow;
      }
    } catch (e) {
      debugPrint('Error loading default data from JSON file: $e');
      rethrow;
    }
  }

  Future<void> importFromJson(
    String jsonString, {
    bool overwriteExisting = false,
  }) async {
    try {
      final jsonData = jsonDecode(jsonString);

      if (jsonData is! Map<String, dynamic>) {
        throw FormatException(
          'Expected a JSON object but got ${jsonData.runtimeType}',
        );
      }

      if (overwriteExisting) {
        await _clearFirebaseCollections();
      }

      final extractedData = _extractDataFromJson(jsonData);

      await _importDataToFirebase(extractedData);
    } catch (e) {
      debugPrint('Error importing from JSON: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _extractDataFromJson(Map<String, dynamic> jsonData) {
    User? userToImport;
    if (jsonData['user'] != null && jsonData['user'] is Map<String, dynamic>) {
      userToImport = User.fromJson(jsonData['user'] as Map<String, dynamic>);
    }

    List<Recipe> recipesToImport = [];
    if (jsonData['recipes'] != null) {
      final recipesList = jsonData['recipes'] as List;
      recipesToImport =
          recipesList
              .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
              .toList();
    }

    List<AppNotification> notificationsToImport = [];
    if (jsonData['notifications'] != null) {
      final notificationsList = jsonData['notifications'] as List;
      notificationsToImport =
          notificationsList
              .map(
                (json) =>
                    AppNotification.fromJson(json as Map<String, dynamic>),
              )
              .toList();
    }

    final mealPlanToImport = _extractMealPlan(jsonData, userToImport);
    final nutritionToImport = _extractNutrition(jsonData, userToImport);
    final notificationUserToImport = _extractNotificationUser(
      jsonData,
      userToImport,
      notificationsToImport,
    );
    final favoritesToImport = _extractFavorites(jsonData, userToImport);

    return {
      'user': userToImport,
      'recipes': recipesToImport,
      'mealPlan': mealPlanToImport,
      'nutrition': nutritionToImport,
      'notifications': notificationsToImport,
      'notificationUser': notificationUserToImport,
      'favorites': favoritesToImport,
    };
  }

  Future<void> _importDataToFirebase(Map<String, dynamic> data) async {
    final user = data['user'] as User?;
    final recipes = data['recipes'] as List<Recipe>;
    final mealPlan = data['mealPlan'] as MealPlan?;
    final nutrition = data['nutrition'] as Nutrition?;
    final notifications = data['notifications'] as List<AppNotification>;
    final notificationUser = data['notificationUser'] as NotificationUser?;
    final favorites = data['favorites'] as Favorites?;

    if (user == null || recipes.isEmpty) {
      debugPrint('Warning: JSON data is missing essential user or recipe data');
    }

    if (recipes.isNotEmpty) {
      await _importRecipesToFirebase(recipes);
    }

    if (user != null) {
      await _importUserToFirebase(user);
    }

    if (mealPlan != null) {
      await _importMealPlanToFirebase(mealPlan);
    }

    if (nutrition != null) {
      await _importNutritionToFirebase(nutrition);
    }

    if (notifications.isNotEmpty) {
      await _importNotificationsToFirebase(notifications);
    }

    if (notificationUser != null) {
      await _importNotificationUserToFirebase(notificationUser);
    }

    if (favorites != null) {
      await _importFavoritesToFirebase(favorites);
    }
  }

  MealPlan? _extractMealPlan(
    Map<String, dynamic> jsonData,
    User? userToImport,
  ) {
    if (jsonData['mealPlan'] != null) {
      if (jsonData['mealPlan'] is Map<String, dynamic>) {
        return MealPlan.fromJson(jsonData['mealPlan'] as Map<String, dynamic>);
      }
    } else if (jsonData['mealPlans'] != null && userToImport != null) {
      final mealPlansList = jsonData['mealPlans'] as List;
      final records = <MealPlanRecord>[];

      for (var legacyPlan in mealPlansList) {
        final legacyMealPlan = _convertLegacyMealPlan(
          legacyPlan as Map<String, dynamic>,
        );
        records.addAll(legacyMealPlan.records);
      }

      return MealPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userToImport.id,
        records: records,
      );
    }
    return null;
  }

  MealPlan _convertLegacyMealPlan(Map<String, dynamic> legacyMealPlan) {
    final id = legacyMealPlan['id'] as String;
    final userId = legacyMealPlan['userId'] as String;
    final date =
        legacyMealPlan['date'] is Timestamp
            ? (legacyMealPlan['date'] as Timestamp).toDate()
            : DateTime.parse(legacyMealPlan['date']);
    final meals = legacyMealPlan['meals'] as Map<String, dynamic>;

    final List<String> recipeIds = [];
    meals.forEach((mealType, ids) {
      if (ids is List) {
        recipeIds.addAll(List<String>.from(ids));
      }
    });

    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final records = [MealPlanRecord(date: dateStr, recipeIds: recipeIds)];

    return MealPlan(id: id, userId: userId, records: records);
  }

  Nutrition? _extractNutrition(
    Map<String, dynamic> jsonData,
    User? userToImport,
  ) {
    if (jsonData['nutrition'] != null) {
      if (jsonData['nutrition'] is Map<String, dynamic>) {
        return Nutrition.fromJson(
          jsonData['nutrition'] as Map<String, dynamic>,
        );
      } else if (jsonData['nutrition'] is List && userToImport != null) {
        final nutritionList = jsonData['nutrition'] as List;
        final records = <NutritionRecord>[];

        for (var legacyNutrition in nutritionList) {
          final legacyNutritionObj = _convertLegacyNutrition(
            legacyNutrition as Map<String, dynamic>,
            userToImport,
          );
          records.addAll(legacyNutritionObj.records);
        }

        return Nutrition(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userToImport.id,
          records: records,
        );
      }
    }
    return null;
  }

  Nutrition _convertLegacyNutrition(
    Map<String, dynamic> legacyNutrition,
    User currentUser,
  ) {
    final id = legacyNutrition['id'] as String;
    final userId = legacyNutrition['userId'] as String;
    final date =
        legacyNutrition['date'] is Timestamp
            ? (legacyNutrition['date'] as Timestamp).toDate()
            : DateTime.parse(legacyNutrition['date']);

    final consumedCalories = legacyNutrition['consumedCalories'] as int? ?? 0;
    final consumedProtein = legacyNutrition['consumedProtein'] as int? ?? 0;
    final consumedCarbs = legacyNutrition['consumedCarbs'] as int? ?? 0;
    final consumedFat = legacyNutrition['consumedFat'] as int? ?? 0;
    final consumedFiber = legacyNutrition['consumedFiber'] as int? ?? 0;

    final targetCalories = currentUser.dailyCalorieTarget;
    final targetProtein = currentUser.dailyProteinTarget;
    final targetCarbs = currentUser.dailyCarbsTarget;
    final targetFat = currentUser.dailyFatTarget;
    final targetFiber = currentUser.dailyFiberTarget;

    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final records = [
      NutritionRecord(
        date: dateStr,
        consumedCalories: consumedCalories,
        consumedProtein: consumedProtein,
        consumedCarbs: consumedCarbs,
        consumedFat: consumedFat,
        consumedFiber: consumedFiber,
        targetCalories: targetCalories,
        targetProtein: targetProtein,
        targetCarbs: targetCarbs,
        targetFat: targetFat,
        targetFiber: targetFiber,
      ),
    ];

    return Nutrition(id: id, userId: userId, records: records);
  }

  NotificationUser? _extractNotificationUser(
    Map<String, dynamic> jsonData,
    User? userToImport,
    List<AppNotification> notifications,
  ) {
    if (jsonData['notificationUser'] != null) {
      if (jsonData['notificationUser'] is Map<String, dynamic>) {
        return NotificationUser.fromJson(
          jsonData['notificationUser'] as Map<String, dynamic>,
        );
      }
    } else if (userToImport != null && notifications.isNotEmpty) {
      final records = <NotificationRecord>[];

      for (var notification in notifications) {
        records.add(
          NotificationRecord(
            notificationId: notification.id,
            isRead: notification.isRead,
          ),
        );
      }

      return NotificationUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userToImport.id,
        records: records,
      );
    }
    return null;
  }

  Favorites? _extractFavorites(
    Map<String, dynamic> jsonData,
    User? userToImport,
  ) {
    if (jsonData['favorites'] != null) {
      if (jsonData['favorites'] is List &&
          (jsonData['favorites'] as List).isNotEmpty) {
        return Favorites.fromJson(
          (jsonData['favorites'] as List).first as Map<String, dynamic>,
        );
      } else if (jsonData['favorites'] is Map<String, dynamic>) {
        return Favorites.fromJson(
          jsonData['favorites'] as Map<String, dynamic>,
        );
      }
    } else if (userToImport != null) {
      return Favorites(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userToImport.id,
        recipeIds: [],
      );
    }
    return null;
  }

  Future<void> _clearFirebaseCollections() async {
    await _deleteCollection(DatabaseConfig.RECIPES_COLLECTION);
    await _deleteCollection(DatabaseConfig.MEAL_PLANS_COLLECTION);
    await _deleteCollection(DatabaseConfig.USERS_COLLECTION);
    await _deleteCollection(DatabaseConfig.NUTRITION_COLLECTION);
    await _deleteCollection(DatabaseConfig.NOTIFICATIONS_COLLECTION);
    await _deleteCollection(DatabaseConfig.NOTIFICATION_USERS_COLLECTION);
    await _deleteCollection(DatabaseConfig.FAVORITES_COLLECTION);
  }

  Future<void> _deleteCollection(String collectionPath) async {
    final snapshot = await _firestore.collection(collectionPath).get();
    final batch = _firestore.batch();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  Future<void> _importRecipesToFirebase(List<Recipe> recipes) async {
    if (recipes.isEmpty) return;

    final batch = _firestore.batch();
    for (var recipe in recipes) {
      final docRef = _firestore
          .collection(DatabaseConfig.RECIPES_COLLECTION)
          .doc(recipe.id);
      batch.set(docRef, recipe.toJson());
    }
    await batch.commit();
  }

  Future<void> _importUserToFirebase(User user) async {
    await _firestore
        .collection(DatabaseConfig.USERS_COLLECTION)
        .doc(user.id)
        .set(user.toJson());
  }

  Future<void> _importMealPlanToFirebase(MealPlan mealPlan) async {
    await _firestore
        .collection(DatabaseConfig.MEAL_PLANS_COLLECTION)
        .doc(mealPlan.id)
        .set(mealPlan.toJson());
  }

  Future<void> _importNutritionToFirebase(Nutrition nutrition) async {
    await _firestore
        .collection(DatabaseConfig.NUTRITION_COLLECTION)
        .doc(nutrition.id)
        .set(nutrition.toJson());
  }

  Future<void> _importNotificationsToFirebase(
    List<AppNotification> notifications,
  ) async {
    if (notifications.isEmpty) return;

    final batch = _firestore.batch();
    for (var notification in notifications) {
      final docRef = _firestore
          .collection(DatabaseConfig.NOTIFICATIONS_COLLECTION)
          .doc(notification.id);
      batch.set(docRef, notification.toJson());
    }
    await batch.commit();
  }

  Future<void> _importNotificationUserToFirebase(
    NotificationUser notificationUser,
  ) async {
    await _firestore
        .collection(DatabaseConfig.NOTIFICATION_USERS_COLLECTION)
        .doc(notificationUser.id)
        .set(notificationUser.toJson());
  }

  Future<void> _importFavoritesToFirebase(Favorites favorites) async {
    await _firestore
        .collection(DatabaseConfig.FAVORITES_COLLECTION)
        .doc(favorites.id)
        .set(favorites.toJson());
  }
}
