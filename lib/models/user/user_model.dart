import 'package:stivy/models/agency/agency_model.dart';

class User {
  final String id;
  final DateTime createdAt; // Alterado para DateTime
  final String username;
  final String? fileUrl;
  final String? fileKey;
  final String email;
  final String password;
  final bool onlineStatus;
  final List<Agency> agencies;
  final List<UserInterest> interests; // Novo campo para interesses

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
    List<UserInterest>? interests, // Novo campo para interesses
  })  : agencies = agencies ?? [],
        interests = interests ?? [];

  // Converte o objeto User para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(), // Converte DateTime para String
      'username': username,
      'file_url': fileUrl,
      'file_key': fileKey,
      'email': email,
      'password': password,
      'online_status': onlineStatus,
      'agencies': agencies.map((agency) => agency.toJson()).toList(),
      'interests': interests.map((interest) => interest.toJson()).toList(), // Novo campo
    };
  }

  // Cria um objeto User a partir de um Map (JSON)
 factory User.fromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'] ?? '', // Valor padrão para id
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at']) // Converte String para DateTime
        : DateTime.now(), // Valor padrão para createdAt
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
        : [], // Lista vazia caso agencies seja null
    interests: json['interests'] != null // Tratamento para interests null
        ? (json['interests'] as List)
            .map((interest) => UserInterest.fromJson(interest))
            .toList()
        : [], // Lista vazia caso interests seja null
  );
}
}

// Modelo para UserInterest
class UserInterest {
  final String userId;
  final String interestId;

  UserInterest({
    required this.userId,
    required this.interestId,
  });

  // Converte o objeto UserInterest para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'interestId': interestId,
    };
  }

  // Cria um objeto UserInterest a partir de um Map (JSON)
  factory UserInterest.fromJson(Map<String, dynamic> json) {
    return UserInterest(
      userId: json['userId'] ?? '', // Valor padrão para userId
      interestId: json['interestId'] ?? '', // Valor padrão para interestId
    );
  }
}