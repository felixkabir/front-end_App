class Agency {
  final String id;
  final DateTime createdAt;
  final String name;
  final String fileUrl;
  final String fileKey;
  final String contact;
  final String userId;
  final List<dynamic> models;
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
    this.location,
    this.rating,
    this.modelsCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'name': name,
      'file_url': fileUrl,
      'file_key': fileKey,
      'contact': contact,
      'userId': userId,
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
      models: json['models'],
      location: json['location'],
      rating: json['rating'] == null ? null : double.parse(json['rating']),
      modelsCount: json['models_count'] == null? null : int.parse(json['models_count']),
    );
  }
}