import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../config/database_config.dart';

import 'user/user_repository.dart';
import 'recipe/recipe_repository.dart';
import 'meal_plan/meal_plan_repository.dart';
import 'nutrition/nutrition_repository.dart';
import 'notification/notification_repository.dart';
import 'favorites/favorites_repository.dart';

import 'user/user.dart';
import 'recipe/recipe.dart';
import 'meal_plan/meal_plan.dart';
import 'nutrition/nutrition.dart';
import 'notification/notification.dart';
import 'notification/notification_user.dart';
import 'favorites/favorites.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final UserRepository _userRepository;
  late final RecipeRepository _recipeRepository;
  late final MealPlanRepository _mealPlanRepository;
  late final NutritionRepository _nutritionRepository;
  late final NotificationRepository _notificationRepository;
  late final FavoritesRepository _favoritesRepository;

  List<Recipe> _recipes = [];
  MealPlan? _userMealPlan;
  User? _currentUser;
  Nutrition? _userNutrition;
  List<AppNotification> _notifications = [];
  NotificationUser? _notificationUser;
  Favorites? _userFavorites;

  bool _isDataLoaded = false;
  String? _jsonFilePath;

  final List<Function> _listeners = [];

  factory AppDatabase() {
    return _instance;
  }

  AppDatabase._internal() {
    _userRepository = UserRepository(_firestore);
    _recipeRepository = RecipeRepository(_firestore);
    _mealPlanRepository = MealPlanRepository(_firestore);
    _nutritionRepository = NutritionRepository(_firestore);
    _notificationRepository = NotificationRepository(_firestore);
    _favoritesRepository = FavoritesRepository(_firestore);

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

  void setJsonFilePath(String path) {
    _jsonFilePath = path;
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
      password: _userRepository.hashPassword('password'),
      dailyCalorieTarget: 2000,
      dailyProteinTarget: 100,
      dailyCarbsTarget: 250,
      dailyFatTarget: 65,
      dailyFiberTarget: 25,
      age: 18,
      weight: 180,
      gender: 'female',
      height: 180,
      disease: null,
      allergy: null,
      isVegetarian: false,
    );
  }

  Future<void> _loadDataFromFirebase() async {
    try {
      if (!_isFirebaseAvailable()) {
        debugPrint(
          'Firebase Firestore not available - skipping Firebase operations',
        );
        if (DatabaseConfig.FALLBACK_TO_JSON && _jsonFilePath != null) {
          debugPrint('Falling back to JSON data loading per configuration');
          await _importJsonData(_jsonFilePath!);
        } else {
          debugPrint(
            'Not using JSON fallback per configuration. Using empty data.',
          );
          _initializeEmptyData();
        }
        return;
      }

      await _loadCollectionsIntoMemory();

      _isDataLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading data from Firebase: $e');
      _initializeEmptyData();
      notifyListeners();
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

  Future<void> _loadCollectionsIntoMemory() async {
    try {
      await _loadUser();
      await _loadRecipes();
      await _loadMealPlans();
      await _loadNutrition();
      await _loadNotifications();
      await _loadNotificationUsers();
      await _loadFavorites();
    } catch (e) {
      debugPrint('Error loading collections into memory: $e');
      rethrow;
    }
  }

  Future<void> _importJsonData(String path) async {
    try {
      final jsonString = await rootBundle.loadString(path);
      await importFromJson(jsonString);
    } catch (e) {
      debugPrint('Error importing JSON data: $e');
      _initializeEmptyData();
    }
  }

  Future<void> _loadUser() async {
    try {
      _currentUser = await _userRepository.loadUser();
    } catch (e) {
      debugPrint('Error loading user: $e');
      rethrow;
    }
  }

  Future<void> _loadRecipes() async {
    try {
      _recipes = await _recipeRepository.loadRecipes();
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

      _userMealPlan = await _mealPlanRepository.loadMealPlan(_currentUser!.id);
    } catch (e) {
      debugPrint('Error loading meal plans: $e');
      rethrow;
    }
  }

  Future<void> _loadNutrition() async {
    try {
      if (_currentUser == null) {
        _userNutrition = null;
        return;
      }

      _userNutrition = await _nutritionRepository.loadNutrition(
        _currentUser!.id,
      );
    } catch (e) {
      debugPrint('Error loading nutrition data: $e');
      rethrow;
    }
  }

  Future<void> _loadNotifications() async {
    try {
      _notifications = await _notificationRepository.loadNotifications();
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

      _notificationUser = await _notificationRepository.loadNotificationUser(
        _currentUser!.id,
      );
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

      _userFavorites = await _favoritesRepository.loadFavorites(
        _currentUser!.id,
      );
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
    return _recipeRepository.getByMealType(_recipes, mealType);
  }

  Recipe? getRecipeById(String id) {
    return _recipeRepository.getRecipeById(_recipes, id);
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      _recipes.add(recipe);
      await _recipeRepository.addRecipe(recipe);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding recipe: $e');
      _recipes.removeWhere((r) => r.id == recipe.id);
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
        await _recipeRepository.updateRecipe(updatedRecipe);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating recipe: $e');
      await _loadRecipes();
      rethrow;
    }
  }

  Future<void> removeRecipe(String id) async {
    try {
      _recipes.removeWhere((recipe) => recipe.id == id);
      await _recipeRepository.removeRecipe(id);

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

      await _favoritesRepository.toggleFavorite(_userFavorites!, recipeId);

      if (_userFavorites!.recipeIds.contains(recipeId)) {
        _userFavorites = _userFavorites!.removeRecipe(recipeId);
      } else {
        _userFavorites = _userFavorites!.addRecipe(recipeId);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      await _loadFavorites();
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

      await _mealPlanRepository.saveMealPlan(updatedMealPlan);
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

      await _mealPlanRepository.saveMealPlan(updatedMealPlan);
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
    int? consumedFiber,
    int? targetCalories,
    int? targetProtein,
    int? targetCarbs,
    int? targetFat,
    int? targetFiber,
  }) async {
    try {
      if (_currentUser == null || _userNutrition == null) {
        debugPrint('Cannot update nutrition: No user is logged in');
        return;
      }

      final existingRecord = _userNutrition!.getRecordForDate(date);

      if (targetCalories != null ||
          targetProtein != null ||
          targetCarbs != null ||
          targetFat != null ||
          targetFiber != null) {
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
          fiber:
              targetFiber ??
              existingRecord?.targetFiber ??
              _currentUser!.dailyFiberTarget,
        );

        _userNutrition = updateTargets;
      }

      if (consumedCalories != null ||
          consumedProtein != null ||
          consumedCarbs != null ||
          consumedFat != null ||
          consumedFiber != null) {
        final updateConsumed = _userNutrition!.updateConsumedNutrients(
          date,
          calories: consumedCalories ?? existingRecord?.consumedCalories ?? 0,
          protein: consumedProtein ?? existingRecord?.consumedProtein ?? 0,
          carbs: consumedCarbs ?? existingRecord?.consumedCarbs ?? 0,
          fat: consumedFat ?? existingRecord?.consumedFat ?? 0,
          fiber: consumedFiber ?? existingRecord?.consumedFiber ?? 0,
          targetCalories:
              existingRecord?.targetCalories ??
              _currentUser!.dailyCalorieTarget,
          targetProtein:
              existingRecord?.targetProtein ?? _currentUser!.dailyProteinTarget,
          targetCarbs:
              existingRecord?.targetCarbs ?? _currentUser!.dailyCarbsTarget,
          targetFat: existingRecord?.targetFat ?? _currentUser!.dailyFatTarget,
          targetFiber:
              existingRecord?.targetFiber ?? _currentUser!.dailyFiberTarget,
        );

        _userNutrition = updateConsumed;
      }

      await _nutritionRepository.saveNutrition(_userNutrition!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating nutrition: $e');
      await _loadNutrition();
      rethrow;
    }
  }

  Future<void> updateConsumedNutrients(
    DateTime date, {
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
    required int fiber,
  }) async {
    await updateNutrition(
      date,
      consumedCalories: calories,
      consumedProtein: protein,
      consumedCarbs: carbs,
      consumedFat: fat,
      consumedFiber: fiber,
    );
  }

  List<AppNotification> getUnreadNotifications() {
    return _notificationRepository.getUnreadNotifications(
      _notifications,
      _notificationUser,
    );
  }

  Future<void> addNotification(AppNotification notification) async {
    try {
      _notifications.add(notification);
      await _notificationRepository.addNotification(notification);

      if (_currentUser != null && _notificationUser != null) {
        final updatedNotificationUser = _notificationUser!.addNotification(
          notification.id,
        );
        _notificationUser = updatedNotificationUser;

        await _notificationRepository.updateNotificationUser(
          _notificationUser!,
        );
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

        await _notificationRepository.updateNotificationUser(
          _notificationUser!,
        );
      } else {
        final index = _notifications.indexWhere((notif) => notif.id == id);
        if (index != -1) {
          _notifications[index].isRead = true;
          await _notificationRepository.markNotificationAsRead(id);
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

        await _notificationRepository.updateNotificationUser(
          _notificationUser!,
        );
      } else {
        for (var notification in _notifications) {
          notification.isRead = true;
        }

        await _notificationRepository.markAllNotificationsAsRead(
          _notifications,
        );
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
      await _notificationRepository.removeNotification(id);
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
      await _userRepository.saveUser(user);

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
    return await _userRepository.validateUserCredentials(email, password);
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
      }

      await _processJsonData(jsonData);

      notifyListeners();
    } catch (e) {
      debugPrint('Error importing from JSON: $e');
      _initializeEmptyData();
      rethrow;
    }
  }

  Future<void> _processJsonData(Map<String, dynamic> jsonData) async {
    User? userToImport;
    if (jsonData['user'] != null && jsonData['user'] is Map<String, dynamic>) {
      userToImport = User.fromJson(jsonData['user'] as Map<String, dynamic>);
      await _importUserToFirebase(userToImport);
      _currentUser = userToImport;
    }

    List<Recipe> recipesToImport = [];
    if (jsonData['recipes'] != null) {
      final recipesList = jsonData['recipes'] as List;
      recipesToImport =
          recipesList
              .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
              .toList();
      await _importRecipesToFirebase(recipesToImport);
      _recipes = recipesToImport;
    }

    if (jsonData['mealPlan'] != null &&
        jsonData['mealPlan'] is Map<String, dynamic>) {
      final mealPlanToImport = MealPlan.fromJson(
        jsonData['mealPlan'] as Map<String, dynamic>,
      );
      await _importMealPlanToFirebase(mealPlanToImport);
      _userMealPlan = mealPlanToImport;
    }

    if (jsonData['nutrition'] != null &&
        jsonData['nutrition'] is Map<String, dynamic>) {
      final nutritionToImport = Nutrition.fromJson(
        jsonData['nutrition'] as Map<String, dynamic>,
      );
      await _importNutritionToFirebase(nutritionToImport);
      _userNutrition = nutritionToImport;
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
      await _importNotificationsToFirebase(notificationsToImport);
      _notifications = notificationsToImport;
    }

    if (jsonData['notificationUser'] != null &&
        jsonData['notificationUser'] is Map<String, dynamic>) {
      final notificationUserToImport = NotificationUser.fromJson(
        jsonData['notificationUser'] as Map<String, dynamic>,
      );
      await _importNotificationUserToFirebase(notificationUserToImport);
      _notificationUser = notificationUserToImport;
    }

    if (jsonData['favorites'] != null) {
      Favorites? favoritesToImport;
      if (jsonData['favorites'] is Map<String, dynamic>) {
        favoritesToImport = Favorites.fromJson(
          jsonData['favorites'] as Map<String, dynamic>,
        );
      } else if (jsonData['favorites'] is List &&
          (jsonData['favorites'] as List).isNotEmpty) {
        favoritesToImport = Favorites.fromJson(
          (jsonData['favorites'] as List).first as Map<String, dynamic>,
        );
      }

      if (favoritesToImport != null) {
        await _importFavoritesToFirebase(favoritesToImport);
        _userFavorites = favoritesToImport;
      }
    }
  }

  Future<void> loadDefaultDataFromJson() async {
    if (_jsonFilePath == null) {
      debugPrint('No JSON file path set for default data loading');
      return;
    }

    await _importJsonData(_jsonFilePath!);
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
    final batch = _firestore.batch();

    for (var recipe in recipes) {
      final docRef = _firestore
          .collection(DatabaseConfig.RECIPES_COLLECTION)
          .doc(recipe.id);
      batch.set(docRef, recipe.toJson());
    }

    if (recipes.isNotEmpty) {
      await batch.commit();
    }
  }

  Future<void> _importMealPlanToFirebase(MealPlan mealPlan) async {
    await _firestore
        .collection(DatabaseConfig.MEAL_PLANS_COLLECTION)
        .doc(mealPlan.id)
        .set(mealPlan.toJson());
  }

  Future<void> _importUserToFirebase(User user) async {
    await _firestore
        .collection(DatabaseConfig.USERS_COLLECTION)
        .doc(user.id)
        .set(user.toJson());
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
    final batch = _firestore.batch();

    for (var notification in notifications) {
      final docRef = _firestore
          .collection(DatabaseConfig.NOTIFICATIONS_COLLECTION)
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
        .collection(DatabaseConfig.NOTIFICATION_USERS_COLLECTION)
        .doc(notificationUser.id)
        .set(notificationUser.toJson());
  }

  Future<void> _importFavoritesToFirebase(Favorites favorites) async {
    try {
      await _firestore
          .collection(DatabaseConfig.FAVORITES_COLLECTION)
          .doc(favorites.id)
          .set(favorites.toJson());
    } catch (e) {
      debugPrint('Error importing favorites to Firebase: $e');
      rethrow;
    }
  }

  MealPlan? getMealPlanByDate(DateTime date) {
    return _mealPlanRepository.getMealPlanByDate(_userMealPlan, date);
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
}
