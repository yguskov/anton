class User {
  final int id;
  final String email;
  final bool is_hr;
  final Map<String, dynamic> userData;
  final String createdAt;
  final String guid;

  User(
      {required this.id,
      required this.email,
      required this.is_hr,
      required this.userData,
      required this.createdAt,
      this.guid = ''});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      is_hr: json['is_hr'] ?? false,
      userData: Map<String, dynamic>.from(json['user_data'] ?? {}),
      createdAt: json['created_at'],
      guid: json['guid'],
    );
  }

  bool get isHr => this.is_hr;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_data': userData,
      'created_at': createdAt,
      'guid': guid,
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

class ClearRequest {
  final String email;

  ClearRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class ResultRequest {
  final String user;
  final int assign;
  final String comment;

  ResultRequest({
    required this.user,
    required this.assign,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'assign': assign,
      'comment': comment,
    };
  }
}
