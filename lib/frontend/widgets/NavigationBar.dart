import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Center(child: Text('Home')),
    Center(child: Text('Saved')),
    Center(child: Text('Add')),
    Center(child: Text('Favorites')),
    Center(child: Text('Profile')),
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
        padding: const EdgeInsets.only(bottom: 50),
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
                child: Transform.scale(
                  scale: 1.4,
                  child: Container(
                    decoration: isSelected
                        ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.27),
                          blurRadius: 3,
                          spreadRadius: -1,
                          offset: const Offset(3, 3),
                        ),
                      ],
                    )
                        : null,
                    child: Icon(
                      _icons[index],
                      color: iconColor,
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
