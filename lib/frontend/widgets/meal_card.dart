import 'package:flutter/material.dart';

class MealCard extends StatelessWidget {
  const MealCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: AssetImage('assets/images/meal.png'), // يمكنك تغييرها لاحقاً
        ),
        title: const Text('Grilled Chicken Salad'),
        subtitle: const Text('450 kcal'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {},
        ),
      ),
    );
  }
}
