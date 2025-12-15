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

  @override
  String get myMeasurementsTitle => 'My Measurements';

  @override
  String get measureWelcome =>
      'Welcome! Please enter your measurements to get started.';

  @override
  String get personalDetails => 'Personal Details';

  @override
  String get bodyMeasurements => 'Body Measurements';

  @override
  String get bodyShapeTitle => 'Body Shape';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get heightLabel => 'Height (cm)';

  @override
  String get weightLabel => 'Weight (kg)';

  @override
  String get chestLabel => 'Chest Circumference (cm)';

  @override
  String get waistLabel => 'Waist Circumference (cm)';

  @override
  String get hipsLabel => 'Hips (cm)';

  @override
  String get shoulderLabel => 'Shoulder Circumference (cm)';

  @override
  String get legLengthLabel => 'Leg Length (cm)';

  @override
  String get footLengthLabel => 'Foot Length (cm)';

  @override
  String get completeSetup => 'Complete Setup';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get measurementsSaved => 'Measurements Saved!';

  @override
  String get myClosetTitle => 'My Closet';

  @override
  String get closetEmpty => 'Your closet is empty.';

  @override
  String get sizeLabel => 'Size';

  @override
  String get scoreLabel => 'Score';

  @override
  String get removeItemTitle => 'Remove Item';

  @override
  String get removeItemConfirm =>
      'Are you sure you want to remove this item from your closet?';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get removeButton => 'Remove';

  @override
  String get itemRemoved => 'Item removed.';

  @override
  String get removeFailed => 'Failed to remove: ';

  @override
  String get requiredError => 'This field is required';

  @override
  String get recommendationTitle => 'Recommendation';

  @override
  String get recommendedSizeLabel => 'Recommended Size';

  @override
  String get confidenceLabel => 'Confidence';

  @override
  String get discardButton => 'Discard';

  @override
  String get addToClosetButton => 'Add to Closet';

  @override
  String get addedToClosetMessage => 'Added to Closet!';

  @override
  String get errorMessage => 'Error';

  @override
  String get howToMeasureTitle => 'How to Measure';

  @override
  String get shoulderMeasureGuide =>
      'Measure from the tip of one shoulder bone to the other across your back.';

  @override
  String get waistMeasureGuide =>
      'Measure around your natural waistline, just above your hips.';

  @override
  String get legLengthMeasureGuide =>
      'Measure from the top of your inner thigh down to your ankle.';

  @override
  String get footLengthMeasureGuide =>
      'Measure from your heel to the tip of your longest toe.';

  @override
  String get handSpanMode => 'No Tape? (Use Hand Span)';

  @override
  String handSpanInfo(Object value) {
    return 'Based on height, 1 span ≈ $value cm';
  }

  @override
  String get spansSuffix => 'spans';

  @override
  String get enterHeightFirst => 'Enter height to enable hand span mode';
}
