import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import 'closet_screen.dart';
import 'measure_form_screen.dart';
import 'result_screen.dart';
import 'package:size_recommendation_app/l10n/app_localizations.dart';
import '../utils/error_mapper.dart';
import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/intro_dialog.dart';
import 'package:flutter/foundation.dart';

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
    return Column(
      key: const ValueKey("Input"),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.homeTitle,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.homeSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
        ),
        const SizedBox(height: 48),
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
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              if (_urlController.text.isNotEmpty) {
                 // Close keyboard
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
                Icon(Icons.auto_awesome, size: 24),
                SizedBox(width: 12),
                const SizedBox(width: 12),
                Text(AppLocalizations.of(context)!.analyzeButton, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        if (provider.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.redAccent.withOpacity(0.1),
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
      ],
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
