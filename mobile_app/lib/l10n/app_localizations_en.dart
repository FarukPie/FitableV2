// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fitable';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailError => 'Please enter email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordError => 'Please enter password';

  @override
  String get loginButton => 'Login';

  @override
  String get registerLink => 'Don\'t have an account? Register';

  @override
  String get myClosetTooltip => 'My Closet';

  @override
  String get analyzingTitle => 'Analyzing Product Details...';

  @override
  String get analyzingSubtitle => 'Our AI is finding your perfect fit.';

  @override
  String get homeTitle => 'Find Your Perfect Size';

  @override
  String get homeSubtitle =>
      'Paste a Zara product link below to get an instant size recommendation based on your body profile.';

  @override
  String get urlHint => 'Paste product URL here...';

  @override
  String get analyzeButton => 'Analyze Now';
}
