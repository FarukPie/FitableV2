import 'dart:convert';

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
  final Map<String, int> sizePercentages; // Stored percentages from recommendation
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
    required this.sizePercentages,
    required this.createdAt,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    // Parse size_percentages from JSON string if available
    Map<String, int> percentages = {};
    if (json['size_percentages'] != null && json['size_percentages'] is String) {
      try {
        final jsonStr = json['size_percentages'] as String;
        if (jsonStr.isNotEmpty && jsonStr.startsWith('{')) {
          final Map<String, dynamic> parsed = jsonDecode(jsonStr);
          parsed.forEach((key, value) {
            percentages[key] = (value as num).toInt();
          });
        }
      } catch (e) {
        // If parsing fails, percentages remain empty
      }
    }
    
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
      sizePercentages: percentages,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
