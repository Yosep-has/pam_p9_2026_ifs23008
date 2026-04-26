import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../services/auth_service.dart';

class MotivationService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  static Future<Map<String, dynamic>> getMotivations(int page) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse("${ApiConstants.motivations}?page=$page&per_page=10"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      throw Exception("Failed to load motivations");
    }
  }

  static Future<void> generateMotivation(String theme, int total) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse(ApiConstants.generate),
      headers: headers,
      body: jsonEncode({"theme": theme, "total": total}),
    );

    if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else if (response.statusCode != 200) {
      throw Exception("Failed to generate");
    }
  }
}
