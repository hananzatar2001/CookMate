class DatabaseConfig {
  static const String DB_SUFFIX = "_db";

  static const String USERS_COLLECTION = "users$DB_SUFFIX";
  static const String RECIPES_COLLECTION = "recipes$DB_SUFFIX";
  static const String MEAL_PLANS_COLLECTION = "mealPlans$DB_SUFFIX";
  static const String NUTRITION_COLLECTION = "nutrition$DB_SUFFIX";
  static const String NOTIFICATIONS_COLLECTION = "notifications$DB_SUFFIX";
  static const String NOTIFICATION_USERS_COLLECTION =
      "notificationUsers$DB_SUFFIX";
  static const String FAVORITES_COLLECTION = "favorites$DB_SUFFIX";

  static const String DEFAULT_DATA_PATH = 'assets/data/app_data.json';

  static const int FIREBASE_INIT_TIMEOUT_MS = 30000;

  static const bool FALLBACK_TO_JSON = true;

  static const bool INITIALIZE_FROM_JSON = true;

  DatabaseConfig._();
}
