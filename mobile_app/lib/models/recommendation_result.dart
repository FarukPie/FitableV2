class RecommendationResult {
  final String productName;
  final String brand;
  final String recommendedSize;
  final double confidenceScore;
  final String fitMessage;
  final String warning;
  final String imageUrl;

  RecommendationResult({
    required this.productName,
    required this.brand,
    required this.recommendedSize,
    required this.confidenceScore,
    required this.fitMessage,
    required this.warning,
    required this.imageUrl,
  });

  factory RecommendationResult.fromJson(Map<String, dynamic> json) {
    print("DEBUG: Parsing Recommendation Result: $json");
    final product = json['product'] ?? {};
    final rec = json['recommendation'] ?? {};

    return RecommendationResult(
      productName: product['product_name'] ?? 'Unknown Product',
      brand: product['brand'] ?? 'Unknown Brand',
      imageUrl: product['image_url'] ?? '',
      recommendedSize: rec['recommended_size'] ?? 'N/A',
      confidenceScore: (rec['confidence_score'] ?? 0.0).toDouble(),
      fitMessage: rec['fit_message'] ?? '',
      warning: rec['warning'] ?? '',
    );
  }
}
