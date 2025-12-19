import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_measurement.dart';
import '../models/recommendation_result.dart';
import '../models/user_model.dart';
import '../models/history_item.dart';

class ApiService {
  // Use 127.0.0.1 for Windows/Web testing. 
  // Use 10.0.2.2 ONLY for Android Emulator.
  static const String baseUrl = 'https://fitablev2.onrender.com';
  // static const String baseUrl = 'http://127.0.0.1:8000';

  Future<User> getUserProfile(String token) async {
    final url = Uri.parse('$baseUrl/auth/me');
    try {
      final response = await http.get(
        url,
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);
         // Inject the access token back into the user object as /me usually doesn't return it
        return User(
            id: user.id,
            email: user.email,
            gender: user.gender,
            username: user.username,
            fullName: user.fullName,
            accessToken: token
        );
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMeasurements(String userId, UserMeasurement measurements) async {
    final url = Uri.parse('$baseUrl/update-measurements'); 
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          ...measurements.toJson(),
        }),
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode != 200) {
        throw Exception('Failed to update measurements: ${response.body}');
      }
    } catch (e) {
      // debugPrint("Error updating measurements: $e");
      rethrow;
    }
  }

  Future<RecommendationResult> getRecommendation(String userId, String productUrl) async {
    final url = Uri.parse('$baseUrl/recommendation/recommend');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'url': productUrl,
        }),
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RecommendationResult.fromJson(data);
      } else {
        throw Exception('Failed to get recommendation: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Login failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User> register(String email, String password, String username, String fullName, String gender, int age) async {
    final url = Uri.parse('$baseUrl/auth/signup');
    debugPrint("DEBUG: ApiService Register calling with Gender: '$gender'");
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': username,
          'full_name': fullName,
          'gender': gender,
          'age': age,
        }),
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // If auto-login successful, we expect 'access_token' and 'user'
        if (data['access_token'] != null && data['user'] != null) {
          return User.fromJson(data);
        } else {
             if (data['user'] != null) {
                 return User(
                   id: data['user']['id'], 
                   email: data['user']['email'],
                   gender: 'unknown' // Fallback
                 );
             }
             throw Exception('Registration succeeded but auto-login failed.');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Registration failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserMeasurement?> getMeasurements(String userId) async {
    final url = Uri.parse('$baseUrl/measurements/$userId');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data'];
        if (data == null) return null;
        
        return UserMeasurement.fromJson(data);
      } else {
        throw Exception('Failed to load measurements');
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<HistoryItem>> getHistory(String userId) async {
    final url = Uri.parse('$baseUrl/history/$userId');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // ignore: unnecessary_cast
        final List<dynamic> data = jsonResponse['data'] as List<dynamic>;
        return data.map((item) => HistoryItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      return [];
    }
  }

  Future<void> addToCloset(RecommendationResult result, String userId, String productUrl) async {
    final url = Uri.parse('$baseUrl/history/add'); 
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'product_name': result.productName,
          'brand': result.brand,
          'product_url': productUrl,
          'image_url': result.imageUrl,
          'price': '', 
          'recommended_size': result.recommendedSize,
          'confidence_score': result.confidenceScore,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to add to closet: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteHistoryItem(String itemId) async {
    final url = Uri.parse('$baseUrl/history/$itemId');
    try {
      final response = await http.delete(url).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete item: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount(String userId) async {
    final url = Uri.parse('$baseUrl/auth/delete/$userId');
    try {
      final response = await http.delete(url).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete account: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
