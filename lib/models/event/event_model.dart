import 'package:stivy/models/agency/agency_model.dart';
import 'package:stivy/models/reaction/reaction_model.dart';
import 'package:stivy/models/user/user_model.dart';

class Event {
  final String id;
  final DateTime createdAt;
  final String name;
  final String fileUrl;
  final String fileKey;
  final DateTime startDate;
  final DateTime endDate;
  final String? userId;
  final String? agencyId;
  final String? location;
  final User? user;
  final Agency? agency;
  final List<ReactionModel> reactions;
  

  Event({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.fileUrl,
    required this.fileKey,
    required this.startDate,
    required this.endDate,
    required this.reactions,
    this.userId,
    this.agencyId,
    this.user,
    this.agency,
    this.location,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      name: json['name'],
      fileUrl: json['file_url'],
      fileKey: json['file_key'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      userId: json['userId'],
      agencyId: json['agencyId'],
      location: json['location'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      agency: json['agency'] != null ? Agency.fromJson(json['agency']) : null,
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
  int get reactionCount => reactions.length;
}
