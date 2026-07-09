import 'dart:convert';
import 'package:http/http.dart' as http;

class VerificationService {
  static const String baseUrl =
      "https://safedonate-backend-production.up.railway.app/api";

  // =========================================
  // VERIFY LINK
  // =========================================
  static Future<Map<String, dynamic>?> verify(String website) async {
    try {
      // Resolve dynamic / redirected QR links first
      final String finalWebsite =
          await resolveFinalUrl(website);

      print("FINAL URL TO VERIFY: $finalWebsite");

      final response = await http.post(
        Uri.parse("$baseUrl/verify-link"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "website": finalWebsite,
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
      print("Verification error: $e");
      return null;
    }
  }

  // =========================================
  // RESOLVE FINAL URL FROM QR / REDIRECT LINK
  // =========================================
  static Future<String> resolveFinalUrl(String website) async {
    try {
      final Uri uri = Uri.parse(website.trim());

      final response = await http.get(
        uri,
        headers: {
          "User-Agent": "Mozilla/5.0",
        },
      );

      // If request ends up at a redirected/final URL,
      // use that final URL
      final String finalUrl =
          response.request?.url.toString() ?? website.trim();

      print("Resolved URL: $finalUrl");

      return finalUrl;
    } catch (e) {
      print("Resolve URL error: $e");

      // fallback to original scanned URL
      return website.trim();
    }
  }
}