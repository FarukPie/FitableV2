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
  String get welcome => 'Welcome';

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
      'Paste a product link below to get an instant size recommendation based on your body profile.';

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
  String get genderOther => 'Other';

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
  String get chestMeasureGuide =>
      'Measure around the fullest part of your chest, keeping the tape horizontal.';

  @override
  String get handSpanMeasureGuide =>
      'Spread your hand fully. Measure the distance by counting how many spans (thumb to pinky tip) fit the area.';

  @override
  String get chestMeasureGuideMale =>
      'Measure around the fullest part of your chest, under your armpits.';

  @override
  String get chestMeasureGuideFemale =>
      'Measure around the fullest part of your bust.';

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

  @override
  String get helloTitle => 'Hello!';

  @override
  String get signInSubtitle => 'Sign in to your account';

  @override
  String get emailHint => 'E-mail';

  @override
  String get emailRequired => 'Please enter email';

  @override
  String get passwordHint => 'Password';

  @override
  String get passwordRequired => 'Please enter password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get signInButton => 'SIGN IN';

  @override
  String get createAccountButton => 'CREATE ACCOUNT';

  @override
  String get welcomeBackTitle => 'Welcome Back!';

  @override
  String get welcomeBackSubtitle => 'Log in to find your perfect fit.';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get joinUsSubtitle => 'Join us to find your perfect fit';

  @override
  String get fullNameHint => 'Name Surname';

  @override
  String get ageHint => 'Age';

  @override
  String get genderLabel => 'Gender';

  @override
  String get usernameHint => 'Username';

  @override
  String get confirmPasswordHint => 'Confirm Password';

  @override
  String get passwordMismatch => 'Mismatch';

  @override
  String get passwordMinChars => 'Min 6 chars';

  @override
  String get registrationSuccess => 'Registration successful! Please login.';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get logInLink => 'Log In';

  @override
  String get joinFitableTitle => 'Join Fitable!';

  @override
  String get joinFitableSubtitle => 'Start your journey to better fit today.';

  @override
  String get loginFailed => 'Login Failed: ';

  @override
  String get registrationFailed => 'Registration Failed: ';

  @override
  String get autoCalculated => 'Auto Calculated';

  @override
  String get shapeInvertedTriangle => 'Inverted Triangle';

  @override
  String get shapeTriangle => 'Triangle';

  @override
  String get shapeOval => 'Oval';

  @override
  String get shapeRectangular => 'Rectangular';

  @override
  String get invalidCredentials => 'Invalid username or password.';

  @override
  String get errorHistoryLoad => 'Failed to load history.';

  @override
  String get errorMeasurementsLoad => 'Failed to load measurements.';

  @override
  String get errorAccountDelete => 'Failed to delete account.';

  @override
  String get errorLoginGeneric => 'Login failed.';

  @override
  String get errorRegisterGeneric => 'Registration failed.';

  @override
  String get errorUpdateMeasurements => 'Failed to update measurements.';

  @override
  String get errorAddToCloset => 'Failed to add to closet.';

  @override
  String get errorRemoveFromCloset => 'Failed to remove item.';

  @override
  String get errorNetwork => 'Network error. Please try again.';

  @override
  String get errorUnknown => 'An unknown error occurred.';
}
