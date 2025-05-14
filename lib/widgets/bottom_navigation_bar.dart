import 'package:flutter/material.dart';
import '../pages/daily_nutrition.dart';
import '../pages/discovery_recipes.dart';
import '../pages/meal_planning.dart';
import '../pages/calorie_tracking.dart';
import '../pages/favorites_recipes_screen.dart';
import '../pages/settings_screen.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;

  const BottomNavBar({super.key, this.initialIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _pages = const [
    DailyNutritionScreen(),
    MealPlanningScreen(),
    Scaffold(),
    FavoritesRecipesScreen(),
    SettingsScreen(),
  ];

  final List<IconData> _icons = const [
    Icons.home,
    Icons.bookmark_rounded,
    Icons.add_box,
    Icons.favorite,
    Icons.person,
  ];

  static const Color iconColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 33),
          height: 70,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_icons.length, (index) {
              final bool isSelected = _currentIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                child: Container(
                  width: 48,
                  height: 48,
                  color: Colors.transparent,
                  child: Center(
                    child: Transform.scale(
                      scale: 1.4,
                      child: Container(
                        decoration:
                            isSelected
                                ? BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.27,
                                      ),
                                      blurRadius: 3,
                                      spreadRadius: -1,
                                      offset: const Offset(3, 3),
                                    ),
                                  ],
                                )
                                : null,
                        child: Icon(_icons[index], color: iconColor),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
