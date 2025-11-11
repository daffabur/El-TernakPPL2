import 'dart:convert';


ApiResponse apiResponseFromJson(String str) => ApiResponse.fromJson(json.decode(str));

class ApiResponse {
  final bool success;
  final String message;
  final List<User> data;

  ApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
    success: json["success"],
    message: json["message"],
    data: List<User>.from(json["data"].map((x) => User.fromJson(x))),
  );
}

class User {
  final dynamic id;
  final String username;
  final String role;
  final bool isActive;
  final int? kandangId;
  final bool isPj;

  User({
    required this.id,
    required this.username,
    required this.role,
    required this.isActive,
    this.kandangId,
    this.isPj = false,
  });

  // Factory constructor untuk membuat instance User dari JSON
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    username: json["username"],
    role: json["role"],
    isActive: json["is_active"],
    kandangId: json['kandang_id'],
    isPj: json["is_pj"] ?? false,
  );

  get name => null;

  get fullName => null;

  get nama => null;
}
