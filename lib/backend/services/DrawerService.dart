import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerService {
  Future<Map<String, dynamic>?> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('userId');
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance.collection('User').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }
}
