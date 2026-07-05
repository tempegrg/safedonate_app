import 'dart:convert';
import 'package:http/http.dart' as http;

class OrganisationApplicationAdminService {
  static const String baseUrl =
      "https://safedonate-backend-production.up.railway.app/api";

  // =========================================
  // GET ALL APPLICATIONS
  // =========================================

  static Future<List> getApplications() async {
    final response = await http.get(
      Uri.parse("$baseUrl/organisation-applications"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["applications"];
    }

    return [];
  }

  // =========================================
  // GET SINGLE APPLICATION
  // =========================================

  static Future<Map<String, dynamic>?> getApplication(
      int id) async {

    final response = await http.get(
      Uri.parse(
        "$baseUrl/organisation-applications/$id",
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  // =========================================
  // APPROVE
  // =========================================

  static Future<bool> approve(int id) async {
    final response = await http.put(
      Uri.parse(
        "$baseUrl/organisation-applications/$id/approve",
      ),
    );

    return response.statusCode == 200;
  }

  // =========================================
  // REJECT
  // =========================================

  static Future<bool> reject(int id) async {
    final response = await http.put(
      Uri.parse(
        "$baseUrl/organisation-applications/$id/reject",
      ),
    );

    return response.statusCode == 200;
  }
}