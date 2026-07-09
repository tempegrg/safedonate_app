import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrganisationApplicationService {
  static const String baseUrl =
      "https://safedonate-backend-production.up.railway.app/api";

  // =========================================
  // SUBMIT APPLICATION
  // =========================================
  static Future<Map<String, dynamic>?> submitApplication({
    required String organisationName,
    required String organisationType,
    required String registrationNumber,
    required String description,
    required String email,
    required String phone,
    required String address,
    required String website,
    required File logo,
    required File certificate,
    File? supportingDocument,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('user_id');

      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/organisation-applications"),
      );

      request.fields["organisation_name"] = organisationName;
      request.fields["organisation_type"] = organisationType;
      request.fields["registration_number"] = registrationNumber;
      request.fields["description"] = description;
      request.fields["email"] = email;
      request.fields["phone"] = phone;
      request.fields["address"] = address;
      request.fields["website"] = website;

      if (userId != null) {
        request.fields["user_id"] = userId.toString();
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          "logo",
          logo.path,
        ),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          "certificate",
          certificate.path,
        ),
      );

      if (supportingDocument != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "supporting_document",
            supportingDocument.path,
          ),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("APPLICATION SUBMIT STATUS: ${response.statusCode}");
      print("APPLICATION SUBMIT BODY: $responseBody");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(responseBody);
      }

      return null;
    } catch (e) {
      print("submitApplication error: $e");
      return null;
    }
  }

  // =========================================
  // GET CURRENT USER APPLICATION STATUS
  // =========================================
  static Future<Map<String, dynamic>?> getMyApplication() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('user_id');

      print("SAVED USER ID: $userId");

      if (userId == null) {
        print("No user_id found in SharedPreferences");
        return null;
      }

      final response = await http.get(
        Uri.parse("$baseUrl/organisation-applications/user/$userId"),
      );

      print("GET MY APPLICATION STATUS: ${response.statusCode}");
      print("GET MY APPLICATION BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        print("DECODED RESPONSE: $decoded");
        print("DECODED TYPE: ${decoded.runtimeType}");

        if (decoded is Map<String, dynamic>) {
          print("APPLICATION FIELD: ${decoded["application"]}");

          if (decoded["application"] != null) {
            final app =
                Map<String, dynamic>.from(decoded["application"]);
            print("RETURNING APPLICATION MAP: $app");
            return app;
          }
        }
      }

      print("RETURNING NULL FROM getMyApplication()");
      return null;
    } catch (e) {
      print("getMyApplication error: $e");
      return null;
    }
  }
}