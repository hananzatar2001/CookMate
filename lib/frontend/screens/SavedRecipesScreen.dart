import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../widgets/NavigationBar.dart';


class SavedRecipesScreen extends StatelessWidget {
  const SavedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Here are your saved recipes.'),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}

