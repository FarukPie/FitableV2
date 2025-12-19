import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_measurement.dart';
import '../models/recommendation_result.dart';
import '../models/user_model.dart';
import '../models/history_item.dart';
import '../services/api_service.dart';

class AppProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  AppProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('user_id');
      final String? userEmail = prefs.getString('user_email');
      final String? userGender = prefs.getString('user_gender');
      final String? accessToken = prefs.getString('access_token');

      if (userId != null && userEmail != null && accessToken != null) {
        // Restore user session
        _user = User(
          id: userId,
          email: userEmail,
          gender: userGender ?? 'male', // Default or save/load accordingly
          accessToken: accessToken,
        );
        
        // Fetch measurements to ensure data consistency
        await fetchMeasurements(); 
      }
    } catch (e) {
      print("Error checking login status: $e");
    } finally {
      // Small delay to prevent flickering if it's too fast, or just finish
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_gender', user.gender);
    if (user.accessToken != null) {
        await prefs.setString('access_token', user.accessToken!);
    }
  }

  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_gender');
    await prefs.remove('access_token');
  }


  // State
  bool _isLoading = false;
  String? _error;
  RecommendationResult? _result;
  User? _user;
  bool _hasMeasurements = false;
  Locale _locale = const Locale('tr'); // Default to Turkish
  ThemeMode _themeMode = ThemeMode.dark; // Default to Dark

  bool get isLoading => _isLoading;
  String? get error => _error;
  RecommendationResult? get result => _result;
  User? get user => _user;
  bool get hasMeasurements => _hasMeasurements;
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get isAuthenticated => _user != null;
  String? get userId => _user?.id;

  void clearResult() {
    _result = null;
    _error = null;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }





  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _apiService.login(email, password);
      await _saveUserSession(_user!);
      // Check if user has measurements
      final measurements = await _apiService.getMeasurements(_user!.id);
      _hasMeasurements = measurements != null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String username, String fullName, String gender, int age) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _apiService.register(email, password, username, fullName, gender, age);
      await _saveUserSession(_user!);
      // New user has no measurements yet.
      _hasMeasurements = false; 
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _clearUserSession();
    _user = null;
    _result = null;
    _error = null;
    notifyListeners();
  }

  Future<void> analyzeProduct(String productUrl) async {
    if (!isAuthenticated) return;
    
    _isLoading = true;
    _error = null;
    _result = null;
    notifyListeners();

    try {
      _result = await _apiService.getRecommendation(_user!.id, productUrl);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveMeasurements(UserMeasurement measurements) async {
    if (!isAuthenticated) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.updateMeasurements(_user!.id, measurements);
      _hasMeasurements = true;
      print("Saved measurements for ${_user!.id}: ${measurements.toJson()}");
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<UserMeasurement?> fetchMeasurements() async {
    if (!isAuthenticated) return null;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final measurements = await _apiService.getMeasurements(_user!.id);
      _hasMeasurements = measurements != null;
      return measurements;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCloset(RecommendationResult result, String productUrl) async {
    if (!isAuthenticated) return;

    try {
      await _apiService.addToCloset(result, _user!.id, productUrl);
      // Optional: Add to local list immediately?
      // _history.add(...); notifyListeners();
    } catch (e) {
      print("Error adding to closet provider: $e");
      rethrow;
    }
  }

  Future<List<HistoryItem>> fetchHistory() async {
    if (!isAuthenticated) return [];

    try {
      return await _apiService.getHistory(_user!.id);
    } catch (e) {
      print("Error fetching history provider: $e");
      return [];
    }
  }

  Future<void> removeFromCloset(String itemId) async {
    if (!isAuthenticated) return;

    try {
      await _apiService.deleteHistoryItem(itemId);
      notifyListeners(); // Notify listeners if any other part depends on it
    } catch (e) {
      print("Error removing form closet provider: $e");
      rethrow;
    }
  }
}
