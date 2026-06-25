import 'dart:convert';
import 'dart:js_interop';

import 'package:example/models/cv.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  User? _currentUser;
  CV? _userCV;
  bool _isLoading = false;
  String? _error;

  AuthProvider({required ApiService apiService}) : _apiService = apiService;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuth => currentUser != null;

  CV? get userCV => _userCV;

  bool get hasToken => _apiService.hasToken;

  Future<bool> register(String email, String password, Map<String, dynamic> userData) async {
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
      if (e.toString().contains('Duplicate')) {
        _error = 'Такой пользователь уже существует';
      } else if (e is ClientException) {
        _error = 'Сервер не отвечает';
      } else {
        _error = 'Возникла ошибка при регистрации';
      }

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
      print(response);
      _currentUser = response['user'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print(_error);
      if (e.toString().contains('Invalid credentials')) {
        _error = 'Неизвестный e-mail адрес или неверный пароль';
      } else if (e is ClientException) {
        _error = 'Сервер не отвечает';
      } else {
        _error = 'Ошибка авторизации';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _apiService.logout();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fetchCurrentUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _apiService.getProfile();
      _isLoading = false;

      print('----- fetch user from API: ${_currentUser!.email}');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      dynamic response = await _apiService.changePassword({'old': oldPassword, 'new': newPassword});
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (e.toString().contains('Invalid old password')) {
        _error = 'Текущий пароль указан неверно';
      } else if (e is ClientException) {
        _error = 'Сервер не отвечает';
      } else {
        _error = 'Возникла ошибка при смене пароля';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveCV(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      dynamic response = await _apiService.save(userData);
      print(response);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveResult(String guid, int assign, String comment) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      dynamic response =
          await _apiService.saveResult(ResultRequest(user: guid, assign: assign, comment: comment));
      print(response);
      _isLoading = false;
      _userCV!.setValue('assign', assign);
      _userCV!.setValue('comment', comment);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      print(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadUserCV(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      var json = await _apiService.getUserCV(id);
      _isLoading = false;

      print('--------get-cv---------------- ${json}');
      notifyListeners();
      _userCV = CV.fromJson(jsonEncode(json));
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}

// http://localhost:42208/#/show/d56iefpams3vsfqpk5k0
