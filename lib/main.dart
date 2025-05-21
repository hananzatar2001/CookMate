import 'package:flutter/material.dart';
//import 'frontend/screens/calorie_tracking_screen.dart';
import 'frontend/screens/add_ingredients_screen.dart';
//import 'frontend/screens/shopping_list_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'frontend/screens/upload_recipe_screen.dart';
//import 'frontend/widgets/hamburger_menu.dart';
//import 'frontend/screens/DrawerExampleScreen.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CookMateApp());
}



class CookMateApp extends StatelessWidget {
  const CookMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CookMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        useMaterial3: true,
      ),
      //drawer
      home: const UploadRecipeScreen(),
    );
  }
}