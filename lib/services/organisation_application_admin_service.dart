import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OrganisationApplicationAdminService {
  static const String baseUrl =
      "https://safedonate-backend-production.up.railway.app/api";

  // =========================================
  // GET ALL APPLICATIONS
  // =========================================
  static Future<List> getApplications() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/organisation-applications"),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded["applications"] ?? [];
      }

      return [];
    } catch (e) {
      print("GET APPLICATIONS ERROR: $e");
      return [];
    }
  }

  // =========================================
  // GET SINGLE APPLICATION
  // =========================================
  static Future<Map<String, dynamic>?> getApplication(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/organisation-applications/$id"),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print("GET APPLICATION ERROR: $e");
      return null;
    }
  }

  // =========================================
  // APPROVE
  // =========================================
  static Future<bool> approve(int id) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/organisation-applications/$id/approve"),
        headers: {"Accept": "application/json"},
      );

      return response.statusCode == 200;
    } catch (e) {
      print("APPROVE ERROR: $e");
      return false;
    }
  }

  // =========================================
  // REJECT
  // =========================================
  static Future<bool> reject(
    int id, {
    String? adminRemark,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/organisation-applications/$id/reject"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "admin_remark": adminRemark,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("REJECT ERROR: $e");
      return false;
    }
  }

  // =========================================
  // UPDATE APPLICATION WITH FILES
  // =========================================
  static Future<bool> updateApplication({
    required int id,
    required String organisationName,
    required String organisationType,
    required String registrationNumber,
    required String description,
    required String email,
    required String phone,
    required String address,
    required String website,
    File? logoFile,
    File? certificateFile,
    File? supportingDocumentFile,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/organisation-applications/$id'),
      );

      // Laravel PUT + multipart workaround
      request.fields['_method'] = 'PUT';

      request.fields['organisation_name'] = organisationName;
      request.fields['organisation_type'] = organisationType;
      request.fields['registration_number'] = registrationNumber;
      request.fields['description'] = description;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['address'] = address;
      request.fields['website'] = website;

      if (logoFile != null) {
        request.files.add(
          await _createMultipartFile('logo', logoFile),
        );
      }

      if (certificateFile != null) {
        request.files.add(
          await _createMultipartFile('certificate', certificateFile),
        );
      }

      if (supportingDocumentFile != null) {
        request.files.add(
          await _createMultipartFile('supporting_document', supportingDocumentFile),
        );
      }

      request.headers['Accept'] = 'application/json';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("UPDATE APPLICATION STATUS: ${response.statusCode}");
      print("UPDATE APPLICATION BODY: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("UPDATE APPLICATION ERROR: $e");
      return false;
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
  // DELETE APPLICATION
  // =========================================
  static Future<bool> deleteApplication(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/organisation-applications/$id"),
        headers: {"Accept": "application/json"},
      );

      return response.statusCode == 200;
    } catch (e) {
      print("DELETE APPLICATION ERROR: $e");
      return false;
    }
  }
}