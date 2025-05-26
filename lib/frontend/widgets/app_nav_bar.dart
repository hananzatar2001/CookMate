import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart';

class AppNavBar extends StatelessWidget {
  final int currentIndex;

  const AppNavBar({super.key, required this.currentIndex});

  final List<IconData> _icons = const [
    Icons.home,
    Icons.bookmark_rounded,
    Icons.add_box,
    Icons.favorite,
    Icons.person,
    Icons.logo_dev,
  ];

  static const Color iconColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 33),
        height: 70,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_icons.length, (index) {
            final bool isSelected = currentIndex == index;

            return GestureDetector(
              onTap: () {
                if (index != currentIndex) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BottomNavBar(initialIndex: index),
                    ),
                  );
                }
              },
              child: Transform.scale(
                scale: 1.4,
                child: Container(
                  decoration:
                      isSelected
                          ? BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.27),
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
            );
          }),
        ),
      ),
    );
  }
}
