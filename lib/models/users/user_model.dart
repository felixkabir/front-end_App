class User {
  final String id;
  final String createdAt;
  final String username;
  final String? fileUrl;
  final String? fileKey;
  final String email;
  final String password;

  User({
    required this.id,
    required this.createdAt,
    required this.username,
    this.fileUrl,
    this.fileKey,
    required this.email,
    required this.password,
  });

  // Converte o objeto User para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'username': username,
      'file_url': fileUrl,
      'file_key': fileKey,
      'email': email,
      'password': password,
    };
  }

  // Cria um objeto User a partir de um Map (JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      createdAt: json['created_at'],
      username: json['username'],
      fileUrl: json['file_url'],
      fileKey: json['file_key'],
      email: json['email'],
      password: json['password'],
    );
  }
}