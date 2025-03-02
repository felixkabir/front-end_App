class Colaborador {
  final String id;
  final String name;
  final String role;
  final String contact;
  final String agencyId;
  final String? fileKey;
  final String? fileUrl;

  Colaborador({
    required this.id,
    required this.name,
    required this.role,
    required this.contact,
    required this.agencyId,
    this.fileKey,
    this.fileUrl,
  });
}