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
  final User creator;
  final String location;
  final double rating;
  final int modelsCount;

  Agency({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.fileUrl,
    required this.fileKey,
    required this.contact,
    required this.userId,
    required this.models,
    required this.creator,
    required this.Post,
    this.location = "", // Valor padrão para location
    this.rating = 0.0, // Valor padrão para rating
    this.modelsCount = 0, // Valor padrão para modelsCount
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
      id: json['id'] ?? "", // Valor padrão para id
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(), // Valor padrão para createdAt
      name: json['name'] ?? "", // Valor padrão para name
      fileUrl: json['file_url'] ?? "", // Valor padrão para fileUrl
      fileKey: json['file_key'] ?? "", // Valor padrão para fileKey
      contact: json['contact'] ?? "", // Valor padrão para contact
      userId: json['userId'] ?? "", // Valor padrão para userId
      models: json['models'] != null
          ? (json['models'] as List)
              .map((model) => User.fromJson(model))
              .toList()
          : [], // Lista vazia se models for null
      creator: json['creator'] != null
          ? User.fromJson(json['creator'])
          : User(
              id: "",
              createdAt: DateTime.now(),
              username: "",
              email: "",
              password: "",
              onlineStatus: false,
              agencies: [],
              interests: [],
            ), // Valor padrão para creator
      Post: json['Post'] ?? [], // Lista vazia se Post for null
      location: json['location'] ?? "", // Valor padrão para location
      rating: json['rating'] != null
          ? double.parse(json['rating'].toString())
          : 0.0, // Valor padrão para rating
      modelsCount: json['models_count'] != null
          ? int.parse(json['models_count'].toString())
          : 0, // Valor padrão para modelsCount
    );
  }
}
