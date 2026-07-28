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

      final request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/organisation-applications"),
      );

      request.headers["Accept"] = "application/json";

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
        await _createMultipartFile("logo", logo),
      );

      request.files.add(
        await _createMultipartFile("certificate", certificate),
      );

      if (supportingDocument != null) {
        request.files.add(
          await _createMultipartFile("supporting_document", supportingDocument),
        );
      }

      print("========== SUBMIT APPLICATION ==========");
      print("POST URL : ${request.url}");
      print("FIELDS   : ${request.fields}");
      print("HEADERS  : ${request.headers}");
      print("LOGO     : ${logo.path}");
      print("CERT     : ${certificate.path}");
      print("SUPPORT  : ${supportingDocument?.path}");

      final streamedResponse = await request.send();

      print("STATUS CODE : ${streamedResponse.statusCode}");
      print("RESPONSE HEADERS : ${streamedResponse.headers}");

      final responseBody =
          await streamedResponse.stream.bytesToString();

      print("RESPONSE BODY:");
      print(responseBody);

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        return jsonDecode(responseBody);
      } else if (streamedResponse.statusCode == 422) {
        final decoded = jsonDecode(responseBody);
        return {
          "error": true,
          "message": decoded["message"] ?? "Validation failed"
        };
      }

      return null;
    } catch (e) {
      print("SUBMIT APPLICATION ERROR:");
      print(e);
      return null;
    }
  }

  static Future<http.MultipartFile> _createMultipartFile(
      String field, File file) async {
    try {
      return await http.MultipartFile.fromPath(field, file.path);
    } catch (e) {
      final response = await http.get(Uri.parse(file.path));
      String filename = file.path.split('/').last;
      if (!filename.contains('.')) {
        filename = '$filename.png';
      }
      return http.MultipartFile.fromBytes(
        field,
        response.bodyBytes,
        filename: filename,
      );
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

        if (decoded is Map<String, dynamic> &&
            decoded["application"] != null) {
          return Map<String, dynamic>.from(
            decoded["application"],
          );
        }
      }

      return null;
    } catch (e) {
      print("getMyApplication error: $e");
      return null;
    }
  }
}