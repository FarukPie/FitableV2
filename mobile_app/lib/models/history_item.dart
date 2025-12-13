class HistoryItem {
  final String id;
  final String userId;
  final String productName;
  final String brand;
  final String productUrl;
  final String imageUrl;
  final String price;
  final String recommendedSize;
  final double confidenceScore;
  final DateTime createdAt;

  HistoryItem({
    required this.id,
    required this.userId,
    required this.productName,
    required this.brand,
    required this.productUrl,
    required this.imageUrl,
    required this.price,
    required this.recommendedSize,
    required this.confidenceScore,
    required this.createdAt,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      productName: json['product_name'] ?? 'Unknown Product',
      brand: json['brand'] ?? 'Unknown Brand',
      productUrl: json['product_url'] ?? '',
      imageUrl: json['image_url'] ?? '',
      price: json['price'] ?? '',
      recommendedSize: json['recommended_size'] ?? 'N/A',
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
