import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
      final String? userUsername = prefs.getString('user_username'); 
      final String? userFullName = prefs.getString('user_fullname');
      final String? accessToken = prefs.getString('access_token');

      if (userId != null && userEmail != null && accessToken != null) {
        // Restore user session initially from local storage
        _user = User(
          id: userId,
          email: userEmail,
          gender: userGender ?? 'male', 
          username: userUsername,
          fullName: userFullName,
          accessToken: accessToken,
        );
        
        // 1. Load local measurements
        final localMeasurements = await _loadMeasurementsLocally();
        if (localMeasurements != null) {
            _hasMeasurements = true;
        }

        // 2. Refresh User Profile (Background)
        // This ensures that if SharedPreferences has missing data (like missing fullName in old sessions),
        // we fetch it from the server and update the session.
        try {
           // debugPrint("Refreshing user profile...");
           final freshUser = await _apiService.getUserProfile(accessToken);
           // debugPrint("Profile refreshed: ${freshUser.fullName}");
           // Update in memory and persist
           _user = freshUser;
           await _saveUserSession(freshUser);
        } catch (e) {
           // If profile fetch fails (offline), we rely on the restored session.
           debugPrint("Profile refresh failed: $e");
        }

        // 3. Fetch fresh measurements
        await fetchMeasurements(); 
      }
    } catch (e) {
      // debugPrint("Error checking login status: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_gender', user.gender);
    if (user.username != null) await prefs.setString('user_username', user.username!);
    if (user.fullName != null) await prefs.setString('user_fullname', user.fullName!);
    if (user.accessToken != null) {
        await prefs.setString('access_token', user.accessToken!);
    }
  }

  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_gender');
    await prefs.remove('user_username');
    await prefs.remove('user_fullname');
    await prefs.remove('access_token');
    await _clearMeasurementsLocally();
  }


  // State
  bool _isLoading = false;
  String? _error;
  RecommendationResult? _result;
  User? _user;
  bool _hasMeasurements = false;
  Locale _locale = const Locale('tr'); // Default to Turkish
  ThemeMode _themeMode = ThemeMode.dark; // Default to Dark
  bool _isNewRegistration = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  RecommendationResult? get result => _result;
  User? get user => _user;
  bool get hasMeasurements => _hasMeasurements;
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get isAuthenticated => _user != null;
  String? get userId => _user?.id;
  bool get isNewRegistration => _isNewRegistration;

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
      _isNewRegistration = false; // Existing user login
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
      _isNewRegistration = true; // Flag as new user for tutorial
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
      // Get the updated measurements from the backend (which includes calculated body shape)
      final updatedMeasurements = await _apiService.updateMeasurements(_user!.id, measurements);
      
      // Update local cache with the BACKEND response, not just the local input
      await _saveMeasurementsLocally(updatedMeasurements);
      _hasMeasurements = true; 
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
      // Try fetching from API
      final measurements = await _apiService.getMeasurements(_user!.id);
      
      if (measurements != null) {
        // Success: Update state and cache
        _hasMeasurements = true;
        await _saveMeasurementsLocally(measurements);
        return measurements;
      } else {
        // Server returned null (no measurements stored), so we don't have them.
        _hasMeasurements = false;
        return null;
      }
    } catch (e) {
      // API Failed (Network error etc)
      // Attempt to return cached version if exists
      final local = await _loadMeasurementsLocally();
      if (local != null) {
         _hasMeasurements = true;
         // _error = null; // Do not surface network error if we have a valid fallback
         return local;
      }

      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveMeasurementsLocally(UserMeasurement measurements) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_measurements', jsonEncode(measurements.toJson()));
      } catch (e) {
        // Ignore cache save errors
      }
  }

  Future<UserMeasurement?> _loadMeasurementsLocally() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final String? jsonStr = prefs.getString('user_measurements');
        if (jsonStr != null) {
            final Map<String, dynamic> data = jsonDecode(jsonStr);
            return UserMeasurement.fromJson(data);
        }
      } catch (e) {
         return null;
      }
      return null;
  }

  Future<void> _clearMeasurementsLocally() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_measurements');
  }

  Future<void> addToCloset(RecommendationResult result, String productUrl) async {
    if (!isAuthenticated) return;

    try {
      await _apiService.addToCloset(result, _user!.id, productUrl);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<HistoryItem>> fetchHistory() async {
    if (!isAuthenticated) return [];

    try {
      return await _apiService.getHistory(_user!.id);
    } catch (e) {
      return [];
    }
  }

  Future<void> removeFromCloset(String itemId) async {
    if (!isAuthenticated) return;

    try {
      await _apiService.deleteHistoryItem(itemId);
      notifyListeners(); // Notify listeners if any other part depends on it
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    if (!isAuthenticated) return;

    try {
      await _apiService.deleteAccount(_user!.id);
      // Clear session locally
      logout();
    } catch (e) {
      rethrow;
    }
  }
}
