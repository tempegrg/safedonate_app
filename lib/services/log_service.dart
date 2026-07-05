import 'dart:convert';
import 'package:http/http.dart' as http;

class LogService {
  static const String baseUrl = "https://safedonate-backend-production.up.railway.app/api";

  static Future<List<dynamic>> getLogs() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/logs"),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['logs'];
      } else {
        return [];
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
}