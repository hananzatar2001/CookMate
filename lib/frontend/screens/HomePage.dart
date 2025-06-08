import 'package:flutter/material.dart';
import '../../frontend/widgets/hamburger_menu.dart';
import '../../frontend/widgets/NavigationBar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      drawer: const CustomDrawer(), // هذا مكان إدخال الويدجيت
      body: const Center(
        child: Text('Welcome to the Home Page!'),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),

    );

  }
}