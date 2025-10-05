import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendService {
  static const String baseUrl = "http://10.0.2.2:8080/api"; // Android emulator

  static Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response = await http.get(Uri.parse("$baseUrl/users"));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Failed to load users");
    }
  }

  static Future<void> startSession(int userId, String song) async {
    final response = await http.post(
      Uri.parse("$baseUrl/sessions/start?userId=$userId&song=$song"),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to start session");
    }
  }
}