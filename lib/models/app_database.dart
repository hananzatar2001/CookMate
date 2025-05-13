import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'recipe.dart';
import 'user.dart';
import 'meal_plan.dart';
import 'nutrition.dart';
import 'notification.dart';
import 'notification_user.dart';
import 'favorites.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();

  static const String DB_SUFFIX = "_test_db_dana";

  static const String RECIPES_COLLECTION = "recipes" + DB_SUFFIX;
  static const String MEAL_PLANS_COLLECTION = "mealPlans" + DB_SUFFIX;
  static const String USERS_COLLECTION = "users" + DB_SUFFIX;
  static const String NUTRITION_COLLECTION = "nutrition" + DB_SUFFIX;
  static const String NOTIFICATIONS_COLLECTION = "notifications" + DB_SUFFIX;
  static const String NOTIFICATION_USERS_COLLECTION =
      "notificationUsers" + DB_SUFFIX;
  static const String FAVORITES_COLLECTION = "favorites" + DB_SUFFIX;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Recipe> _recipes = [];
  MealPlan? _userMealPlan;
  User? _currentUser;
  Nutrition? _userNutrition;
  List<AppNotification> _notifications = [];
  NotificationUser? _notificationUser;
  Favorites? _userFavorites;

  bool _isDataLoaded = false;
  bool _shouldLoadFromJson = true;
  String? _jsonFilePath;

  final List<Function> _listeners = [];

  factory AppDatabase() {
    return _instance;
  }

  AppDatabase._internal() {
    _initializeEmptyData();
    _loadDataFromFirebase();
  }

  List<Recipe> get allRecipes => _recipes;
  User? get currentUser => _currentUser;
  List<AppNotification> get allNotifications => _notifications;
  List<String> get userFavoriteIds => _userFavorites?.recipeIds ?? [];

  int get unreadNotificationsCount {
    return _notificationUser?.unreadNotificationIds.length ??
        _notifications.where((notification) => !notification.isRead).length;
  }

  String _hashPassword(String password) {
    return password;
  }

  void setJsonFilePath(String path) {
    _jsonFilePath = path;
    _shouldLoadFromJson = true;
  }

  void _initializeEmptyData() {
    _recipes = [];
    _userMealPlan = null;
    _userNutrition = null;
    _notifications = [];
    _notificationUser = null;
    _userFavorites = null;

    _currentUser = User(
      id: '1',
      name: 'Default User',
      email: 'user@example.com',
      password: _hashPassword('password'),
      dailyCalorieTarget: 2000,
      dailyProteinTarget: 100,
      dailyCarbsTarget: 250,
      dailyFatTarget: 65,
      age: 18,
      weight: 180,
      gender: 'female',
      height: 180,
      disease: null,
      allergy: null,
      isVegetarian: false,
    );
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

  Future<void> _loadDataFromFirebase() async {
    try {
      if (!_isFirebaseAvailable()) {
        debugPrint(
          'Firebase Firestore not available - skipping Firebase operations',
        );
        if (_shouldLoadFromJson && _jsonFilePath != null) {
          debugPrint('Falling back to JSON data loading');
          await _loadAndImportJsonFile();
        }
        return;
      }

      bool hasRecipes = await _collectionExists(RECIPES_COLLECTION);
      bool hasMealPlans = await _collectionExists(MEAL_PLANS_COLLECTION);
      bool hasUsers = await _collectionExists(USERS_COLLECTION);
      bool hasNutrition = await _collectionExists(NUTRITION_COLLECTION);
      bool hasNotifications = await _collectionExists(NOTIFICATIONS_COLLECTION);
      bool hasNotificationUsers = await _collectionExists(
        NOTIFICATION_USERS_COLLECTION,
      );
      bool hasFavorites = await _collectionExists(FAVORITES_COLLECTION);

      if (!hasRecipes &&
          !hasMealPlans &&
          !hasUsers &&
          !hasNutrition &&
          !hasNotifications &&
          !hasNotificationUsers &&
          !hasFavorites &&
          _shouldLoadFromJson &&
          _jsonFilePath != null) {
        debugPrint('No data found in Firebase. Loading from JSON file.');

        await _loadAndImportJsonFile();

        await _loadCollectionsIntoMemory();
      } else {
        await _loadCollectionsIntoMemory(
          loadRecipes: hasRecipes,
          loadMealPlans: hasMealPlans,
          loadUsers: hasUsers,
          loadNutrition: hasNutrition,
          loadNotifications: hasNotifications,
          loadNotificationUsers: hasNotificationUsers,
          loadFavorites: hasFavorites,
        );
      }

      _isDataLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading data from Firebase: $e');

      if (_shouldLoadFromJson && _jsonFilePath != null) {
        try {
          debugPrint('Attempting to load from JSON as fallback');
          await _loadAndImportJsonFile();
          _isDataLoaded = true;
          notifyListeners();
          return;
        } catch (jsonError) {
          debugPrint('Error loading from JSON fallback: $jsonError');
        }
      }

      _initializeEmptyData();
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

  Future<void> _loadCollectionsIntoMemory({
    bool loadRecipes = true,
    bool loadMealPlans = true,
    bool loadUsers = true,
    bool loadNutrition = true,
    bool loadNotifications = true,
    bool loadNotificationUsers = true,
    bool loadFavorites = true,
  }) async {
    try {
      if (loadRecipes) await _loadRecipes();
      if (loadUsers) await _loadUser();
      if (loadMealPlans) await _loadMealPlans();
      if (loadNutrition) await _loadNutrition();
      if (loadNotifications) await _loadNotifications();
      if (loadNotificationUsers) await _loadNotificationUsers();
      if (loadFavorites) await _loadFavorites();
    } catch (e) {
      debugPrint('Error loading collections into memory: $e');
      rethrow;
    }
  }

  Future<void> _loadAndImportJsonFile() async {
    try {
      if (_jsonFilePath == null) {
        debugPrint('No JSON file path set for default data loading');
        return;
      }

      final jsonString = await rootBundle.loadString(_jsonFilePath!);
      debugPrint('Successfully loaded JSON string from $_jsonFilePath');

      try {
        await importFromJson(jsonString, overwriteExisting: true);
        debugPrint('Successfully imported default data from JSON file');
      } catch (importError) {
        debugPrint('Error importing JSON data: $importError');

        _initializeEmptyData();
        rethrow;
      }
    } catch (e) {
      debugPrint('Error loading default data from JSON file: $e');

      _initializeEmptyData();
      rethrow;
    }
  }

  Future<void> _loadRecipes() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection(RECIPES_COLLECTION).get();
      _recipes =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Recipe.fromJson(data);
          }).toList();
    } catch (e) {
      debugPrint('Error loading recipes: $e');
      rethrow;
    }
  }

  Future<void> _loadMealPlans() async {
    try {
      if (_currentUser == null) {
        _userMealPlan = null;
        return;
      }

      final QuerySnapshot snapshot =
          await _firestore
              .collection(MEAL_PLANS_COLLECTION)
              .where('userId', isEqualTo: _currentUser!.id)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        _userMealPlan = MealPlan.fromJson(data);
      } else {
        _userMealPlan = MealPlan(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: _currentUser!.id,
          records: [],
        );
      }
    } catch (e) {
      debugPrint('Error loading meal plans: $e');
      rethrow;
    }
  }

  Future<void> _loadUser() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection(USERS_COLLECTION).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        _currentUser = User.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      rethrow;
    }
  }

  Future<void> _loadNutrition() async {
    try {
      if (_currentUser == null) {
        _userNutrition = null;
        return;
      }

      final QuerySnapshot snapshot =
          await _firestore
              .collection(NUTRITION_COLLECTION)
              .where('userId', isEqualTo: _currentUser!.id)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        _userNutrition = Nutrition.fromJson(data);
      } else {
        _userNutrition = Nutrition(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: _currentUser!.id,
          records: [],
        );
      }
    } catch (e) {
      debugPrint('Error loading nutrition data: $e');
      rethrow;
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection(NOTIFICATIONS_COLLECTION).get();
      _notifications =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return AppNotification.fromJson(data);
          }).toList();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      rethrow;
    }
  }

  Future<void> _loadNotificationUsers() async {
    try {
      if (_currentUser == null) {
        _notificationUser = null;
        return;
      }

      final QuerySnapshot snapshot =
          await _firestore
              .collection(NOTIFICATION_USERS_COLLECTION)
              .where('userId', isEqualTo: _currentUser!.id)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        _notificationUser = NotificationUser.fromJson(data);
      } else {
        _notificationUser = NotificationUser(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: _currentUser!.id,
          records: [],
        );
      }
    } catch (e) {
      debugPrint('Error loading notification users: $e');
      rethrow;
    }
  }

  Future<void> _loadFavorites() async {
    try {
      if (_currentUser == null) {
        _userFavorites = null;
        return;
      }

      final QuerySnapshot snapshot =
          await _firestore
              .collection(FAVORITES_COLLECTION)
              .where('userId', isEqualTo: _currentUser!.id)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        _userFavorites = Favorites.fromJson(data);
      } else {
        _userFavorites = Favorites(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: _currentUser!.id,
          recipeIds: [],
        );
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      rethrow;
    }
  }

  void loadSampleData() {
    _initializeEmptyData();
  }

  List<Recipe> getFavorites() {
    if (_userFavorites == null) return [];
    return _recipes
        .where((recipe) => _userFavorites!.recipeIds.contains(recipe.id))
        .toList();
  }

  List<Recipe> getByMealType(String mealType) {
    return _recipes.where((recipe) => recipe.mealType == mealType).toList();
  }

  Recipe? getRecipeById(String id) {
    try {
      return _recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      _recipes.add(recipe);

      await _firestore
          .collection(RECIPES_COLLECTION)
          .doc(recipe.id)
          .set(recipe.toJson());

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding recipe: $e');

      _recipes.removeWhere((r) => r.id == recipe.id);
      rethrow;
    }
  }

  Future<void> removeRecipe(String id) async {
    try {
      _recipes.removeWhere((recipe) => recipe.id == id);

      await _firestore.collection(RECIPES_COLLECTION).doc(id).delete();

      if (_userFavorites != null && _userFavorites!.recipeIds.contains(id)) {
        await toggleFavorite(id);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error removing recipe: $e');

      await _loadRecipes();
      rethrow;
    }
  }

  Future<void> toggleFavorite(String recipeId) async {
    try {
      if (_currentUser == null || _userFavorites == null) {
        debugPrint(
          'Cannot toggle favorite: No user is logged in or favorites not loaded',
        );
        return;
      }

      if (_userFavorites!.recipeIds.contains(recipeId)) {
        _userFavorites!.recipeIds.remove(recipeId);
      } else {
        _userFavorites!.recipeIds.add(recipeId);
      }

      await _firestore
          .collection(FAVORITES_COLLECTION)
          .doc(_userFavorites!.id)
          .set(_userFavorites!.toJson());

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      await _loadFavorites();
      rethrow;
    }
  }

  Future<void> updateRecipe(Recipe updatedRecipe) async {
    try {
      final recipeIndex = _recipes.indexWhere(
        (recipe) => recipe.id == updatedRecipe.id,
      );

      if (recipeIndex != -1) {
        _recipes[recipeIndex] = updatedRecipe;

        await _firestore
            .collection(RECIPES_COLLECTION)
            .doc(updatedRecipe.id)
            .update(updatedRecipe.toJson());

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating recipe: $e');

      await _loadRecipes();
      rethrow;
    }
  }

  List<Recipe> getRecipesForDate(DateTime date) {
    if (_userMealPlan == null) return [];

    final record = _userMealPlan!.getRecordForDate(date);
    if (record == null || record.recipeIds.isEmpty) return [];

    return _recipes
        .where((recipe) => record.recipeIds.contains(recipe.id))
        .toList();
  }

  Future<void> addRecipeToMealPlan(DateTime date, String recipeId) async {
    try {
      if (_currentUser == null || _userMealPlan == null) {
        debugPrint('Cannot add recipe to meal plan: No user is logged in');
        return;
      }

      final updatedMealPlan = _userMealPlan!.addRecipe(date, recipeId);
      _userMealPlan = updatedMealPlan;

      await _firestore
          .collection(MEAL_PLANS_COLLECTION)
          .doc(updatedMealPlan.id)
          .set(updatedMealPlan.toJson());

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding recipe to meal plan: $e');

      await _loadMealPlans();
      rethrow;
    }
  }

  Future<void> removeRecipeFromMealPlan(DateTime date, String recipeId) async {
    try {
      if (_currentUser == null || _userMealPlan == null) {
        debugPrint('Cannot remove recipe from meal plan: No user is logged in');
        return;
      }

      final updatedMealPlan = _userMealPlan!.removeRecipe(date, recipeId);
      _userMealPlan = updatedMealPlan;

      await _firestore
          .collection(MEAL_PLANS_COLLECTION)
          .doc(updatedMealPlan.id)
          .set(updatedMealPlan.toJson());

      notifyListeners();
    } catch (e) {
      debugPrint('Error removing recipe from meal plan: $e');

      await _loadMealPlans();
      rethrow;
    }
  }

  NutritionRecord? getNutritionByDate(DateTime date) {
    if (_userNutrition == null) return null;
    return _userNutrition!.getRecordForDate(date);
  }

  Future<void> updateNutrition(
    DateTime date, {
    int? consumedCalories,
    int? consumedProtein,
    int? consumedCarbs,
    int? consumedFat,
    int? targetCalories,
    int? targetProtein,
    int? targetCarbs,
    int? targetFat,
  }) async {
    try {
      if (_currentUser == null || _userNutrition == null) {
        debugPrint('Cannot update nutrition: No user is logged in');
        return;
      }

      final existingRecord = _userNutrition!.getRecordForDate(date);
      final dateStr = Nutrition.formatDate(date);

      if (targetCalories != null ||
          targetProtein != null ||
          targetCarbs != null ||
          targetFat != null) {
        final updateTargets = _userNutrition!.updateTargets(
          date,
          calories:
              targetCalories ??
              existingRecord?.targetCalories ??
              _currentUser!.dailyCalorieTarget,
          protein:
              targetProtein ??
              existingRecord?.targetProtein ??
              _currentUser!.dailyProteinTarget,
          carbs:
              targetCarbs ??
              existingRecord?.targetCarbs ??
              _currentUser!.dailyCarbsTarget,
          fat:
              targetFat ??
              existingRecord?.targetFat ??
              _currentUser!.dailyFatTarget,
        );

        _userNutrition = updateTargets;
      }

      if (consumedCalories != null ||
          consumedProtein != null ||
          consumedCarbs != null ||
          consumedFat != null) {
        final updateConsumed = _userNutrition!.updateConsumedNutrients(
          date,
          calories: consumedCalories ?? existingRecord?.consumedCalories ?? 0,
          protein: consumedProtein ?? existingRecord?.consumedProtein ?? 0,
          carbs: consumedCarbs ?? existingRecord?.consumedCarbs ?? 0,
          fat: consumedFat ?? existingRecord?.consumedFat ?? 0,
          targetCalories:
              existingRecord?.targetCalories ??
              _currentUser!.dailyCalorieTarget,
          targetProtein:
              existingRecord?.targetProtein ?? _currentUser!.dailyProteinTarget,
          targetCarbs:
              existingRecord?.targetCarbs ?? _currentUser!.dailyCarbsTarget,
          targetFat: existingRecord?.targetFat ?? _currentUser!.dailyFatTarget,
        );

        _userNutrition = updateConsumed;
      }

      await _firestore
          .collection(NUTRITION_COLLECTION)
          .doc(_userNutrition!.id)
          .set(_userNutrition!.toJson());

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating nutrition: $e');

      await _loadNutrition();
      rethrow;
    }
  }

  List<AppNotification> getUnreadNotifications() {
    if (_notificationUser != null && _notifications.isNotEmpty) {
      final unreadIds = _notificationUser!.unreadNotificationIds;
      return _notifications
          .where((notification) => unreadIds.contains(notification.id))
          .toList();
    }
    return _notifications.where((notif) => !notif.isRead).toList();
  }

  Future<void> addNotification(AppNotification notification) async {
    try {
      _notifications.add(notification);

      await _firestore
          .collection(NOTIFICATIONS_COLLECTION)
          .doc(notification.id)
          .set(notification.toJson());

      if (_currentUser != null && _notificationUser != null) {
        final updatedNotificationUser = _notificationUser!.addNotification(
          notification.id,
        );
        _notificationUser = updatedNotificationUser;

        await _firestore
            .collection(NOTIFICATION_USERS_COLLECTION)
            .doc(_notificationUser!.id)
            .set(_notificationUser!.toJson());
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding notification: $e');

      await _loadNotifications();
      rethrow;
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    try {
      if (_currentUser != null && _notificationUser != null) {
        final updatedNotificationUser = _notificationUser!.markAsRead(id);
        _notificationUser = updatedNotificationUser;

        await _firestore
            .collection(NOTIFICATION_USERS_COLLECTION)
            .doc(_notificationUser!.id)
            .set(_notificationUser!.toJson());
      } else {
        final index = _notifications.indexWhere((notif) => notif.id == id);
        if (index != -1) {
          _notifications[index].isRead = true;

          await _firestore.collection(NOTIFICATIONS_COLLECTION).doc(id).update({
            'isRead': true,
          });
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');

      await _loadNotifications();
      await _loadNotificationUsers();
      rethrow;
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      if (_currentUser != null && _notificationUser != null) {
        final updatedNotificationUser = _notificationUser!.markAllAsRead();
        _notificationUser = updatedNotificationUser;

        await _firestore
            .collection(NOTIFICATION_USERS_COLLECTION)
            .doc(_notificationUser!.id)
            .set(_notificationUser!.toJson());
      } else {
        for (var notification in _notifications) {
          notification.isRead = true;
        }

        final batch = _firestore.batch();

        for (var notification in _notifications) {
          batch.update(
            _firestore
                .collection(NOTIFICATIONS_COLLECTION)
                .doc(notification.id),
            {'isRead': true},
          );
        }

        await batch.commit();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');

      await _loadNotifications();
      await _loadNotificationUsers();
      rethrow;
    }
  }

  Future<void> removeNotification(String id) async {
    try {
      _notifications.removeWhere((notif) => notif.id == id);

      await _firestore.collection(NOTIFICATIONS_COLLECTION).doc(id).delete();

      notifyListeners();
    } catch (e) {
      debugPrint('Error removing notification: $e');

      await _loadNotifications();
      rethrow;
    }
  }

  Future<void> setUser(User user) async {
    try {
      _currentUser = user;

      await _firestore
          .collection(USERS_COLLECTION)
          .doc(user.id)
          .set(user.toJson());

      await _loadMealPlans();
      await _loadNutrition();
      await _loadFavorites();
      await _loadNotificationUsers();

      notifyListeners();
    } catch (e) {
      debugPrint('Error setting user: $e');

      await _loadUser();
      rethrow;
    }
  }

  Future<bool> validateUserCredentials(String email, String password) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection(USERS_COLLECTION)
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) {
        return false;
      }

      final userData = snapshot.docs.first.data() as Map<String, dynamic>;
      final user = User.fromJson(userData);

      return user.password == password;
    } catch (e) {
      debugPrint('Error validating credentials: $e');
      return false;
    }
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

  Nutrition _convertLegacyNutrition(Map<String, dynamic> legacyNutrition) {
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

    final targetCalories = _currentUser?.dailyCalorieTarget ?? 2000;
    final targetProtein = _currentUser?.dailyProteinTarget ?? 100;
    final targetCarbs = _currentUser?.dailyCarbsTarget ?? 250;
    final targetFat = _currentUser?.dailyFatTarget ?? 65;

    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final records = [
      NutritionRecord(
        date: dateStr,
        consumedCalories: consumedCalories,
        consumedProtein: consumedProtein,
        consumedCarbs: consumedCarbs,
        consumedFat: consumedFat,
        targetCalories: targetCalories,
        targetProtein: targetProtein,
        targetCarbs: targetCarbs,
        targetFat: targetFat,
      ),
    ];

    return Nutrition(id: id, userId: userId, records: records);
  }

  Future<String> exportToJson() async {
    final jsonData = {
      'recipes': _recipes.map((recipe) => recipe.toJson()).toList(),
      'mealPlan': _userMealPlan?.toJson(),
      'user': _currentUser?.toJson(),
      'nutrition': _userNutrition?.toJson(),
      'notifications':
          _notifications.map((notification) => notification.toJson()).toList(),
      'notificationUser': _notificationUser?.toJson(),
      'favorites': _userFavorites?.toJson(),
    };

    return jsonEncode(jsonData);
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
      } else {
        bool hasRecipes = await _collectionExists(RECIPES_COLLECTION);
        bool hasMealPlans = await _collectionExists(MEAL_PLANS_COLLECTION);
        bool hasUsers = await _collectionExists(USERS_COLLECTION);
        bool hasNutrition = await _collectionExists(NUTRITION_COLLECTION);
        bool hasNotifications = await _collectionExists(
          NOTIFICATIONS_COLLECTION,
        );
        bool hasNotificationUsers = await _collectionExists(
          NOTIFICATION_USERS_COLLECTION,
        );
        bool hasFavorites = await _collectionExists(FAVORITES_COLLECTION);

        List<Recipe> recipesToImport = [];
        if (jsonData['recipes'] != null) {
          final recipesList = jsonData['recipes'] as List;
          recipesToImport =
              recipesList
                  .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
                  .toList();
        }

        User? userToImport;
        if (jsonData['user'] != null &&
            jsonData['user'] is Map<String, dynamic>) {
          userToImport = User.fromJson(
            jsonData['user'] as Map<String, dynamic>,
          );
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

        Favorites? favoritesToImport;
        if (jsonData['favorites'] != null) {
          if (jsonData['favorites'] is List &&
              (jsonData['favorites'] as List).isNotEmpty) {
            favoritesToImport = Favorites.fromJson(
              (jsonData['favorites'] as List).first as Map<String, dynamic>,
            );
          } else if (jsonData['favorites'] is Map<String, dynamic>) {
            favoritesToImport = Favorites.fromJson(
              jsonData['favorites'] as Map<String, dynamic>,
            );
          }
        }

        MealPlan? mealPlanToImport;
        if (jsonData['mealPlan'] != null) {
          if (jsonData['mealPlan'] is Map<String, dynamic>) {
            mealPlanToImport = MealPlan.fromJson(
              jsonData['mealPlan'] as Map<String, dynamic>,
            );
          }
        } else if (jsonData['mealPlans'] != null) {
          final mealPlansList = jsonData['mealPlans'] as List;

          if (mealPlansList.isNotEmpty && userToImport != null) {
            final records = <MealPlanRecord>[];

            for (var legacyPlan in mealPlansList) {
              final legacyMealPlan = _convertLegacyMealPlan(
                legacyPlan as Map<String, dynamic>,
              );
              records.addAll(legacyMealPlan.records);
            }

            mealPlanToImport = MealPlan(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: userToImport.id,
              records: records,
            );
          }
        }

        Nutrition? nutritionToImport;
        if (jsonData['nutrition'] != null) {
          if (jsonData['nutrition'] is Map<String, dynamic>) {
            nutritionToImport = Nutrition.fromJson(
              jsonData['nutrition'] as Map<String, dynamic>,
            );
          } else if (jsonData['nutrition'] is List) {
            final nutritionList = jsonData['nutrition'] as List;

            if (nutritionList.isNotEmpty && userToImport != null) {
              final records = <NutritionRecord>[];

              for (var legacyNutrition in nutritionList) {
                final legacyNutritionObj = _convertLegacyNutrition(
                  legacyNutrition as Map<String, dynamic>,
                );
                records.addAll(legacyNutritionObj.records);
              }

              nutritionToImport = Nutrition(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                userId: userToImport.id,
                records: records,
              );
            }
          }
        }

        NotificationUser? notificationUserToImport;
        if (jsonData['notificationUser'] != null) {
          if (jsonData['notificationUser'] is Map<String, dynamic>) {
            notificationUserToImport = NotificationUser.fromJson(
              jsonData['notificationUser'] as Map<String, dynamic>,
            );
          }
        } else if (jsonData['notifications'] != null && userToImport != null) {
          final notificationsList = jsonData['notifications'] as List;
          final records = <NotificationRecord>[];

          for (var notification in notificationsList) {
            final notificationObj = AppNotification.fromJson(
              notification as Map<String, dynamic>,
            );
            records.add(
              NotificationRecord(
                notificationId: notificationObj.id,
                isRead: notificationObj.isRead,
              ),
            );
          }

          notificationUserToImport = NotificationUser(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userToImport.id,
            records: records,
          );
        }

        if (!hasRecipes && recipesToImport.isNotEmpty) {
          await _importRecipesToFirebase(recipesToImport);
          _recipes = recipesToImport;
        }

        if (!hasUsers && userToImport != null) {
          await _importUserToFirebase(userToImport);
          _currentUser = userToImport;
        }

        if (!hasMealPlans && mealPlanToImport != null) {
          await _importMealPlanToFirebase(mealPlanToImport);
          _userMealPlan = mealPlanToImport;
        }

        if (!hasNutrition && nutritionToImport != null) {
          await _importNutritionToFirebase(nutritionToImport);
          _userNutrition = nutritionToImport;
        }

        if (!hasNotifications && notificationsToImport.isNotEmpty) {
          await _importNotificationsToFirebase(notificationsToImport);
          _notifications = notificationsToImport;
        }

        if (!hasNotificationUsers && notificationUserToImport != null) {
          await _importNotificationUserToFirebase(notificationUserToImport);
          _notificationUser = notificationUserToImport;
        }

        if (!hasFavorites && favoritesToImport != null) {
          await _importFavoritesToFirebase(favoritesToImport);
          _userFavorites = favoritesToImport;
        }

        notifyListeners();
        return;
      }

      List<Recipe> recipesToImport = [];
      if (jsonData['recipes'] != null) {
        final recipesList = jsonData['recipes'] as List;
        recipesToImport =
            recipesList
                .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
                .toList();
      }

      User? userToImport;
      if (jsonData['user'] != null &&
          jsonData['user'] is Map<String, dynamic>) {
        userToImport = User.fromJson(jsonData['user'] as Map<String, dynamic>);
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

      MealPlan? mealPlanToImport;
      if (jsonData['mealPlan'] != null) {
        mealPlanToImport = MealPlan.fromJson(
          jsonData['mealPlan'] as Map<String, dynamic>,
        );
      } else if (jsonData['mealPlans'] != null && userToImport != null) {
        final mealPlansList = jsonData['mealPlans'] as List;
        final records = <MealPlanRecord>[];

        for (var legacyPlan in mealPlansList) {
          final legacyMealPlan = _convertLegacyMealPlan(
            legacyPlan as Map<String, dynamic>,
          );
          records.addAll(legacyMealPlan.records);
        }

        mealPlanToImport = MealPlan(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userToImport.id,
          records: records,
        );
      }

      Nutrition? nutritionToImport;
      if (jsonData['nutrition'] != null) {
        if (jsonData['nutrition'] is Map<String, dynamic>) {
          nutritionToImport = Nutrition.fromJson(
            jsonData['nutrition'] as Map<String, dynamic>,
          );
        } else if (jsonData['nutrition'] is List && userToImport != null) {
          final nutritionList = jsonData['nutrition'] as List;
          final records = <NutritionRecord>[];

          for (var legacyNutrition in nutritionList) {
            final legacyNutritionObj = _convertLegacyNutrition(
              legacyNutrition as Map<String, dynamic>,
            );
            records.addAll(legacyNutritionObj.records);
          }

          nutritionToImport = Nutrition(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userToImport.id,
            records: records,
          );
        }
      }

      NotificationUser? notificationUserToImport;
      if (jsonData['notificationUser'] != null) {
        notificationUserToImport = NotificationUser.fromJson(
          jsonData['notificationUser'] as Map<String, dynamic>,
        );
      } else if (jsonData['notifications'] != null && userToImport != null) {
        final notificationsList = jsonData['notifications'] as List;
        final records = <NotificationRecord>[];

        for (var notification in notificationsList) {
          final notificationObj = AppNotification.fromJson(
            notification as Map<String, dynamic>,
          );
          records.add(
            NotificationRecord(
              notificationId: notificationObj.id,
              isRead: notificationObj.isRead,
            ),
          );
        }

        notificationUserToImport = NotificationUser(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userToImport.id,
          records: records,
        );
      }

      Favorites? favoritesToImport;
      if (jsonData['favorites'] != null) {
        if (jsonData['favorites'] is List &&
            (jsonData['favorites'] as List).isNotEmpty) {
          favoritesToImport = Favorites.fromJson(
            (jsonData['favorites'] as List).first as Map<String, dynamic>,
          );
        } else if (jsonData['favorites'] is Map<String, dynamic>) {
          favoritesToImport = Favorites.fromJson(
            jsonData['favorites'] as Map<String, dynamic>,
          );
        }
      }

      await _importRecipesToFirebase(recipesToImport);
      if (userToImport != null) {
        await _importUserToFirebase(userToImport);
      }
      if (mealPlanToImport != null) {
        await _importMealPlanToFirebase(mealPlanToImport);
      }
      if (nutritionToImport != null) {
        await _importNutritionToFirebase(nutritionToImport);
      }
      await _importNotificationsToFirebase(notificationsToImport);
      if (notificationUserToImport != null) {
        await _importNotificationUserToFirebase(notificationUserToImport);
      }
      if (favoritesToImport != null) {
        await _importFavoritesToFirebase(favoritesToImport);
      }

      _recipes = recipesToImport;
      _currentUser = userToImport;
      _userMealPlan = mealPlanToImport;
      _userNutrition = nutritionToImport;
      _notifications = notificationsToImport;
      _notificationUser = notificationUserToImport;
      _userFavorites = favoritesToImport;

      notifyListeners();
    } catch (e) {
      debugPrint('Error importing from JSON: $e');
      _initializeEmptyData();
      rethrow;
    }
  }

  Future<void> loadDefaultDataFromJson() async {
    if (_jsonFilePath == null) {
      debugPrint('No JSON file path set for default data loading');
      return;
    }

    await _loadAndImportJsonFile();
  }

  Future<void> _clearFirebaseCollections() async {
    await _deleteCollection(RECIPES_COLLECTION);
    await _deleteCollection(MEAL_PLANS_COLLECTION);
    await _deleteCollection(USERS_COLLECTION);
    await _deleteCollection(NUTRITION_COLLECTION);
    await _deleteCollection(NOTIFICATIONS_COLLECTION);
    await _deleteCollection(NOTIFICATION_USERS_COLLECTION);
    await _deleteCollection(FAVORITES_COLLECTION);
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
    final batch = _firestore.batch();

    for (var recipe in recipes) {
      final docRef = _firestore.collection(RECIPES_COLLECTION).doc(recipe.id);
      batch.set(docRef, recipe.toJson());
    }

    if (recipes.isNotEmpty) {
      await batch.commit();
    }
  }

  Future<void> _importMealPlanToFirebase(MealPlan mealPlan) async {
    await _firestore
        .collection(MEAL_PLANS_COLLECTION)
        .doc(mealPlan.id)
        .set(mealPlan.toJson());
  }

  Future<void> _importUserToFirebase(User user) async {
    await _firestore
        .collection(USERS_COLLECTION)
        .doc(user.id)
        .set(user.toJson());
  }

  Future<void> _importNutritionToFirebase(Nutrition nutrition) async {
    await _firestore
        .collection(NUTRITION_COLLECTION)
        .doc(nutrition.id)
        .set(nutrition.toJson());
  }

  Future<void> _importNotificationsToFirebase(
    List<AppNotification> notifications,
  ) async {
    final batch = _firestore.batch();

    for (var notification in notifications) {
      final docRef = _firestore
          .collection(NOTIFICATIONS_COLLECTION)
          .doc(notification.id);
      batch.set(docRef, notification.toJson());
    }

    if (notifications.isNotEmpty) {
      await batch.commit();
    }
  }

  Future<void> _importNotificationUserToFirebase(
    NotificationUser notificationUser,
  ) async {
    await _firestore
        .collection(NOTIFICATION_USERS_COLLECTION)
        .doc(notificationUser.id)
        .set(notificationUser.toJson());
  }

  Future<void> _importFavoritesToFirebase(Favorites favorites) async {
    try {
      await _firestore
          .collection(FAVORITES_COLLECTION)
          .doc(favorites.id)
          .set(favorites.toJson());
      debugPrint('Successfully imported favorites to Firebase');
    } catch (e) {
      debugPrint('Error importing favorites to Firebase: $e');
      rethrow;
    }
  }

  void addListener(Function listener) {
    _listeners.add(listener);
  }

  void removeListener(Function listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  Future<void> updateConsumedNutrients(
    DateTime date, {
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
  }) async {
    await updateNutrition(
      date,
      consumedCalories: calories,
      consumedProtein: protein,
      consumedCarbs: carbs,
      consumedFat: fat,
    );
  }

  MealPlan? getMealPlanByDate(DateTime date) {
    if (_userMealPlan == null) return null;

    final record = _userMealPlan!.getRecordForDate(date);
    if (record == null || record.recipeIds.isEmpty) return null;

    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return MealPlan(
      id: _userMealPlan!.id,
      userId: _userMealPlan!.userId,
      records: [record],
    );
  }

  List<Recipe> getRecipesForMeal(DateTime date, String mealType) {
    if (_userMealPlan == null) return [];

    final record = _userMealPlan!.getRecordForDate(date);
    if (record == null || record.recipeIds.isEmpty) return [];

    return _recipes
        .where(
          (recipe) =>
              record.recipeIds.contains(recipe.id) &&
              recipe.mealType.toLowerCase() == mealType.toLowerCase(),
        )
        .toList();
  }
}
