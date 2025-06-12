import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiBaseUrl = 'http://192.168.1.197:3050';
const String livekitHost = 'wss://tele-oovrxt5d.livekit.cloud';

Future<String?> fetchLivekitToken(String room, String name) async {
  final response = await http.get(
    Uri.parse('$apiBaseUrl/api/token?room=$room&username=$name'),
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return json['token'];
  } else {
    print('Token fetch failed: ${response.body}');
    return null;
  }
}
