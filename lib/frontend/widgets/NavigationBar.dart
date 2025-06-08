import 'package:cookmate/backend/services/favorite_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../frontend/screens/upload_recipe_screen.dart';
import '../../frontend/screens/user_profile_screen.dart';
import '../../frontend/screens/saved_recipess_screen.dart';
import '../../frontend/screens/HomePage.dart';
import '../../frontend/screens/favorites_recipes_screen.dart';
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
                      case 0:
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomePage()),
                        );
                        break;
                      case 1:
                        if (userId.isNotEmpty) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>  SavedRecipesScreen(userId: userId),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("User ID not found")),
                          );
                        }
                        break;
                      case 2:
                        if (userId.isNotEmpty) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>  UploadRecipeScreen(),
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
                      case 5:
                        if (userId.isNotEmpty) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FavoritesRecipesScreen(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("User ID not found")),
                          );
                        }
                        break;

                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Transform.scale(
                    scale: 1.5,
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
