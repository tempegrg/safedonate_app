import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class OrganisationApplicationService {

  static const String baseUrl =
      "https://safedonate-backend-production.up.railway.app/api";

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

      var request = http.MultipartRequest(

        "POST",

        Uri.parse(
          "$baseUrl/organisation-applications",
        ),
      );

      // =========================================
      // TEXT FIELDS
      // =========================================

      request.fields["organisation_name"] = organisationName;

      request.fields["organisation_type"] = organisationType;

      request.fields["registration_number"] = registrationNumber;

      request.fields["description"] = description;

      request.fields["email"] = email;

      request.fields["phone"] = phone;

      request.fields["address"] = address;

      request.fields["website"] = website;

      // =========================================
      // LOGO
      // =========================================

      request.files.add(

        await http.MultipartFile.fromPath(

          "logo",

          logo.path,

        ),
      );

      // =========================================
      // REGISTRATION CERTIFICATE
      // =========================================

      request.files.add(

        await http.MultipartFile.fromPath(

          "certificate",

          certificate.path,

        ),
      );

      // =========================================
      // SUPPORTING DOCUMENT (OPTIONAL)
      // =========================================

      if (supportingDocument != null) {

        request.files.add(

          await http.MultipartFile.fromPath(

            "supporting_document",

            supportingDocument.path,

          ),
        );
      }

      // =========================================
      // SEND REQUEST
      // =========================================

      var response = await request.send();

      var responseBody =
          await response.stream.bytesToString();

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        return jsonDecode(responseBody);
      }

      print(responseBody);

      return null;

    } catch (e) {

      print(e);

      return null;

    }
  }
}