import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Fitable'**
  String get appTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get emailError;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordError.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get passwordError;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @registerLink.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get registerLink;

  /// No description provided for @myClosetTooltip.
  ///
  /// In en, this message translates to:
  /// **'My Closet'**
  String get myClosetTooltip;

  /// No description provided for @analyzingTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Product Details...'**
  String get analyzingTitle;

  /// No description provided for @analyzingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Our AI is finding your perfect fit.'**
  String get analyzingSubtitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Find Your Perfect Size'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paste a Zara product link below to get an instant size recommendation based on your body profile.'**
  String get homeSubtitle;

  /// No description provided for @urlHint.
  ///
  /// In en, this message translates to:
  /// **'Paste product URL here...'**
  String get urlHint;

  /// No description provided for @analyzeButton.
  ///
  /// In en, this message translates to:
  /// **'Analyze Now'**
  String get analyzeButton;

  /// No description provided for @myMeasurementsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Measurements'**
  String get myMeasurementsTitle;

  /// No description provided for @measureWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome! Please enter your measurements to get started.'**
  String get measureWelcome;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @bodyMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Body Measurements'**
  String get bodyMeasurements;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightLabel;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightLabel;

  /// No description provided for @chestLabel.
  ///
  /// In en, this message translates to:
  /// **'Chest Circumference (cm)'**
  String get chestLabel;

  /// No description provided for @waistLabel.
  ///
  /// In en, this message translates to:
  /// **'Waist Circumference (cm)'**
  String get waistLabel;

  /// No description provided for @hipsLabel.
  ///
  /// In en, this message translates to:
  /// **'Hips (cm)'**
  String get hipsLabel;

  /// No description provided for @shoulderLabel.
  ///
  /// In en, this message translates to:
  /// **'Shoulder Circumference (cm)'**
  String get shoulderLabel;

  /// No description provided for @legLengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Leg Length (cm)'**
  String get legLengthLabel;

  /// No description provided for @footLengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Foot Length (cm)'**
  String get footLengthLabel;

  /// No description provided for @completeSetup.
  ///
  /// In en, this message translates to:
  /// **'Complete Setup'**
  String get completeSetup;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @measurementsSaved.
  ///
  /// In en, this message translates to:
  /// **'Measurements Saved!'**
  String get measurementsSaved;

  /// No description provided for @myClosetTitle.
  ///
  /// In en, this message translates to:
  /// **'My Closet'**
  String get myClosetTitle;

  /// No description provided for @closetEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your closet is empty.'**
  String get closetEmpty;

  /// No description provided for @sizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get sizeLabel;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get scoreLabel;

  /// No description provided for @removeItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Item'**
  String get removeItemTitle;

  /// No description provided for @removeItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this item from your closet?'**
  String get removeItemConfirm;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @removeButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeButton;

  /// No description provided for @itemRemoved.
  ///
  /// In en, this message translates to:
  /// **'Item removed.'**
  String get itemRemoved;

  /// No description provided for @removeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove: '**
  String get removeFailed;

  /// No description provided for @requiredError.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredError;

  /// No description provided for @recommendationTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get recommendationTitle;

  /// No description provided for @recommendedSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Recommended Size'**
  String get recommendedSizeLabel;

  /// No description provided for @confidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidenceLabel;

  /// No description provided for @discardButton.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardButton;

  /// No description provided for @addToClosetButton.
  ///
  /// In en, this message translates to:
  /// **'Add to Closet'**
  String get addToClosetButton;

  /// No description provided for @addedToClosetMessage.
  ///
  /// In en, this message translates to:
  /// **'Added to Closet!'**
  String get addedToClosetMessage;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorMessage;

  /// No description provided for @howToMeasureTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Measure'**
  String get howToMeasureTitle;

  /// No description provided for @shoulderMeasureGuide.
  ///
  /// In en, this message translates to:
  /// **'Measure from the tip of one shoulder bone to the other across your back.'**
  String get shoulderMeasureGuide;

  /// No description provided for @waistMeasureGuide.
  ///
  /// In en, this message translates to:
  /// **'Measure around your natural waistline, just above your hips.'**
  String get waistMeasureGuide;

  /// No description provided for @legLengthMeasureGuide.
  ///
  /// In en, this message translates to:
  /// **'Measure from the top of your inner thigh down to your ankle.'**
  String get legLengthMeasureGuide;

  /// No description provided for @footLengthMeasureGuide.
  ///
  /// In en, this message translates to:
  /// **'Measure from your heel to the tip of your longest toe.'**
  String get footLengthMeasureGuide;

  /// No description provided for @handSpanMode.
  ///
  /// In en, this message translates to:
  /// **'No Tape? (Use Hand Span)'**
  String get handSpanMode;

  /// No description provided for @handSpanInfo.
  ///
  /// In en, this message translates to:
  /// **'Based on height, 1 span ≈ {value} cm'**
  String handSpanInfo(Object value);

  /// No description provided for @spansSuffix.
  ///
  /// In en, this message translates to:
  /// **'spans'**
  String get spansSuffix;

  /// No description provided for @enterHeightFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter height to enable hand span mode'**
  String get enterHeightFirst;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
