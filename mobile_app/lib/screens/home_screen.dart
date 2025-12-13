import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import 'closet_screen.dart';
import 'measure_form_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // Listen for success state to navigate
    if (provider.result != null && !provider.isLoading) {
      final result = provider.result!; // Capture result before clearing
      final url = _urlController.text; // Capture URL
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Clear result first to prevent loops, then push
        provider.clearResult(); 
        Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(result: result, productUrl: url)));
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fitable"),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network("https://cdn-icons-png.flaticon.com/512/3309/3309995.png", color: Colors.white), // Logo placeholder
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.checkroom_rounded),
            tooltip: "My Closet",
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
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
               Provider.of<AppProvider>(context, listen: false).logout();
            },
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
             "Analyzing Product Details...",
             style: GoogleFonts.outfit(
               fontSize: 20, 
               fontWeight: FontWeight.w600,
               color: Colors.white70
             ),
           ),
           const SizedBox(height: 8),
           const Text(
             "Our AI is finding your perfect fit.",
             style: TextStyle(color: Colors.grey),
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
        const Text(
          "Find Your Perfect Size",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          "Paste a Zara product link below to get an instant size recommendation based on your body profile.",
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
              hintText: "Paste product URL here...",
              prefixIcon: Icon(Icons.link, color: Theme.of(context).primaryColor),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
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
              children: const [
                Icon(Icons.auto_awesome, size: 24),
                SizedBox(width: 12),
                Text("Analyze Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        if (provider.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                   const Icon(Icons.error_outline, color: Colors.red),
                   const SizedBox(width: 12),
                   Expanded(child: Text(provider.error!, style: const TextStyle(color: Colors.redAccent))),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
