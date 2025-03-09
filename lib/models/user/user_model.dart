import 'package:stivy/models/agency/agency_model.dart';

class User {
  final String id;
  final String createdAt;
  final String username;
  final String? fileUrl;
  final String? fileKey;
  final String email;
  final String password;
  final bool onlineStatus;
  final List<Agency> agencies;

  User({
    required this.id,
    required this.createdAt,
    required this.username,
    this.fileUrl,
    this.fileKey,
    required this.email,
    required this.password,
    this.onlineStatus = false, // Valor padrão para onlineStatus
    List<Agency>? agencies,
  }) : agencies = agencies ?? [];

  // Converte o objeto User para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'username': username,
      'file_url': fileUrl,
      'file_key': fileKey,
      'email': email,
      'password': password,
      'online_status': onlineStatus,
      'agencies': agencies.map((agency) => agency.toJson()).toList(),
    };
  }

  // Cria um objeto User a partir de um Map (JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '', // Valor padrão para id
      createdAt: json['created_at'] ?? '', // Valor padrão para createdAt
      username: json['username'] ?? '', // Valor padrão para username
      fileUrl: json['file_url'],
      fileKey: json['file_key'],
      email: json['email'] ?? '', // Valor padrão para email
      password: json['password'] ?? '', // Valor padrão para password
      onlineStatus: json['online_status'] ?? false, // Valor padrão para onlineStatus
      agencies: json['agencies'] != null
          ? (json['agencies'] as List)
              .map((agency) => Agency.fromJson(agency))
              .toList()
          : [],
    );
  }
}