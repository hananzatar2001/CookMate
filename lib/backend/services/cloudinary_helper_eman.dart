import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
class CloudinaryHelperEman {
  static const _cloudName = 'dx20va0rd';
  static const _uploadPreset = 'profile_pictures_upload';

  static Future<String?> upload(File file) async {
    try {
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$_cloudName/image/upload");

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        final data = json.decode(resStr);
        return data['secure_url'];
      } else {
        print(' Cloudinary upload failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print(' Upload error: $e');
      return null;
    }
  }
}
