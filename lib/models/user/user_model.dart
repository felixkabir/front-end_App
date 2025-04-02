import 'package:stivy/models/agency/agency_model.dart';

// No seu arquivo Dart (frontend)
enum UserType {
  MODEL,
  FREELANCE_MODEL,
  PHOTOGRAPHER,
  FREELANCE_PHOTOGRAPHER,
  FASHION_LOVER,
  DESIGNER,
  STYLIST,
  OTHER;

  String get displayName {
    switch (this) {
      case UserType.MODEL:
        return 'Modelo';
      case UserType.FREELANCE_MODEL:
        return 'Modelo Freelancer';
      case UserType.PHOTOGRAPHER:
        return 'Fotógrafo';
      case UserType.FREELANCE_PHOTOGRAPHER:
        return 'Fotógrafo Freelancer';
      case UserType.FASHION_LOVER:
        return 'Amante de Moda';
      case UserType.DESIGNER:
        return 'Designer';
      case UserType.STYLIST:
        return 'Estilista';
      case UserType.OTHER:
        return 'Outro';
    }
  }

  String get apiValue {
    return toString().split('.').last;
  }

  static UserType fromApi(String value) {
    return UserType.values.firstWhere(
      (e) => e.apiValue == value.toUpperCase(),
      orElse: () => UserType.OTHER,
    );
  }
}

enum Gender {
  MALE,
  FEMALE,
  OTHER;

  String get displayName {
    switch (this) {
      case Gender.MALE:
        return 'Masculino';
      case Gender.FEMALE:
        return 'Feminino';
      case Gender.OTHER:
        return 'Selecione o gênero';
    }
  }

  String get apiValue {
    return toString().split('.').last;
  }

  static Gender fromApi(String value) {
    return Gender.values.firstWhere(
      (e) => e.apiValue == value.toUpperCase(),
      orElse: () => Gender.OTHER,
    );
  }
}

class User {
  final String id;
  final DateTime createdAt;
  final String username;
  final String? fileUrl;
  final String? fileKey;
  final String email;
  final String password;
  final bool onlineStatus;
  final Gender gender;
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
    this.gender = Gender.OTHER,
    this.onlineStatus = false,
    List<Agency>? agencies,
    List<UserInterest>? interests,
  })  : agencies = agencies ?? [],
        interests = interests ?? [];

  String genderToString() {
    return gender.toString().split('.').last;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'username': username,
      'file_url': fileUrl,
      'file_key': fileKey,
      'email': email,
      'password': password,
      'online_status': onlineStatus,
      'gender': genderToString(),
      'agencies': agencies.map((agency) => agency.toJson()).toList(),
      'interests':
          interests.map((interest) => interest.toJson()).toList(), // Novo campo
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      username: json['username'] ?? '',
      fileUrl: json['file_url'],
      fileKey: json['file_key'],
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      onlineStatus: json['online_status'] ?? false,
      gender: Gender.fromApi(json['gender'] ?? 'OTHER'),
      agencies: json['agencies'] != null
          ? (json['agencies'] as List)
              .map((agency) => Agency.fromJson(agency))
              .toList()
          : [],
      interests: json['interests'] != null
          ? (json['interests'] as List)
              .map((interest) => UserInterest.fromJson(interest))
              .toList()
          : [],
    );
  }
 
}

class UserInterest {
  final String userId;
  final String interestId;

  UserInterest({
    required this.userId,
    required this.interestId,
  });

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
