import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_measurement.dart';
import '../models/recommendation_result.dart';
import '../models/user_model.dart';
import '../models/history_item.dart';

class ApiService {
  // Use 127.0.0.1 for Windows/Web testing. 
  // Use 10.0.2.2 ONLY for Android Emulator.
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<void> updateMeasurements(String userId, UserMeasurement measurements) async {
    final url = Uri.parse('$baseUrl/update-measurements'); // Endpoint needs to facilitate this
    // For now we assume this endpoint exists or we mock it.
    // Ideally, we'd interact with Supabase directly if backend doesn't proxy, 
    // but requirements said "POST /update-measurements".
    
    // NOTE: Backend hasn't implemented /update-measurements yet, 
    // but we build the client side as requested.
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          ...measurements.toJson(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update measurements: ${response.body}');
      }
    } catch (e) {
      print("Error updating measurements: $e");
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
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RecommendationResult.fromJson(data);
      } else {
        throw Exception('Failed to get recommendation: ${response.body}');
      }
    } catch (e) {
      print("Error getting recommendation: $e");
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
      );

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

  Future<void> register(String email, String password, String username) async {
    final url = Uri.parse('$baseUrl/auth/signup');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': username,
        }),
      );

      if (response.statusCode != 200) {
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
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data'];
        if (data == null) return null;
        
        // Ensure gender is valid ('male' or 'female') coming from DB?
        // It comes as string. UserMeasurement.fromJson needs implementation or manual parsing.
        // Let's rely on manual parsing if fromJson is missing or just parse it here.
        // UserMeasurement model doesn't have fromJson shown in my previous view.
        return UserMeasurement(
          height: (data['height'] as num).toDouble(),
          weight: (data['weight'] as num).toDouble(),
          chest: (data['chest'] as num).toDouble(),
          waist: (data['waist'] as num).toDouble(),
          hips: (data['hips'] as num).toDouble(),
          gender: data['gender'] ?? 'male',
        );
      } else {
        throw Exception('Failed to load measurements');
      }
    } catch (e) {
      print("Error fetching measurements: $e");
      // Return null or rethrow? 
      // If error, maybe user has no data or network error. 
      // Safe to return null for "no data found" but rethrow for network.
      return null;
    }
  }
  Future<List<HistoryItem>> getHistory(String userId) async {
    final url = Uri.parse('$baseUrl/history/$userId');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((item) => HistoryItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      print("Error fetching history: $e");
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
          'price': '', // Assuming price is not available in RecommendationResult yet
          'recommended_size': result.recommendedSize,
          'confidence_score': result.confidenceScore,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add to closet: ${response.body}');
      }
    } catch (e) {
      print("Error adding to closet: $e");
      rethrow;
    }
  }

  Future<void> deleteHistoryItem(String itemId) async {
    final url = Uri.parse('$baseUrl/history/$itemId');
    try {
      final response = await http.delete(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete item: ${response.body}');
      }
    } catch (e) {
      print("Error deleting history item: $e");
      rethrow;
    }
  }
}

