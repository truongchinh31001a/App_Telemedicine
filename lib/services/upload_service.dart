import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // 👈 thêm cái này
import 'package:path/path.dart';

Future<void> uploadFormImage(String filePath) async {
  final uri = Uri.parse('http://192.168.1.197:3000/api/upload');

  final token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjYsInVzZXJuYW1lIjoic3VwZXJhZG1pbiIsInJvbGUiOiJhZG1pbiIsImlhdCI6MTc0OTc4MDU3MCwiZXhwIjoxNzUwMzg1MzcwfQ.3bCNEI6vx5Oz5eAecc_u1fERpj42NNaVuGKp3d7GfIQ";

  final request = http.MultipartRequest('POST', uri);
  request.headers['Authorization'] = 'Bearer $token';

  request.files.add(
    await http.MultipartFile.fromPath(
      'file',
      filePath,
      filename: basename(filePath), // vẫn cần basename
      contentType: MediaType('image', 'png'), // ✅ thêm dòng này để server hiểu
    ),
  );

  final response = await request.send();
  final respStr = await response.stream.bytesToString();

  if (response.statusCode == 200) {
    print('✅ Upload thành công: $respStr');
  } else {
    print('❌ Upload thất bại (${response.statusCode}): $respStr');
  }
}
