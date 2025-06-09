import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookmate/frontend/screens/home_page_screen.dart';
import 'login_screen.dart';
import 'splash2_screen.dart'; // شاشة الاقتباس

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hideCTA = false;

  @override
  void initState() {
    super.initState();
    _checkSession(); //  تحقق من الجلسة عند التشغيل
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null && mounted) {
      //  إذا في userId → روح عالهوم
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
    //  إذا ما في userId → يكمّل splash عادي (بدون توجيه)
  }

  void _showQuoteOverlay() {
    setState(() {
      _hideCTA = true;
    });

    Navigator.of(context)
        .push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => const CookingQuoteScreen(),
      ),
    )
        .then((_) {
      setState(() {
        _hideCTA = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'cookmate',
                    style: TextStyle(fontSize: 40, color: Colors.black),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Personalized recipes, smart\nmeal planning, and nutrition\ntracking - all in one app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Image.asset(
                    'assets/cookmate_logo.jpeg',
                    height: 375,
                  ),
                  const SizedBox(height: 20),
                  if (!_hideCTA)
                    SizedBox(
                      width: 209,
                      height: 39,
                      child: ElevatedButton(
                        onPressed: _showQuoteOverlay,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0x99CDE26D),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        child: const Text(
                          'Call-to-Action',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
