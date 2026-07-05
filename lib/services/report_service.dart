import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportService {

  static const String baseUrl =
      "https://safedonate-backend-production.up.railway.app/api";

  // =========================================
  // GET REPORT DATA
  // =========================================

  static Future<Map<String, dynamic>?>
      getReports() async {

    try {

      final response = await http.get(

        Uri.parse(
          "$baseUrl/reports",
        ),

        headers: {
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {

        return jsonDecode(
          response.body,
        );
      }

      return null;

    } catch (e) {

      print(
        "Report Error: $e",
      );

      return null;
    }
  }
}