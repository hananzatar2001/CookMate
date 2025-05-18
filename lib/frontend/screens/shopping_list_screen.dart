import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../backend/services/shopping_list_service.dart';
import 'package:cook_mate/frontend/widgets/NavigationBar.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final List<Map<String, dynamic>> items = [];
  final ShoppingListService _shoppingService = ShoppingListService();
  final TextEditingController controller = TextEditingController();
  late String userId;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    userId = currentUser?.uid ?? 'demo_user'; // Replace with real user check
    if (currentUser != null) {
      userId = currentUser.uid;
    } else {
      // Redirect to login or show error
      // Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    loadShoppingList();
  }

  void loadShoppingList() async {
    final fetched = await _shoppingService.getShoppingList(userId);
    setState(() {
      items.clear();
      items.addAll(fetched.map((e) => {'name': e, 'checked': false}));
    });
  }

  void toggleItem(int index, bool? value) {
    setState(() {
      items[index]['checked'] = value ?? false;
    });
  }

  void addItem(String itemName) async {
    if (itemName.isEmpty) return;
    setState(() {
      items.add({'name': itemName, 'checked': false});
    });
    await _shoppingService.addItem(userId, itemName);
    controller.clear();
  }

  void removeItem(int index) async {
    final itemName = items[index]['name'];
    setState(() {
      items.removeAt(index);
    });
    await _shoppingService.removeItem(userId, itemName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        centerTitle: true,
        leading: const Icon(Icons.arrow_back_ios),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(items[index]['name']),
                    leading: Checkbox(
                      value: items[index]['checked'],
                      onChanged: (val) => toggleItem(index, val),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.cancel_rounded),
                      onPressed: () => removeItem(index),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Add item'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => addItem(controller.text.trim()),
                )
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),

      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 6),
    );
  }
}
