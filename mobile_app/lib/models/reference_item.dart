
class ReferenceItem {
  final int id;
  final String userId;
  final String brand;
  final String sizeLabel;

  ReferenceItem({
    required this.id,
    required this.userId,
    required this.brand,
    required this.sizeLabel,
  });

  factory ReferenceItem.fromJson(Map<String, dynamic> json) {
    return ReferenceItem(
      id: json['id'],
      userId: json['user_id'],
      brand: json['brand'],
      sizeLabel: json['size_label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'brand': brand,
      'size_label': sizeLabel,
    };
  }
}
