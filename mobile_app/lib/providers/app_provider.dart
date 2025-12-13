import 'package:flutter/material.dart';
import '../models/user_measurement.dart';
import '../models/recommendation_result.dart';
import '../models/user_model.dart';
import '../models/history_item.dart';
import '../services/api_service.dart';

class AppProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State
  bool _isLoading = false;
  String? _error;
  RecommendationResult? _result;
  User? _user;
  Locale _locale = const Locale('en'); // Default to English

  bool get isLoading => _isLoading;
  String? get error => _error;
  RecommendationResult? get result => _result;
  User? get user => _user;
  Locale get locale => _locale;
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

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _apiService.login(email, password);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.register(email, password, username);
      // Optional: Auto-login after register, or let user login.
      // For now, let's just return and let UI handle it.
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
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
