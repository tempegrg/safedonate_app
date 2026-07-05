import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "https://safedonate-backend-production.up.railway.app/api";

  // 🔐 LOGIN
  static Future<Map<String, dynamic>?> login(
      String email,
      String password,
  ) async {

    print("AUTH 1 - Login started");

    try {

      final response = await http.post(

        Uri.parse("$baseUrl/login"),

        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },

        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      print("AUTH 2 - Response received");
      print("Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {

        final data =
            jsonDecode(response.body);

        print("AUTH 3 - JSON decoded");

        // SAVE SESSION
        final prefs =
            await SharedPreferences.getInstance();

        print("AUTH 4 - SharedPreferences loaded");

        await prefs.setBool(
          'isLoggedIn',
          true,
        );

        print("AUTH 5 - Login status saved");

        await prefs.setString(
          'name',
          data['user']['name'],
        );

        print("AUTH 6 - Name saved");

        await prefs.setString(
          'email',
          data['user']['email'],
        );

        print("AUTH 7 - Email saved");

        await prefs.setString(
          'role',
          data['user']['role'],
        );

        print("AUTH 8 - Role saved");

        return data;

      } else {

        print("AUTH FAILED");
        print(response.body);

        return null;
      }

    } catch (e) {

      print("AUTH ERROR");
      print(e);

      return null;
    }
  }
  // 📝 REGISTER
  static Future<Map<String, dynamic>?> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print("Register failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Register error: $e");
      return null;
    }
  }

    static Future<void> logout() async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.clear();
  }
}