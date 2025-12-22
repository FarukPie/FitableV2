class RecommendationResult {
  final String productName;
  final String brand;
  final String recommendedSize;
  final Map<String, int> sizePercentages; // NEW: {"L": 88, "M": 10, "XL": 2}
  final String fitMessage;
  final String warning;
  final String imageUrl;

  RecommendationResult({
    required this.productName,
    required this.brand,
    required this.recommendedSize,
    required this.sizePercentages,
    required this.fitMessage,
    required this.warning,
    required this.imageUrl,
  });

  factory RecommendationResult.fromJson(Map<String, dynamic> json) {
    print("DEBUG: Parsing Recommendation Result: $json");
    final product = json['product'] ?? {};
    final rec = json['recommendation'] ?? {};

    // Parse size_percentages
    Map<String, int> percentages = {};
    if (rec['size_percentages'] != null) {
      final rawPercentages = rec['size_percentages'] as Map<String, dynamic>;
      rawPercentages.forEach((key, value) {
        percentages[key] = (value as num).toInt();
      });
    }

    return RecommendationResult(
      productName: product['product_name'] ?? 'Unknown Product',
      brand: product['brand'] ?? 'Unknown Brand',
      imageUrl: product['image_url'] ?? '',
      recommendedSize: rec['recommended_size'] ?? 'N/A',
      sizePercentages: percentages,
      fitMessage: rec['fit_message'] ?? '',
      warning: rec['warning'] ?? '',
    );
  }
}
