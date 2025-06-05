import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../backend/services/profile_service.dart';
import '../widgets/recipe_grid_view.dart';
import '../widgets/NavigationBar.dart';
import '../screens/edit_profile_dialog.dart';
//import '../screens/Settingscreen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final profileService = ProfileRecipeService();
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  void _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: profileService.getUserProfileStream(userId),
          builder: (context, snapshot) {
            final data = snapshot.data?.data() ?? {};
            final name = data['name']?.toString() ?? 'No Name';



            return Text(
              name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 9.0),
            child: IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.black,
                size: 37,
              ),
              onPressed: () {}
              /*  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );*/
             // },

            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 66.67,
                      height: 66.67,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black),
                      ),
                      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: profileService.getUserProfileStream(userId),
                        builder: (context, snapshot) {
                          final profilePic = snapshot.data?.data()?['profile_picture'];
                          if (profilePic != null && profilePic != '') {
                            return ClipOval(
                              child: Image.network(
                                profilePic,
                                fit: BoxFit.cover,
                                width: 66.67,
                                height: 66.67,
                              ),
                            );
                          } else {
                            return const Icon(Icons.person_outline, size: 36);
                          }
                        },
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Icon(Icons.add, size: 20),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('0', 'Recipes'),
                      _buildStatColumn('0', 'Saved'),
                      _buildStatColumn('0', 'Favorite'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: profileService.getUserProfileStream(userId),
            builder: (context, snapshot) {
              final data = snapshot.data?.data();
              final bio = data?['Bio']?.trim() ?? '';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        bio.isNotEmpty ? bio : 'Add Bio',
                        style: TextStyle(
                          color: bio.isNotEmpty ? Colors.black : Colors.grey,
                          fontSize: bio.isNotEmpty ? 30 : 20,
                          fontWeight: bio.isNotEmpty ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => EditProfileDialog(
                            currentBio: bio,
                            userId: userId,
                            onSave: (userId, newBio) async {
                              await profileService.updateUserBio(userId, newBio);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const TabBarSection(),
          RecipeGridView(userId: userId),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class TabBarSection extends StatefulWidget {
  const TabBarSection({Key? key}) : super(key: key);

  @override
  State<TabBarSection> createState() => _TabBarSectionState();
}

class _TabBarSectionState extends State<TabBarSection> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildTab('Recipes', 0),
            _buildTab('Collections', 1),
          ],
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.black54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 24,
                ),
              ),
            ),
            Container(
              height: 6,
              color: isSelected ? Colors.black : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
