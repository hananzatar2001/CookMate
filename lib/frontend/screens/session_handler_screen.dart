import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'home_page_screen.dart';
import 'splash1_screen.dart'; // شاشة البداية المتحركة

class SessionHandlerScreen extends StatefulWidget {
  const SessionHandlerScreen({super.key});

  @override
  State<SessionHandlerScreen> createState() => _SessionHandlerScreenState();
}

class _SessionHandlerScreenState extends State<SessionHandlerScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 3)); //  خليها بعد سبلاش متحركة
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (!mounted) return;

    if (userId != null && userId.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
