class AgencyModel {
  final String id;
  final String name;
  final String imageUrl;
  final String location;
  final double? rating;
  final int modelsCount;
  
  

  AgencyModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.location,
    this.rating,
    required this.modelsCount,
  });
  
   factory AgencyModel.fromJson(Map<String, dynamic> json) {
    return AgencyModel(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      location: json['location'],
      rating: json['rating'] == null? null : double.parse(json['rating']),
      modelsCount: json['models_count'],
    );
  }
}
