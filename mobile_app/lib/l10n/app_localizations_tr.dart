// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Fitable';

  @override
  String get welcomeBack => 'Tekrar Hoşgeldiniz';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get emailError => 'Lütfen e-posta giriniz';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get passwordError => 'Lütfen şifre giriniz';

  @override
  String get loginButton => 'Giriş Yap';

  @override
  String get registerLink => 'Hesabınız yok mu? Kaydolun';

  @override
  String get myClosetTooltip => 'Dolabım';

  @override
  String get analyzingTitle => 'Ürün Detayları Analiz Ediliyor...';

  @override
  String get analyzingSubtitle => 'Yapay zekamız en uygun bedeni buluyor.';

  @override
  String get homeTitle => 'Mükemmel Bedeninizi Bulun';

  @override
  String get homeSubtitle =>
      'Vücut profilinize göre anında beden önerisi almak için Zara ürün linkini aşağıya yapıştırın.';

  @override
  String get urlHint => 'Ürün URL\'sini buraya yapıştırın...';

  @override
  String get analyzeButton => 'Analiz Et';
}
