import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordService {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<String?> sendResetLink({required String email}) async {
    try {

      final userQuery = await firestore
          .collection('User')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isEmpty) {
        return '❗ هذا الإيميل غير مسجل في النظام';
      }

      // ✅ 2. توليد resetToken (كود عشوائي)
      final resetToken = DateTime.now().millisecondsSinceEpoch.toString();

      // ✅ 3. تحديث Firestore بالـ token و تاريخ الانتهاء
      final userDocId = userQuery.docs.first.id;

      await firestore.collection('User').doc(userDocId).update({
        'resetToken': resetToken,
        'resetTokenExpiry': DateTime.now().add(Duration(minutes: 30)).toIso8601String(),
      });

      // ✅ 4. إرسال إيميل يدوي عبر SendGrid
      final response = await http.post(
        Uri.parse('https://api.sendgrid.com/v3/mail/send'),
        headers: {
          'Authorization': 'Bearer YOUR_SENDGRID_API_KEY', // 🔴 بدله بالـ API Key الحقيقي
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personalizations': [
            {
              'to': [{'email': email}],
              'subject': 'Reset your CookMate password',
            }
          ],
          'from': {'email': 'noreply@cookmate.com'},  // ✅ لازم يكون Verified Sender
          'content': [
            {
              'type': 'text/plain',
              'value':
              'Hello,\n\nClick the link below to reset your password:\n\nhttps://cookmate.com/reset-password?token=$resetToken\n\nThis link expires in 30 minutes.\n\nBest,\nCookMate Team'
            }
          ],
        }),
      );

      if (response.statusCode != 202) {
        print(' SendGrid Error: ${response.body}');
        return 'Failed to send the password reset link.';
      }

      print('The password reset link has been sent to $email');
      return null;  // success

    } catch (e) {
      print('Error while sending the password reset link: $e');
      return 'An unexpected error occurred. Please try again..';
    }
  }
}
//hs
