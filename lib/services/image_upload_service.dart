import 'dart:io';
import 'package:http/http.dart' as http;

class ImageUploadService {
  static const String uploadUrl = 'http://your-api.com/upload'; // thay bằng URL thật

  static Future<bool> uploadImage(File file) async {
    try {
      final uri = Uri.parse(uploadUrl);
      final request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath('image', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        // Hoặc bạn có thể đọc thêm nội dung từ response.stream
        return true;
      } else {
        print('❌ Upload thất bại: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Lỗi khi upload ảnh: $e');
      return false;
    }
  }
}
