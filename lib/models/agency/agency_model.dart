import 'package:stivy/models/user/user_model.dart';

class Model {
  final String id;
  final String name;
  final String height;
  final String waist;
  final String shoes;
  final String contact;
  final String fileUrl;
  final String fileKey;
  final String? userId;
  final String agencyId;

  Model({
    required this.id,
    required this.name,
    required this.height,
    required this.waist,
    required this.shoes,
    required this.contact,
    required this.fileUrl,
    required this.fileKey,
    required this.agencyId,
    this.userId,
  });

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      height: json['height'] ?? "",
      waist: json['waist'] ?? "",
      shoes: json['shoes'] ?? "",
      contact: json['contact'] ?? "",
      fileUrl: json['file_url'] ?? "",
      fileKey: json['file_key'] ?? "",
      agencyId: json['agencyId'] ?? "",
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'height': height,
      'waist': waist,
      'shoes': shoes,
      'contact': contact, 
      'file': fileKey,
      'agencyId': agencyId,
      'userId': userId,
    };
  }
}

class Agency {
  final String id;
  final DateTime createdAt;
  final String name;
  final String fileUrl;
  final String fileKey;
  final String contact;
  final String userId;
  final List<Model> models;
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
    this.location = "",
    this.rating = 0.0,
    this.modelsCount = 0,
  });

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      id: json['id'] ?? "",
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      name: json['name'] ?? "",
      fileUrl: json['file_url'] ?? "",
      fileKey: json['file_key'] ?? "",
      contact: json['contact'] ?? "",
      userId: json['userId'] ?? "",
      models: json['models'] != null
          ? (json['models'] as List)
              .map((model) => Model.fromJson(model))
              .toList()
          : [],
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
            ),
      Post: json['Post'] ?? [],
      location: json['location'] ?? "",
      rating: json['_count'] != null && json['_count']['models'] != null
          ? double.parse(json['_count']['models'].toString())
          : 0.0,
      modelsCount: json['_count'] != null && json['_count']['models'] != null
          ? int.parse(json['_count']['models'].toString())
          : 0,
    );
  }

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
      'creator': creator.toJson(),
      'Post': Post,
      'location': location,
      'rating': rating,
      'models_count': modelsCount,
    };
  }
}