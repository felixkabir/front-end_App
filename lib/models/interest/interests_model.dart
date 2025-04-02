class Interest {
  final String id;
  final String createdAt;
  final String interestType;
  final String name;
  final List<dynamic>? users;

  Interest({
    required this.id,
    required this.createdAt,
    required this.interestType,
    required this.name,
    this.users,
  });

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      id: json['id'],
      createdAt: json['created_at'],
      interestType: json['interest_type'],
      name: json['name'],
      users: json['users'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Interest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}