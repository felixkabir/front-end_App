import 'package:stivy/models/reaction/reaction_model.dart';
import 'package:stivy/models/user/user_model.dart';
import 'package:stivy/models/agency/agency_model.dart';

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
  final Agency? agency;
  final List<ReactionModel> reactions;

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
    this.agency,
    required this.reactions,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      content: json['content'],
      isWorkModel: json['is_work_model'] ?? false, // Default value if null
      type: json['type'],
      userId: json['userId'],
      agencyId: json['agencyId'],
      modelId: json['modelId'],
      fileEntities: (json['file_entity'] as List)
          .map((file) => FileEntity.fromJson(file))
          .toList(),
      user: json['user'] != null ? User.fromJson(json['user']) : null, // Handling for null user
      agency: json['agency'] != null ? Agency.fromJson(json['agency']) : null, // Handling for null agency
      reactions: json['Reaction'] != null
          ? (json['Reaction'] as List)
              .map((reaction) => ReactionModel.fromJson(reaction))
              .toList()
          : [],
    );
  }


  bool hasUserReacted(String userId) {
    return reactions.any((reaction) => reaction.userId == userId);
  }
  // Get reaction count
  int get reactionCount => reactions.length;
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
