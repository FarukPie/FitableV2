class UserMeasurement {
  final double height;
  final double weight;
  final double chest;
  final double waist;
  final double hips;
  final double shoulder;
  final double legLength;
  final double footLength;
  final String gender;
  final String? bodyShape;

  UserMeasurement({
    required this.height,
    required this.weight,
    required this.chest,
    required this.waist,
    required this.hips,
    required this.shoulder,
    required this.legLength,
    required this.footLength,
    required this.gender,
    this.bodyShape,
  });

  factory UserMeasurement.fromJson(Map<String, dynamic> json) {
    return UserMeasurement(
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      chest: (json['chest'] as num).toDouble(),
      waist: (json['waist'] as num).toDouble(),
      hips: (json['hips'] as num?)?.toDouble() ?? 0.0,
      shoulder: (json['shoulder'] as num?)?.toDouble() ?? 0.0,
      legLength: (json['inseam'] as num?)?.toDouble() ?? 0.0, // Backend uses 'inseam'
      footLength: (json['foot_length'] as num?)?.toDouble() ?? 0.0,
      gender: json['gender'] ?? 'male',
      bodyShape: json['body_shape'], // Optional
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'weight': weight,
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'shoulder': shoulder,
      'inseam': legLength, // Backend uses 'inseam'
      'foot_length': footLength,
      'gender': gender,
      'body_shape': bodyShape,
    };
  }
}
