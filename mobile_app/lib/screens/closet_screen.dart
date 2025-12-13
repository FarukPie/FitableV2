import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/history_item.dart';

class ClosetScreen extends StatefulWidget {
  const ClosetScreen({super.key});

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen> {
  late Future<List<HistoryItem>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = Provider.of<AppProvider>(context, listen: false).fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Closet")),
      body: FutureBuilder<List<HistoryItem>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Your closet is empty."));
          }

          final history = snapshot.data!;
          return ListView.builder(
            itemCount: history.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index) {
              final item = history[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Image
                      if (item.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: _buildImage(item.imageUrl),
                        )
                      else
                        Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(item.brand, style: TextStyle(color: Colors.grey[600])),
                            const SizedBox(height: 4),
                            Text(
                              "Size: ${item.recommendedSize}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                            ),
                            Text(
                              "Score: ${(item.confidenceScore * 100).toStringAsFixed(1)}%",
                              style: const TextStyle(fontSize: 12, color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildImage(String url) {
    return Image.network(
        url,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (ctx, _, __) => const Icon(Icons.error),
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: 80,
            height: 80,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
  }
}
