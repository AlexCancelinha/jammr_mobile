import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ScanService {
  static const String baseUrl = 'http://10.0.2.2:8080/api'; // Android emulator fix

  static Future<List<UserModel>> fetchUsers() async {
    final uri = Uri.parse('$baseUrl/users');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => UserModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }
}
