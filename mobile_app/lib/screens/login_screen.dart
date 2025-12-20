import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'signup_screen.dart';
import '../utils/error_mapper.dart';
import 'package:size_recommendation_app/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;


  // Colors from requirements & Template
  static const Color _backgroundColor = Color(0xFF121212); // Main Screen BG
  static const Color _cardColor = Color(0xFF1E1E1E); // Card BG
  static const Color _accentColor = Color(0xFF2962FF); // Electric Blue
  static const Color _inputFillColor = Color(0xFF252525); // Slightly lighter than card
  static const Color _textSecondary = Colors.grey;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Provider.of<AppProvider>(context, listen: false).login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      if (mounted) {
        // Show friendly error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorMapper.getErrorMessage(e.toString(), context)),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 850),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 30,
                  offset: Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                   // The Background Painter can span the whole container or just the right side
                   // To achieve the "Cloudy/Wavy" blend, we'll paint on top or behind.
                   // Let's put the painter behind the content.
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _BackgroundShapePainter(),
                    ),
                  ),

                  IntrinsicHeight(
                    child: Row(
                      children: [
                        // LEFT PANEL: Form
                        Expanded(
                          flex: isDesktop ? 4 : 1, 
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(40, isDesktop ? 40 : 100, 40, 40),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    l10n.helloTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Roboto', // Assuming default font
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.signInSubtitle,
                                    style: const TextStyle(
                                      color: _textSecondary,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 48),

                                  // Email Field
                                  TextFormField(
                                    controller: _emailController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: _inputFillColor,
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: const Icon(Icons.email_rounded, color: _accentColor, size: 22),
                                      ),
                                      hintText: l10n.emailHint,
                                      hintStyle: TextStyle(color: Colors.grey[600]),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: _accentColor, width: 1.5),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 20),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) =>
                                        value == null || value.isEmpty ? l10n.emailRequired : null,
                                  ),
                                  const SizedBox(height: 24),

                                  // Password Field
                                  TextFormField(
                                    controller: _passwordController,
                                    style: const TextStyle(color: Colors.white),
                                    obscureText: !_isPasswordVisible,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: _inputFillColor,
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: const Icon(Icons.lock_rounded, color: _accentColor, size: 22),
                                      ),
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: IconButton(
                                          icon: Icon(
                                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off, 
                                            color: _accentColor,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isPasswordVisible = !_isPasswordVisible;
                                            });
                                          },
                                        ),
                                      ),
                                      hintText: l10n.passwordHint,
                                      hintStyle: TextStyle(color: Colors.grey[600]),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(color: _accentColor, width: 1.5),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 20),
                                    ),
                                    validator: (value) =>
                                        value == null || value.isEmpty ? l10n.passwordRequired : null,
                                  ),
                                  const SizedBox(height: 24),


                                  const SizedBox(height: 40),

                                  // Sign In Button
                                  ElevatedButton(
                                    onPressed: _isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _accentColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 8,
                                      shadowColor: _accentColor.withOpacity(0.5),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            l10n.signInButton,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Create Account Button
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      side: const BorderSide(color: Colors.white54, width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text(
                                      l10n.createAccountButton,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),

                                  // OR Divider


                                  // Google Sign In Button

                                ],
                              ),
                            ),
                          ),
                        ),

                        // RIGHT PANEL: Decoration
                        if (isDesktop)
                          Expanded(
                            flex: 5, // Slightly larger right panel as per typical login designs
                            child: Container(
                              // The background is painted by CustomPaint, we just put content here
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end, // Or center
                                children: [
                                  const Spacer(),
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          l10n.welcomeBackTitle,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          l10n.welcomeBackSubtitle,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Language Toggle Buttons
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Row(
                      children: [
                        _buildLanguageButton(context, const Locale('tr'), '🇹🇷'),
                        const SizedBox(width: 12),
                        _buildLanguageButton(context, const Locale('en'), '🇬🇧'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildLanguageButton(BuildContext context, Locale locale, String flag) {
    final currentLocale = Provider.of<AppProvider>(context).locale;
    final isSelected = currentLocale.languageCode == locale.languageCode;
    
    return GestureDetector(
      onTap: () {
        Provider.of<AppProvider>(context, listen: false).setLocale(locale);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? _accentColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: _accentColor, width: 1.5) : Border.all(color: Colors.transparent),
        ),
        child: Text(
          flag,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class _BackgroundShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // This painter draws the wavy separation and the darker right side if needed.
    // Assuming the entire card background is _cardColor (#1E1E1E).
    // The reference image usually shows a distinct shape.
    // Let's assume a diagonal or wavy split where the Right Side is slightly separate or has a gradient.
    
    // We will draw a dark overlay on the right with a wavy edge on the LEFT.
    
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.3) // Darker shade for the wave/right side
      ..style = PaintingStyle.fill;
      
    final path = Path();
    
    // Start from top middleish
    // We want to cover the Right side.
    
    // Coordinates: (x, y)
    // 0,0 is top-left of the CARD.
    
    // Let's say the wave starts at 40% width.
    double startX = size.width * 0.45;
    
    path.moveTo(startX, 0);
    
    // Top to Bottom wave
    // Create multiple curves to mimic the "Cloud" or "Smoke" look
    
    // Curve 1
    path.quadraticBezierTo(
      startX + 50, size.height * 0.1, 
      startX - 20, size.height * 0.2
    );
    
    // Curve 2
    path.quadraticBezierTo(
      startX - 60, size.height * 0.35, 
      startX + 20, size.height * 0.5
    );
    
    // Curve 3
    path.quadraticBezierTo(
      startX + 80, size.height * 0.65, 
      startX - 30, size.height * 0.8
    );
    
    // Curve 4
    path.quadraticBezierTo(
      startX - 60, size.height * 0.9, 
      startX + 10, size.height
    );
    
    // Close the path to the right
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
