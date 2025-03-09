import 'package:stivy/models/user/user_model.dart';

class Post {
  final String id;
  final DateTime createdAt;
  final String? content;
  final bool isWorkModel;
  final String type;
  final String? userId;
  final String? agencyId;
  final String? modelId;
  final List<FileEntity> fileEntities;
  final User? user;

  Post({
    required this.id,
    required this.createdAt,
    this.content,
    required this.isWorkModel,
    required this.type,
    this.userId,
    this.agencyId,
    this.modelId,
    required this.fileEntities,
    this.user,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      content: json['content'],
      isWorkModel: json['is_work_model'] ?? false, // Valor padrão caso seja null
      type: json['type'],
      userId: json['userId'],
      agencyId: json['agencyId'],
      modelId: json['modelId'],
      fileEntities: (json['file_entity'] as List)
          .map((file) => FileEntity.fromJson(file))
          .toList(),
      user: json['user'] != null ? User.fromJson(json['user']) : null, // Tratamento para user null
    );
  }
}

class FileEntity {
  final String id;
  final String fileUrl;
  final String fileKey;
  final String? modelId;
  final String postId;

  FileEntity({
    required this.id,
    required this.fileUrl,
    required this.fileKey,
    this.modelId,
    required this.postId,
  });

  factory FileEntity.fromJson(Map<String, dynamic> json) {
    return FileEntity(
      id: json['id'],
      fileUrl: json['file_url'],
      fileKey: json['file_key'],
      modelId: json['modelId'],
      postId: json['postId'],
    );
  }
}