class UserMeasurement {
  final double height;
  final double weight;
  final double chest;
  final double waist;
  final double hips;
  final String gender;

  UserMeasurement({
    required this.height,
    required this.weight,
    required this.chest,
    required this.waist,
    required this.hips,
    required this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'weight': weight,
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'gender': gender,
    };
  }
}
