import 'dart:convert';
import 'package:http/http.dart' as http;

class OrganisationService {
  // =========================================
  // BASE URL
  // =========================================
  static const String baseUrl =
      "https://safedonate-backend-production.up.railway.app/api/organisations";

  // =========================================
  // GET ALL ORGANISATIONS
  // =========================================
  static Future<List<dynamic>> getOrganisations() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['organisations'] ?? [];
      }

      print("GET ORGANISATIONS FAILED: ${response.statusCode}");
      print(response.body);
      return [];
    } catch (e) {
      print("GET ERROR: $e");
      return [];
    }
  }

  // =========================================
  // ADD ORGANISATION
  // =========================================
  static Future<bool> addOrganisation({
    required String name,
    required String registrationNo,
    required String website,
    required String category,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "registration_no": registrationNo,
          "website": website,
          "category": category,
        }),
      );

      return response.statusCode == 200 ||
          response.statusCode == 201;
    } catch (e) {
      print("ADD ERROR: $e");
      return false;
    }
  }

  // =========================================
  // DELETE ORGANISATION
  // =========================================
  static Future<bool> deleteOrganisation(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: {
          "Accept": "application/json",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("DELETE ERROR: $e");
      return false;
    }
  }
}