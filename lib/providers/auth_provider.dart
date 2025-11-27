import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider({required ApiService apiService}) : _apiService = apiService;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuth => currentUser.isDefinedAndNotNull;

  Future<bool> register(
      String email, String password, Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        userData: userData,
      );

      dynamic response = await _apiService.register(request);
      _currentUser = response['user'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = LoginRequest(
        email: email,
        password: password,
      );

      dynamic response = await _apiService.login(request);
      _currentUser = response.User;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
