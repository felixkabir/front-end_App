import 'package:stivy/models/user/user_model.dart';

class Event {
  final String id;
  final DateTime createdAt;
  final String name;
  final String fileUrl;
  final String fileKey;
  final DateTime startDate;
  final DateTime endDate;
  final String userId;
  final String? location;
  final User user;

  Event({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.fileUrl,
    required this.fileKey,
    required this.startDate,
    required this.endDate,
    required this.userId,
    required this.user,
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
      location: json['location'],
      user: User.fromJson(json['user']),
    );
  }
}