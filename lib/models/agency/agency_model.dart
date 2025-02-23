class AgencyModel {
  final String name;
  final String location;

  AgencyModel({required this.name, required this.location});

  factory AgencyModel.fromJson(Map<String, dynamic> json) {
    return AgencyModel(
      name: json['name'],
      location: json['location'],
    );
  }
}