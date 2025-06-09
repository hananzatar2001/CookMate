import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../backend/services/shopping_list_service.dart';
import '../../frontend/widgets/NavigationBar.dart';
import '../../frontend/widgets/notification_bell.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  late String userId;
  final List<Map<String, dynamic>> items = [];
  final ShoppingListService _shoppingService = ShoppingListService();
  final TextEditingController controller = TextEditingController();

  //لالوان حسي figma
  final List<Color> baseColors = [
    const Color(0xFFF8D558),
    const Color(0xFFCCB1F6),
    const Color(0xFFCDE26D),
  ];
  int colorIndex = 0;

  @override
  void initState() {
    super.initState();
    loadUserIdAndShoppingList();
  }

  Future<void> loadUserIdAndShoppingList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('userId');

      if (storedUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User ID not found. Please log in.")),
        );
        return;
      }

      userId = storedUserId;

      final fetched = await _shoppingService.getShoppingList(userId);
      setState(() {
        items.clear();
        for (var e in fetched) {
          final baseColor = baseColors[colorIndex % baseColors.length];
          //baseColor 0.5 نسبة تشبع اللون
          final displayColor = desaturate(baseColor, 0.5);
          items.add({'name': e, 'checked': false, 'color': displayColor});
          colorIndex++;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load shopping list: $e")),
      );
    }
  }

  Color desaturate(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    final desaturated = hsl.withSaturation(hsl.saturation * factor);
    return desaturated.toColor();
  }

  void toggleItem(int index, bool? value) {
    setState(() {
      items[index]['checked'] = value ?? false;
    });
  }

  void addItem(String itemName) async {
    if (itemName.isEmpty || !_shoppingService.isValidInput(itemName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid item")),
      );
      return;
    }

    final baseColor = baseColors[colorIndex % baseColors.length];
    final displayColor = desaturate(baseColor, 0.5);
    colorIndex++;

    setState(() {
      items.add({'name': itemName, 'checked': false, 'color': displayColor});
    });

    try {
      await _shoppingService.addItem(userId, itemName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add item: $e")),
      );
    }

    controller.clear();
  }

  void removeItem(int index) async {
    final itemName = items[index]['name'];
    setState(() {
      items.removeAt(index);
    });

    try {
      await _shoppingService.removeItem(userId, itemName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to remove item: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Shopping List'),
        centerTitle: true,
        leading: const Icon(Icons.arrow_back_ios),
        actions: [
          //NotificationBell(unreadCount: 5),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HSLColor.fromColor(const Color(0xFFF8FEDA))
                .withSaturation(0.5)
                .toColor(),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: items[index]['color'],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text(
                          items[index]['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        leading: Checkbox(
                          value: items[index]['checked'],
                          onChanged: (val) => toggleItem(index, val),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.cancel_rounded),
                          onPressed: () => removeItem(index),
                        ),
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
                      decoration: const InputDecoration(
                        hintText: 'Add item',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => addItem(controller.text.trim()),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Colors.black,
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 6),
    );
  }
}
