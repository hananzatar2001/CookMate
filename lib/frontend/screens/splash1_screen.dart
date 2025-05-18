import 'package:flutter/material.dart';
import 'splash2_screen.dart';
import '../widgets/NavigationBar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hideCTA = false;

  void _showQuoteOverlay() {
    setState(() {
      _hideCTA = true;
    });

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => const CookingQuoteScreen(),
      ),
    ).then((_) {
      // لما يرجع من صفحة الاقتباس
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 45),
                const Text(
                  'cookmate',
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.black,
                  ),
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
                const SizedBox(height: 95),


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
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 0),


    );
  }
}
//b