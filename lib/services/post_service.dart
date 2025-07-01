import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';

class PostService {
  static const String baseUrl =
      'http://localhost:4000/api/requests'; // Android emulator base URL
  static Future<List<Post>> fetchFeed(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/feed'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      print(data);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      print('Token: $token');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      throw Exception('Failed to fetch feed: ${response.statusCode}');
    }
  }

  static Future<void> acceptRequest(int requestId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final response = await http.post(
      Uri.parse('$baseUrl/accept/$requestId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to accept request: ${response.body}');
    }
  }

  static Future<void> confirmAcceptance(int requestId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final response = await http.post(
      Uri.parse('$baseUrl/confirm/$requestId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to confirm acceptance: ${response.body}');
    }
  }
}
