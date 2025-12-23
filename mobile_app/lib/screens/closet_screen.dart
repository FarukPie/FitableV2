import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/history_item.dart';
import '../models/recommendation_result.dart';
import 'package:size_recommendation_app/l10n/app_localizations.dart';
import '../utils/icon_mapper.dart';
import '../utils/name_simplifier.dart';
import 'package:url_launcher/url_launcher.dart';
import 'result_screen.dart';
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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.myClosetTitle)),
      body: FutureBuilder<List<HistoryItem>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.closetEmpty));
          }

          final history = snapshot.data!;
          return ListView.builder(
            itemCount: history.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index) {
              final item = history[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: InkWell(
                  onTap: () => _showRecommendationDetails(item),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // Icon always shown now
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: _buildImage(item.imageUrl, item.productName),
                        ),
                        const SizedBox(width: 16),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                NameSimplifier.simplify(item.productName),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(item.brand, style: TextStyle(color: Colors.grey[600])),
                              const SizedBox(height: 4),
                              Text(
                                "${AppLocalizations.of(context)!.sizeLabel}: ${item.recommendedSize}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                              ),
                              Text(
                                "${AppLocalizations.of(context)!.scoreLabel}: ${(item.confidenceScore * 100).toStringAsFixed(1)}%",
                                style: const TextStyle(fontSize: 12, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                  
                        // Delete Button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(AppLocalizations.of(context)!.removeItemTitle),
                                content: Text(
                                    AppLocalizations.of(context)!.removeItemConfirm),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(AppLocalizations.of(context)!.cancelButton),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text(AppLocalizations.of(context)!.removeButton,
                                        style: const TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                  
                            if (confirm == true) {
                              print("DEBUG: User confirmed delete for item ID: ${item.id}");
                              try {
                                await Provider.of<AppProvider>(context, listen: false)
                                    .removeFromCloset(item.id);
                                setState(() {
                                  _historyFuture =
                                      Provider.of<AppProvider>(context, listen: false)
                                          .fetchHistory();
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocalizations.of(context)!.itemRemoved)),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("${AppLocalizations.of(context)!.removeFailed}$e")),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showRecommendationDetails(HistoryItem item) {
    // Use stored percentages if available, otherwise calculate fallback
    Map<String, int> sizePercentages;
    
    if (item.sizePercentages.isNotEmpty) {
      // Use stored percentages directly - this is the FIX!
      sizePercentages = item.sizePercentages;
    } else {
      // Fallback for old data without stored percentages
      final topPct = (item.confidenceScore * 100).round();
      final secondPct = ((1 - item.confidenceScore) * 100 * 0.7).round();
      final thirdPct = 100 - topPct - secondPct;
      
      // Get next size for percentage display
      final sizeOrder = ["XXS", "XS", "S", "M", "L", "XL", "XXL", "3XL"];
      String secondSize = "?";
      String thirdSize = "?";
      
      final upperSize = item.recommendedSize.toUpperCase();
      final currentIndex = sizeOrder.indexOf(upperSize);
      
      if (currentIndex >= 0) {
        if (currentIndex < sizeOrder.length - 1) {
          secondSize = sizeOrder[currentIndex + 1];
        }
        if (currentIndex > 0) {
          thirdSize = sizeOrder[currentIndex - 1];
        }
      } else {
        final numSize = int.tryParse(item.recommendedSize);
        if (numSize != null) {
          secondSize = (numSize + 1).toString();
          thirdSize = (numSize - 1).toString();
        }
      }
      
      sizePercentages = {
        item.recommendedSize: topPct,
        secondSize: secondPct,
        thirdSize: thirdPct > 0 ? thirdPct : 1,
      };
    }
    
    // Get top percentage for fit message
    final topPct = sizePercentages[item.recommendedSize] ?? 
                   (item.confidenceScore * 100).round();
    
    final result = RecommendationResult(
      productName: item.productName,
      brand: item.brand,
      recommendedSize: item.recommendedSize,
      sizePercentages: sizePercentages,
      fitMessage: "${item.recommendedSize} beden için %$topPct uyumlusunuz",
      warning: "",
      imageUrl: item.imageUrl,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          result: result,
          productUrl: item.productUrl,
          isFromCloset: true,  // Flag to hide "Add to Closet" button
        ),
      ),
    );
  }

  Widget _buildImage(String url, String productName) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Icon(
        IconMapper.getIconForProduct(productName),
        size: 40,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
