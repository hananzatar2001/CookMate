import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/splash1_screen.dart';
import '../screens/user_profile_screen.dart';
import '../screens/saved_recipess_screen.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<IconData> icons = [
      Icons.home,
      Icons.bookmark_rounded,
      Icons.add_box,
      Icons.favorite,
      Icons.person,
    ];

    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 33),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(icons.length, (index) {
              final bool isSelected = widget.currentIndex == index;

              return GestureDetector(
                onTap: () {
                  if (widget.currentIndex != index) {
                    switch (index) {

                      case 1:
                        if (userId.isNotEmpty) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SavedRecipesScreen(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("User ID not found")),
                          );
                        }
                        break;
                      case 4:
                        if (userId.isNotEmpty) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfilePage(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("User ID not found")),
                          );
                        }
                        break;

                    // باقي الحالات يمكن إضافتها هنا لاحقًا
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Transform.scale(
                    scale: 1.5,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.27),
                            blurRadius: 3,
                            spreadRadius: -1,
                            offset: const Offset(3, 3),
                          ),
                        ]
                            : [],
                      ),
                      child: Icon(
                        icons[index],
                        color: const Color(0xFF333333),
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
