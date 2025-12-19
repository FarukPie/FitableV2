import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'package:size_recommendation_app/l10n/app_localizations.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();
  String? _gender;
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Colors from theme
  static const Color _backgroundColor = Color(0xFF121212);
  static const Color _cardColor = Color(0xFF1E1E1E);
  static const Color _accentColor = Color(0xFF2962FF);
  static const Color _inputFillColor = Color(0xFF252525);
  static const Color _textSecondary = Colors.grey;

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Provider.of<AppProvider>(context, listen: false).register(
        _emailController.text.trim(),
        _passwordController.text,
        _usernameController.text.trim(),
        _fullNameController.text.trim(),
        _gender!,
        int.parse(_ageController.text.trim()),
      );
      
      if (mounted) {
        // Auto-login successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.welcome}! ${AppLocalizations.of(context)!.registrationSuccess}')),
        );
        // We pop the SignupScreen so the user falls back to the main app flow
        // The main AuthGate will see authentication and show the Home/Measure screen.
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.registrationFailed}${e.toString()}'),
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
    final isDesktop = size.width > 900; // Wider breakpoint for signup as it has more fields
    final l10n = AppLocalizations.of(context)!;
    
    // Gender options need to be localized or handled differently if keys vary.
    // For now assuming generic lists or we could use keys if we added them.
    // Let's use the l10n strings if available or hardcode mapped to language.
    // Since we didn't add gender option keys, I'll stick to a simple list but ideally this should be mapped.
    // Wait, let's see if we have gender keys. We have genderMale/genderFemale in existing arb.
    final List<String> genderOptions = [l10n.genderMale, l10n.genderFemale, l10n.genderOther];

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 800),
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
                   // Background Painter
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
                            padding: const EdgeInsets.fromLTRB(40, 40, 40, 40),
                            child: Form(
                              key: _formKey,
                              child: SingleChildScrollView( // Inner scroll for form fields if needed
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      l10n.createAccountTitle,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.joinUsSubtitle,
                                      style: const TextStyle(
                                        color: _textSecondary,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    // Full Name
                                    _buildTextField(
                                      controller: _fullNameController,
                                      hint: l10n.fullNameHint,
                                      icon: Icons.person_outline,
                                      validator: (v) => v?.isEmpty == true ? l10n.requiredError : null,
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Row for Age and Gender
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildTextField(
                                            controller: _ageController,
                                            hint: l10n.ageHint,
                                            icon: Icons.cake_outlined,
                                            inputType: TextInputType.number,
                                            validator: (v) => v?.isEmpty == true ? l10n.requiredError : null,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: DropdownButtonFormField<String>(
                                            dropdownColor: _inputFillColor,
                                            style: const TextStyle(color: Colors.white),
                                            decoration: _inputDecoration(l10n.genderLabel, Icons.people_outline),
                                            value: _gender,
                                            items: genderOptions.map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                            onChanged: (newValue) => setState(() => _gender = newValue),
                                            validator: (val) => val == null ? l10n.requiredError : null,
                                            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Username
                                    _buildTextField(
                                      controller: _usernameController,
                                      hint: l10n.usernameHint,
                                      icon: Icons.alternate_email,
                                      validator: (v) => v?.isEmpty == true ? l10n.requiredError : null,
                                    ),
                                    const SizedBox(height: 16),

                                    // Email
                                    _buildTextField(
                                      controller: _emailController,
                                      hint: l10n.emailHint,
                                      icon: Icons.email_rounded,
                                      inputType: TextInputType.emailAddress,
                                      validator: (v) => v?.isEmpty == true ? l10n.requiredError : null,
                                    ),
                                    const SizedBox(height: 16),

                                    // Password
                                    _buildTextField(
                                      controller: _passwordController,
                                      hint: l10n.passwordHint,
                                      icon: Icons.lock_rounded,
                                      isPassword: true,
                                      isVisible: _isPasswordVisible,
                                      onVisibilityChanged: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                      validator: (v) => (v?.length ?? 0) < 6 ? l10n.passwordMinChars : null,
                                    ),
                                    const SizedBox(height: 16),

                                    // Confirm Password
                                    _buildTextField(
                                      controller: _confirmPasswordController,
                                      hint: l10n.confirmPasswordHint,
                                      icon: Icons.lock_outline,
                                      isPassword: true,
                                      isVisible: _isConfirmPasswordVisible,
                                      onVisibilityChanged: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                                      validator: (v) {
                                        if (v?.isEmpty == true) return l10n.requiredError;
                                        if (v != _passwordController.text) return l10n.passwordMismatch;
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 32),

                                    // Register Button
                                    ElevatedButton(
                                      onPressed: _isLoading ? null : _register,
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
                                              l10n.createAccountButton,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Login Link
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          l10n.alreadyHaveAccount,
                                          style: TextStyle(color: Colors.grey[500], fontSize: 14),
                                        ),
                                        GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: Text(
                                            l10n.logInLink,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // RIGHT PANEL: Decoration
                        if (isDesktop)
                          Expanded(
                            flex: 5, 
                            child: Container(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Spacer(),
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          l10n.joinFitableTitle,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          l10n.joinFitableSubtitle,
                                          textAlign: TextAlign.center,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      obscureText: isPassword && !isVisible,
      keyboardType: inputType,
      decoration: _inputDecoration(hint, icon).copyWith(
        suffixIcon: isPassword
            ? Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Icon(
                    isVisible ? Icons.link_off : Icons.link,
                    color: _accentColor,
                  ),
                  onPressed: onVisibilityChanged,
                ),
              )
            : null,
      ),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: _inputFillColor,
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Icon(icon, color: _accentColor, size: 22),
      ),
      hintText: hint,
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
    );
  }
}

class _BackgroundShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
      
    final path = Path();
    double startX = size.width * 0.45;
    
    path.moveTo(startX, 0);
    path.quadraticBezierTo(startX + 50, size.height * 0.1, startX - 20, size.height * 0.2);
    path.quadraticBezierTo(startX - 60, size.height * 0.35, startX + 20, size.height * 0.5);
    path.quadraticBezierTo(startX + 80, size.height * 0.65, startX - 30, size.height * 0.8);
    path.quadraticBezierTo(startX - 60, size.height * 0.9, startX + 10, size.height);
    
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
