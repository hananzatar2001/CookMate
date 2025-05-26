// import 'package:cookmate/pages/ingredient_screen.dart';
import 'package:flutter/material.dart';
import 'frontend/screens/daily_nutrition.dart';
// import 'pages/meal_planning.dart';
// import 'pages/calorie_tracking.dart';
// import 'pages/favorites_recipes_screen.dart';
// import 'pages/settings_screen.dart';
// import 'pages/notifications_screen.dart';
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
      home: const DailyNutritionScreen(),
    );
  }
}
