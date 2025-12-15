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

  @override
  String get myMeasurementsTitle => 'Ölçülerim';

  @override
  String get measureWelcome =>
      'Hoşgeldiniz! Başlamak için lütfen ölçülerinizi girin.';

  @override
  String get personalDetails => 'Kişisel Bilgiler';

  @override
  String get bodyMeasurements => 'Vücut Ölçüleri';

  @override
  String get bodyShapeTitle => 'Vücut Tipi';

  @override
  String get genderMale => 'Erkek';

  @override
  String get genderFemale => 'Kadın';

  @override
  String get heightLabel => 'Boy (cm)';

  @override
  String get weightLabel => 'Kilo (kg)';

  @override
  String get chestLabel => 'Göğüs Çevresi (cm)';

  @override
  String get waistLabel => 'Bel Çevresi (cm)';

  @override
  String get hipsLabel => 'Basen (cm)';

  @override
  String get shoulderLabel => 'Omuz Çevresi (cm)';

  @override
  String get legLengthLabel => 'Bacak Uzunluğu (cm)';

  @override
  String get footLengthLabel => 'Ayak Uzunluğu (cm)';

  @override
  String get completeSetup => 'Kurulumu Tamamla';

  @override
  String get updateProfile => 'Profili Güncelle';

  @override
  String get measurementsSaved => 'Ölçüler Kaydedildi!';

  @override
  String get myClosetTitle => 'Dolabım';

  @override
  String get closetEmpty => 'Dolabınız boş.';

  @override
  String get sizeLabel => 'Beden';

  @override
  String get scoreLabel => 'Skor';

  @override
  String get removeItemTitle => 'Ürünü Kaldır';

  @override
  String get removeItemConfirm =>
      'Bu ürünü dolabınızdan kaldırmak istediğinize emin misiniz?';

  @override
  String get cancelButton => 'İptal';

  @override
  String get removeButton => 'Kaldır';

  @override
  String get itemRemoved => 'Ürün kaldırıldı.';

  @override
  String get removeFailed => 'Kaldırılamadı: ';

  @override
  String get requiredError => 'Bu alan gerekli';

  @override
  String get recommendationTitle => 'Beden Önerisi';

  @override
  String get recommendedSizeLabel => 'Önerilen Beden';

  @override
  String get confidenceLabel => 'Güven Oranı';

  @override
  String get discardButton => 'Çöpe At';

  @override
  String get addToClosetButton => 'Dolabıma Koy';

  @override
  String get addedToClosetMessage => 'Dolaba Eklendi!';

  @override
  String get errorMessage => 'Hata';

  @override
  String get howToMeasureTitle => 'Nasıl Ölçülür?';

  @override
  String get shoulderMeasureGuide =>
      'Sırtınızdan, bir omuz kemiğinin ucundan diğerine ölçün.';

  @override
  String get waistMeasureGuide =>
      'Doğal bel çevrenizi, kalçanızın hemen üzerinden ölçün.';

  @override
  String get legLengthMeasureGuide =>
      'İç bacağınızın en üst kısmından ayak bileğinize kadar ölçün.';

  @override
  String get footLengthMeasureGuide =>
      'Topuğunuzdan en uzun parmağınızın ucuna kadar ölçün.';

  @override
  String get handSpanMode => 'Mezuram Yok (Karış Hesabı)';

  @override
  String handSpanInfo(Object value) {
    return 'Boyunuza göre 1 karış ≈ $value cm';
  }

  @override
  String get spansSuffix => 'karış';

  @override
  String get enterHeightFirst =>
      'Karış hesabını açmak için önce boyunuzu girin';
}
