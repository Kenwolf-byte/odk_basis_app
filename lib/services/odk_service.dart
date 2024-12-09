import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> authenticate(
    String serverUrl, String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$serverUrl/v1/sessions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception('Failed to authenticate: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

Future<List> fetchProjectsFromODK(String serverUrl, String token) async {
  try {
    final response = await http.get(
      Uri.parse('$serverUrl/v1/projects'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load projects: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

Future<List> fetchFormsFromODK(
    String serverUrl, String token, int projectId) async {
  try {
    final response = await http.get(
      Uri.parse('$serverUrl/v1/projects/$projectId/forms'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load forms: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}
