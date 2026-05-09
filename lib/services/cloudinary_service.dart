import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  final String cloudName = 'dz8ajd0d4';
  final String uploadPreset = 'cafe_menu_uploads';

  // Untuk Android
  Future<String?> uploadImage(File imageFile) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200) return jsonData['secure_url'];
      return null;
    } catch (e) {
      return null;
    }
  }

  // Untuk Web
  Future<String?> uploadImageWeb(Uint8List imageBytes) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(http.MultipartFile.fromBytes('file', imageBytes,
            filename: 'upload.jpg'));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200) return jsonData['secure_url'];
      return null;
    } catch (e) {
      return null;
    }
  }
}