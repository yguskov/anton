import 'dart:convert';
import 'dart:html';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  String? _token;

  final String baseUrl;
  final http.Client client;

  ApiService({http.Client? client})
      : client = client ?? http.Client(),
        baseUrl = const String.fromEnvironment(
          'API_URL',
          defaultValue: 'http://localhost:8993/api',
        ) {
    if (window.localStorage['token'] != null) _token = window.localStorage['token']!;
  }

  // Сохраняем токен
  void set token(String token) {
    _token = token;
    window.localStorage['token'] = token;
  }

  void clearToken() {
    _token = null;
    window.localStorage.remove('token');
  }

  // Получаем headers с авторизацией
  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

/**
 * @return 
 * {
          'success': true,
          'user': User.fromJson(data['data']['user']),
          'token': data['data']['token'],
   }
 */

  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    final response = await client.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        token = data['data']['token'];
        return {
          'success': true,
          'user': User.fromJson(data['data']['user']),
          'token': data['data']['token'],
        };
      } else {
        throw Exception(data['error'] ?? 'Ошибка регистрации');
      }
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> login(LoginRequest request) async {
    final response = await client.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        token = data['data']['token'];
        return {
          'success': true,
          'user': User.fromJson(data['data']['user']),
          'token': data['data']['token'],
        };
      } else {
        throw Exception(data['error'] ?? 'Login failed');
      }
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  void logout() {
    clearToken();
  }

  Future<List<User>> getUsers() async {
    final response = await client.get(
      Uri.parse('$baseUrl/users'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final List<dynamic> usersJson = data['data'];
        return usersJson.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception(data['error'] ?? 'Failed to load users');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - please login again');
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<User> getProfile() async {
    final response = await client.get(
      Uri.parse('$baseUrl/profile'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['email'] != null) {
        return User.fromJson(data);
      } else {
        throw Exception(data['error'] ?? 'Failed to load profile');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - please login again');
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<Map<String, dynamic>> changePassword(Map<String, dynamic> request) async {
    final response = await client.post(
      Uri.parse('$baseUrl/password'),
      headers: _getHeaders(),
      body: json.encode(request),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        token = data['data']['token'];
        return {
          'success': true,
        };
      } else {
        throw Exception(data['error'] ?? 'Change password failed');
      }
    } else {
      throw Exception('Failed to change password: ${response.body}');
    }
  }

  // Save CV Data
  Future<Map<String, dynamic>> save(Map<String, dynamic> userData) async {
    final response = await client.post(
      Uri.parse('$baseUrl/save'),
      headers: _getHeaders(),
      body: json.encode(userData),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Ok',
        };
      } else {
        throw Exception(data['error'] ?? 'Ошибка сохранения');
      }
    } else {
      throw Exception('Cервер вернул ошибку: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getUserCV(String id) async {
    final response = await client.post(
      Uri.parse('$baseUrl/cv'),
      headers: _getHeaders(),
      body: json.encode({'id': id}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['error'] ?? 'Change password failed');
      }
    } else {
      throw Exception('Failed to change password: ${response.body}');
    }
  }

  Future<List<String>> listHint(String category) async {
    // Разбираем базовый URL
    final baseUri = Uri.parse(baseUrl);

    // Создаем новый URL
    final url = Uri(
      scheme: baseUri.scheme, // 'http'
      host: baseUri.host, // 'localhost'
      port: baseUri.port, // 8993
      path: '${baseUri.path}/hint', // '/api/hints'
      queryParameters: {'category': category},
    );

/* 
    final url = Uri.https(
      baseUrl,
      '/hints',
      {
        'category': category,
        // 'limit': '10',
        // 'sort': 'desc',
      },
    );
 */
    final response = await client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      print('----body-------${response.body}----------');
      print('----data-------${data}----------');

      return data.map((item) => item.toString()).toList();

      // final data = json.decode(response.body);
      // return data as List<String>;
      // final List<dynamic> json = data as List<String>;
    } else {
      return List<String>.from([]);
    }
  }
}
