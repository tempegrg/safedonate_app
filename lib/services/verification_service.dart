import 'dart:convert';
import 'package:http/http.dart' as http;

class VerificationService {
  static const String baseUrl = "https://safedonate-backend-production.up.railway.app/api";

  static Future<Map<String, dynamic>?> verify(String website) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/verify-link"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "website": website,
        }),
      );

      print("VERIFY LINK RESPONSE:");
      print(response.body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}