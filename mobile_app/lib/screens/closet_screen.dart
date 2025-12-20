import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/history_item.dart';
import 'package:size_recommendation_app/l10n/app_localizations.dart';
import '../utils/icon_mapper.dart';
import '../utils/name_simplifier.dart';
import 'package:url_launcher/url_launcher.dart';

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
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1E1E1E),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               // Icon
               Container(
                 height: 100,
                 width: 100,
                 decoration: BoxDecoration(
                   color: Theme.of(context).primaryColor.withOpacity(0.1),
                   shape: BoxShape.circle,
                 ),
                 child: Icon(
                   IconMapper.getIconForProduct(item.productName),
                   size: 50,
                   color: Theme.of(context).primaryColor,
                 ),
               ),
               const SizedBox(height: 16),
               
               // Brand & Name
               Text(
                 item.brand.toUpperCase(),
                 style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
               ),
               const SizedBox(height: 8),
               Text(
                 NameSimplifier.simplify(item.productName),
                 style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                 textAlign: TextAlign.center,
               ),
               const SizedBox(height: 24),
               
               // Recommendation
               Text(AppLocalizations.of(context)!.recommendedSizeLabel, style: const TextStyle(color: Colors.grey)),
               Text(
                 item.recommendedSize,
                 style: TextStyle(
                   fontSize: 42, 
                   fontWeight: FontWeight.bold,
                   color: Theme.of(context).primaryColor,
                 ),
               ),
              const SizedBox(height: 5),
              Text(
                "${AppLocalizations.of(context)!.confidenceLabel}: ${(item.confidenceScore * 100).toStringAsFixed(0)}%",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 30),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   // Close
                   TextButton(
                     onPressed: () => Navigator.pop(context),
                     child: Text(AppLocalizations.of(context)!.cancelButton, style: const TextStyle(color: Colors.grey)),
                   ),
                   // Go to Product
                   ElevatedButton(
                     onPressed: () async {
                        final url = Uri.parse(item.productUrl);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                           try {
                             await launchUrl(url);
                           } catch (e) {
                              if(mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(content: Text("Could not launch: $e")),
                                );
                              }
                           }
                        }
                     },
                     style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                     ),
                     child: Text(AppLocalizations.of(context)?.goToProductButton ?? "Ürüne Git"),
                   ),
                ],
              )
            ],
          ),
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
