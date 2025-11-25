class User {
  final int id;
  final String email;
  final Map<String, dynamic> userData;
  final String createdAt;

  User({
    required this.id,
    required this.email,
    required this.userData,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      userData: Map<String, dynamic>.from(json['user_data'] ?? {}),
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_data': userData,
      'created_at': createdAt,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final Map<String, dynamic> userData;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.userData,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'user_data': userData,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
