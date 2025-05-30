import 'package:cookmate/frontend/screens/ingredient_screen.dart';
import 'package:flutter/material.dart';
import 'frontend/widgets/bottom_navigation_bar.dart';
import 'frontend/screens/daily_nutrition.dart';
import 'frontend/screens/meal_planning.dart';
import 'frontend/screens/calorie_tracking.dart';
import 'frontend/screens/settings_screen.dart';
import 'backend/services/database_service.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await DatabaseService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cookmate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins',
      ),
      home: const BottomNavBar(),
      routes: {
        '/home': (context) => const DailyNutritionScreen(),
        '/meal-planning': (context) => const MealPlanningScreen(),
        '/calorie-tracking': (context) => const CalorieTrackingPage(),
        '/recipe2': (context) => const RecipeDetailScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/recipe': (context) => const RecipeDetailScreen(),
      },
      initialRoute: '/',
    );
  }
}
