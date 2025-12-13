import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/recommendation_result.dart';

class ResultScreen extends StatelessWidget {
  final RecommendationResult result;
  final String productUrl;

  const ResultScreen({super.key, required this.result, required this.productUrl});

  @override
  Widget build(BuildContext context) {
    // Removed provider lookup since we pass result directly


    return Scaffold(
      appBar: AppBar(title: const Text("Recommendation")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image
            if (result.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  result.imageUrl,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 300, 
                    color: Colors.grey[200], 
                    child: const Icon(Icons.image_not_supported, size: 50)
                  ),
                ),
              ),
            const SizedBox(height: 20),
            
            // Product Info
            Text(
              result.brand.toUpperCase(),
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              result.productName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Recommendation Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text("Recommended Size", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(
                    result.recommendedSize,
                    style: TextStyle(
                      fontSize: 48, 
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Confidence: ${(result.confidenceScore * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Fit Message
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(result.fitMessage, style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Warning
            if (result.warning.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        result.warning,
                        style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              
            const SizedBox(height: 30),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Discard and go back
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text("Çöpe At", style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await Provider.of<AppProvider>(context, listen: false)
                            .addToCloset(result, productUrl);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Added to Closet!")),
                        );
                        // Optional: Navigate to Closet or Home?
                        // User said "discard throws back", didn't specify for add. 
                        // I'll stay on screen or go back. Let's go home for better flow.
                        Navigator.pop(context); 
                      } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    },
                    icon: const Icon(Icons.checkroom),
                    label: const Text("Dolabıma Koy"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
