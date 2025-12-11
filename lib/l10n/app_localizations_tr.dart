// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Bütçe Akışım';

  @override
  String get welcomeBack => 'Tekrar Hoşgeldiniz';

  @override
  String get joinUsTitle => 'Hemen Aramıza Katıl!';

  @override
  String get joinUsSubtitle =>
      'Gelir ve giderlerini kolayca takip et, hedeflerini koy!';

  @override
  String get createAccountTitle => 'Hesap Oluştur';

  @override
  String get resetPasswordTitle => 'Şifre Sıfırla';

  @override
  String get resetPasswordDescription =>
      'E-posta adresini gir, sana şifreni sıfırlaman için bir bağlantı gönderelim.';

  @override
  String get emailLabel => 'E-posta Adresi';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get passwordConfirmLabel => 'Şifre Tekrar';

  @override
  String get nameLabel => 'Ad';

  @override
  String get surnameLabel => 'Soyad';

  @override
  String get birthDateLabel => 'Doğum Tarihi';

  @override
  String get dateHint => 'GG.AA.YYYY';

  @override
  String get loginButton => 'Giriş Yap';

  @override
  String get registerButton => 'Kayıt Ol';

  @override
  String get sendResetLinkButton => 'Sıfırlama Linki Gönder';

  @override
  String get logoutButton => 'Çıkış Yap';

  @override
  String get forgotPasswordQuestion => 'Şifremi Unuttum?';

  @override
  String get noAccountQuestion => 'Hesabın yok mu?';

  @override
  String get alreadyHaveAccountQuestion => 'Zaten hesabın var mı? Giriş Yap';

  @override
  String get navHome => 'Ana Menü';

  @override
  String get navTransactions => 'İşlemler';

  @override
  String get navCalendar => 'Takvim';

  @override
  String get navGoals => 'Hedefler';

  @override
  String get pageTitleHome => 'Ana Menü';

  @override
  String get pageTitleTransactions => 'İşlemler';

  @override
  String get pageTitleCalendar => 'Takvim';

  @override
  String get pageTitleGoals => 'Hedefler';

  @override
  String get pageTitleProfile => 'Profil';

  @override
  String get pageTitleSettings => 'Ayarlar';

  @override
  String get pageTitleNotifications => 'Bildirimler';

  @override
  String get pageTitleAbout => 'Hakkında';

  @override
  String get errorInvalidEmail => 'Geçerli bir e-posta adresi giriniz.';

  @override
  String get errorEmptyField => 'Bu alan boş bırakılamaz.';

  @override
  String get errorPasswordShort => 'En az 6 karakter olmalı.';

  @override
  String get errorPasswordMismatch => 'Şifreler eşleşmiyor.';

  @override
  String get errorOnlyLetters => 'Sadece harf giriniz.';

  @override
  String get errorLoginGeneral => 'Giriş sırasında bir hata oluştu.';

  @override
  String get errorLoginWrongCredentials =>
      'Hatalı e-posta veya şifre girdiniz.';

  @override
  String get errorRegisterEmailInUse => 'Bu e-posta adresi zaten kullanılıyor.';

  @override
  String get errorRegisterGeneral => 'Kayıt sırasında bir hata oluştu.';

  @override
  String get errorLoadingLanguageSettings =>
      'Dil ayarları yüklenirken bir hata oluştu.';

  @override
  String get successRegister =>
      'Kayıt başarıyla oluşturuldu. Lütfen giriş yapın.';

  @override
  String get successResetEmailSent =>
      'Sıfırlama bağlantısı e-posta adresine gönderildi.\nSpam klasörünü kontrol etmeyi unutma!';

  @override
  String get settingsLanguage => 'Uygulama Dili';

  @override
  String get settingsLanguageTr => 'Türkçe';

  @override
  String get settingsLanguageEn => 'İngilizce';

  @override
  String get settingsTheme => 'Uygulama Teması';

  @override
  String get settingsThemeLight => 'Açık';

  @override
  String get settingsThemeDark => 'Koyu';

  @override
  String errorGeneric(Object error) {
    return 'Bir hata oluştu: $error';
  }
}
