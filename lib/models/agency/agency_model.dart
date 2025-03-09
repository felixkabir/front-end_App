import 'package:stivy/models/user/user_model.dart';
class Agency {
  final String id;
  final DateTime createdAt;
  final String name;
  final String fileUrl;
  final String fileKey;
  final String contact;
  final String userId;
  final List<User> models;
  final List<dynamic> Post;
  final User creator; // Alterado para User (não é uma lista)
  final String? location;
  final double? rating;
  final int? modelsCount;

  Agency({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.fileUrl,
    required this.fileKey,
    required this.contact,
    required this.userId,
    required this.models,
    required this.creator, // Agora é um único User
    required this.Post,
    this.location,
    this.rating,
    this.modelsCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'file_url': fileUrl,
      'file_key': fileKey,
      'contact': contact,
      'userId': userId,
      'models': models.map((model) => model.toJson()).toList(),
      'creator': creator.toJson(), // Agora é um único objeto User
      'Post': Post,
      'location': location,
      'rating': rating,
      'models_count': modelsCount,
    };
  }

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      name: json['name'],
      fileUrl: json['file_url'],
      fileKey: json['file_key'],
      contact: json['contact'],
      userId: json['userId'],
      models: (json['models'] as List).map((model) => User.fromJson(model)).toList(),
      creator: User.fromJson(json['creator']), // Agora é um único objeto User
      Post: json['Post'],
      location: json['location'],
      rating: json['rating'] == null ? null : double.parse(json['rating']),
      modelsCount: json['models_count'] == null ? null : int.parse(json['models_count']),
    );
  }
}