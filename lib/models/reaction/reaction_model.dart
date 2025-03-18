class ReactionModel {
  final String id;
  final String userId;
  final String? postId;
  final String? eventId;

  ReactionModel({
    required this.id,
    required this.userId,
    this.postId,
    this.eventId,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      id: json['id'],
      userId: json['userId'],
      postId: json['postId'],
      eventId: json['eventId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'postId': postId,
      'eventId': eventId,
    };
  }
}