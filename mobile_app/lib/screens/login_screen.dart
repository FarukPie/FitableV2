import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:size_recommendation_app/l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import 'signup_screen.dart';

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
      // Navigation is handled by main.dart based on auth state, 
      // but if main doesn't rebuild automatically or we are pushing/popping:
      // In this architecture, main.dart checks 'isAuthenticated'. 
      // So once provider updates, the main wrapper should rebuild if it is listening.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => Provider.of<AppProvider>(context, listen: false).setLocale(const Locale('en')),
                        child: Text("🇬🇧", style: TextStyle(fontSize: 24, color: Localizations.localeOf(context).languageCode == 'en' ? Colors.white : Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () => Provider.of<AppProvider>(context, listen: false).setLocale(const Locale('tr')),
                        child: Text("🇹🇷", style: TextStyle(fontSize: 24, color: Localizations.localeOf(context).languageCode == 'tr' ? Colors.white : Colors.grey)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 60.0), // Space for switcher
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.welcomeBack,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.emailLabel,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value == null || value.isEmpty ? AppLocalizations.of(context)!.emailError : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.passwordLabel,
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) =>
                      value == null || value.isEmpty ? AppLocalizations.of(context)!.passwordError : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(AppLocalizations.of(context)!.loginButton),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.registerLink),
                ),
              ],
            ),
          ),
        ],
      ),
          ),
        ),
      ),
    );
  }
}
