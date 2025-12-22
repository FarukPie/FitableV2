import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../models/history_item.dart';
import 'closet_screen.dart';
import 'measure_form_screen.dart';
import 'result_screen.dart';
import 'package:size_recommendation_app/l10n/app_localizations.dart';
import '../utils/error_mapper.dart';
import '../utils/icon_mapper.dart';
import '../utils/name_simplifier.dart';
import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/intro_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _urlController = TextEditingController();
  StreamSubscription? _intentDataStreamSubscription;
  
  @override
  void initState() {
    super.initState();
    // For sharing or opening while app is running in the background
    if (!kIsWeb) {
      _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
        if (value.isNotEmpty && value.first.type == SharedMediaType.text) {
           _handleSharedText(value.first.path);
        }
      }, onError: (err) {
        print("getIntentDataStream error: $err");
      });

      // For sharing or opening while app is closed
      ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
        if (value.isNotEmpty && value.first.type == SharedMediaType.text) {
           _handleSharedText(value.first.path);
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkMandatoryMeasurements();
    });
  }

  Future<void> _checkMandatoryMeasurements() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    // Ensure we have the latest status
    if (!provider.hasMeasurements) {
       // Force navigation to Measure Form
       await Navigator.push(
         context,
         MaterialPageRoute(
             builder: (_) => const MeasureFormScreen(isInitialSetup: true)
         ),
       );
       
       _checkAndShowIntro();
    } else {
       _checkAndShowIntro();
    } 
  }

  Future<void> _checkAndShowIntro() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    // Only show if this is a fresh registration session
    if (!provider.isNewRegistration) return;

    // Using userId for persistence as a fallback
    final userId = provider.userId;
    if (userId == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('intro_shown_$userId') ?? false;

    if (!hasShown) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false, // Force user to click button
          builder: (_) => const IntroDialog(),
        );
        await prefs.setBool('intro_shown_$userId', true);
      }
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  void _handleSharedText(String text) {
    // Basic URL extraction
    // "Check out this product! https://trendyol.com/..."
    final urlRegExp = RegExp(
        r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
    final match = urlRegExp.firstMatch(text);
    if (match != null) {
      setState(() {
        _urlController.text = text.substring(match.start, match.end);
      });
    } else {
       setState(() {
         _urlController.text = text;
       });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // Listen for success state to navigate/show dialog
    if (provider.result != null && !provider.isLoading) {
      final result = provider.result!; // Capture result before clearing
      final url = _urlController.text; // Capture URL
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.clearResult(); // Clear first
        
        // CHECK: Is it a valid clothing item?
        if (result.recommendedSize == "N/A") {
             // Show Popup for Non-Wearable
             _urlController.clear(); // Clear input
             _showNonWearableDialog(context, result.fitMessage);
        } else {
             // Navigate to Result
             _urlController.clear(); 
             Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(result: result, productUrl: url)));
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.checkroom_rounded),
            tooltip: AppLocalizations.of(context)!.myClosetTooltip,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ClosetScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MeasureFormScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: provider.isLoading
              ? _buildLoadingState()
              : _buildInputState(provider),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
     return Center(
       key: const ValueKey("Loading"),
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Lottie.network(
             'https://assets10.lottiefiles.com/packages/lf20_7fwvvesa.json', 
             width: 250, 
             height: 250,
             errorBuilder: (context, error, stack) => const CircularProgressIndicator(),
           ),
           const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)!.analyzingTitle,
              style: GoogleFonts.outfit(
               fontSize: 20, 
               fontWeight: FontWeight.w600,
               color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7)
             ),
           ),
           const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.analyzingSubtitle,
              style: const TextStyle(color: Colors.grey),
           ),
         ],
       ),
     );
  }

  Widget _buildInputState(AppProvider provider) {
    return SingleChildScrollView(
      key: const ValueKey("Input"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title Section
          Text(
            AppLocalizations.of(context)!.homeTitle,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.homeSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 24),
          
          // URL Input Section - Now at top
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: TextField(
              controller: _urlController,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.urlHint,
                prefixIcon: Icon(Icons.link, color: Theme.of(context).primaryColor),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                contentPadding: const EdgeInsets.all(20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Analyze Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (_urlController.text.isNotEmpty) {
                   FocusScope.of(context).unfocus();
                   provider.analyzeProduct(_urlController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, size: 22),
                  const SizedBox(width: 10),
                  Text(AppLocalizations.of(context)!.analyzeButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          
          // Error Message
          if (provider.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Expanded(child: Text(ErrorMapper.getErrorMessage(provider.error!, context), style: const TextStyle(color: Colors.redAccent))),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: provider.clearResult,
                    )
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 32),
          
          // Closet Section
          _buildClosetSection(provider),
        ],
      ),
    );
  }

  Widget _buildClosetSection(AppProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.checkroom_rounded, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context)!.myClosetTitle,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ClosetScreen()),
                  ),
                  child: Text(
                    "Tümünü Gör",
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          
          // Closet Items Preview
          FutureBuilder<List<HistoryItem>>(
            future: provider.fetchHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } 
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.checkroom_outlined, size: 48, color: Colors.grey[600]),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.closetEmpty,
                        style: TextStyle(color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              // Show last 3 items
              final items = snapshot.data!.take(3).toList();
              
              return Column(
                children: [
                  ...items.map((item) => _buildClosetItemPreview(item)),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClosetItemPreview(HistoryItem item) {
    return InkWell(
      onTap: () => _showRecommendationPreview(item),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                IconMapper.getIconForProduct(item.productName),
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    NameSimplifier.simplify(item.productName),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.brand,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            
            // Size Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.recommendedSize,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecommendationPreview(HistoryItem item) {
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
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconMapper.getIconForProduct(item.productName),
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // Brand & Name
              Text(
                item.brand.toUpperCase(),
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11),
              ),
              const SizedBox(height: 6),
              Text(
                NameSimplifier.simplify(item.productName),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Size
              Text(AppLocalizations.of(context)!.recommendedSizeLabel, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(
                item.recommendedSize,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
              ),
              
              const SizedBox(height: 20),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Kapat", style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final url = Uri.parse(item.productUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
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

  void _showNonWearableDialog(BuildContext context, String message) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              const Text("Uyarı"),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
               onPressed: () => Navigator.of(ctx).pop(),
               child: const Text("Tamam", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
  }
}
