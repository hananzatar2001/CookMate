/*
import 'package:flutter/material.dart';
import '../widgets/nutrient_bar.dart';
import '../widgets/meal_card.dart';

class CalorieTrackingScreen extends StatelessWidget {
  const CalorieTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios),
        title: const Text('Calorie Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.notifications_none))],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // 🔥 Calorie Progress Circle (Dummy placeholder)
          const Text(
            '1721 Kcal',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const Text('of 2213 kcal', style: TextStyle(color: Colors.grey)),

          const SizedBox(height: 16),

          // 💪 Nutrient Bars
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NutrientBar(label: 'Protein', value: 78, target: 90, color: Colors.green),
                NutrientBar(label: 'Fats', value: 45, target: 70, color: Colors.red),
                NutrientBar(label: 'Carbs', value: 95, target: 110, color: Colors.orange),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🍽️ Meal Type Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Chip(label: Text('Breakfast')),
                Chip(label: Text('Lunch')),
                Chip(label: Text('Dinner')),
                Chip(label: Text('Snacks')),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🥗 List of Meals
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                MealCard(),
                MealCard(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }
}
*/
//******************************************
/*
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart'; // أضف في pubspec.yaml
import 'package:firebase_auth/firebase_auth.dart';
import '../../backend/services/CalorieLogService.dart';

class CalorieTrackingScreen extends StatefulWidget {
  const CalorieTrackingScreen({super.key});

  @override
  State<CalorieTrackingScreen> createState() => _CalorieTrackingScreenState();
}

class _CalorieTrackingScreenState extends State<CalorieTrackingScreen> {
  final _logService = MockCalorieLogService();
  late String userId;

  double totalCaloriesTaken = 0;
  double userCaloriesGoal = 2200; // يمكنك لاحقًا جلبها من userCaloriesNeeded

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    userId = currentUser?.uid ?? 'demo_user';
    loadCalories();
  }

  Future<void> loadCalories() async {
    final logs = await _logService.getLogsByUser(userId);
    double total = 0;
    for (var doc in logs.docs) {
      total += (doc['Calories taken'] ?? 0) as num;
    }

    setState(() {
      totalCaloriesTaken = total;
    });
  }

  Color getProgressColor(double percent) {
    if (percent < 0.5) return Colors.green;
    if (percent < 0.8) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final percent = (totalCaloriesTaken / userCaloriesGoal).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Tracking'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),

          // ✅ نصف الدائرة مع السعرات
          CircularPercentIndicator(
            radius: 100,
            lineWidth: 20,
            percent: percent,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: getProgressColor(percent),
            backgroundColor: Colors.grey.shade200,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
                Text(
                  '${totalCaloriesTaken.toInt()} Kcal',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'of ${userCaloriesGoal.toInt()} kcal',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          // يمكنك إضافة NutrientBar و MealCard هنا لاحقًا.
        ],
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../backend/services/CalorieLogService.dart'; // تأكد من استيراد النسخة التجريبية المناسبة
import '../widgets/nutrient_bar.dart';
import '../widgets/meal_card.dart';
import '../../frontend/widgets/NavigationBar.dart';


class CalorieTrackingScreen extends StatefulWidget {
  const CalorieTrackingScreen({super.key});

  @override
  State<CalorieTrackingScreen> createState() => _CalorieTrackingScreenState();
}

class _CalorieTrackingScreenState extends State<CalorieTrackingScreen> {
  final _logService = MockCalorieLogService();
  late String userId;

  double totalCaloriesTaken = 0;
  double userCaloriesGoal = 2200; // يمكن استبدالها لاحقاً بقيمة مخصصة

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    userId = currentUser?.uid ?? 'demo_user';
    loadCalories();
  }

  Future<void> loadCalories() async {
    final logs = await _logService.getLogsByUser(userId);
    double total = 0;
    for (var doc in logs.docs) {
      total += (doc['Calories taken'] ?? 0) as num;
    }

    setState(() {
      totalCaloriesTaken = total;
    });
  }

  Color getProgressColor(double percent) {
    if (percent < 0.5) return Colors.green;
    if (percent < 0.8) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final percent = (totalCaloriesTaken / userCaloriesGoal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios),
        title: const Text('Calorie Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // 🔥 Circular Calorie Progress Indicator (Dynamic)
          CircularPercentIndicator(
            radius: 100,
            lineWidth: 20,
            percent: percent,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: getProgressColor(percent),
            backgroundColor: Colors.grey.shade200,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
                Text(
                  '${totalCaloriesTaken.toInt()} Kcal',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'of ${userCaloriesGoal.toInt()} kcal',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 💪 Nutrient Bars
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NutrientBar(label: 'Protein', value: 78, target: 90, color: Colors.green),
                NutrientBar(label: 'Fats', value: 45, target: 70, color: Colors.red),
                NutrientBar(label: 'Carbs', value: 95, target: 110, color: Colors.orange),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🍽️ Meal Type Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Chip(label: Text('Breakfast')),
                Chip(label: Text('Lunch')),
                Chip(label: Text('Dinner')),
                Chip(label: Text('Snacks')),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🥗 List of Meals
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                MealCard(),
                MealCard(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 7),
    );
  }
}

