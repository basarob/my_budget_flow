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
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bütçe Akışım'**
  String get appTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Hoşgeldiniz'**
  String get welcomeBack;

  /// No description provided for @joinUsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hemen Aramıza Katıl!'**
  String get joinUsTitle;

  /// No description provided for @joinUsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Gelir ve giderlerini kolayca takip et, hedeflerini koy!'**
  String get joinUsSubtitle;

  /// No description provided for @createAccountTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Oluştur'**
  String get createAccountTitle;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Sıfırla'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresini gir, sana şifreni sıfırlaman için bir bağlantı gönderelim.'**
  String get resetPasswordDescription;

  /// No description provided for @emailLabel.
  ///
  /// In tr, this message translates to:
  /// **'E-posta Adresi'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get passwordLabel;

  /// No description provided for @passwordConfirmLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şifre Tekrar'**
  String get passwordConfirmLabel;

  /// No description provided for @nameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get nameLabel;

  /// No description provided for @surnameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Soyad'**
  String get surnameLabel;

  /// No description provided for @birthDateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Doğum Tarihi'**
  String get birthDateLabel;

  /// No description provided for @dateHint.
  ///
  /// In tr, this message translates to:
  /// **'GG.AA.YYYY'**
  String get dateHint;

  /// No description provided for @loginButton.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get registerButton;

  /// No description provided for @sendResetLinkButton.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırlama Linki Gönder'**
  String get sendResetLinkButton;

  /// No description provided for @logoutButton.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logoutButton;

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum?'**
  String get forgotPasswordQuestion;

  /// No description provided for @noAccountQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu?'**
  String get noAccountQuestion;

  /// No description provided for @alreadyHaveAccountQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı? Giriş Yap'**
  String get alreadyHaveAccountQuestion;

  /// No description provided for @navHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Menü'**
  String get navHome;

  /// No description provided for @navTransactions.
  ///
  /// In tr, this message translates to:
  /// **'İşlemler'**
  String get navTransactions;

  /// No description provided for @navCalendar.
  ///
  /// In tr, this message translates to:
  /// **'Takvim'**
  String get navCalendar;

  /// No description provided for @navGoals.
  ///
  /// In tr, this message translates to:
  /// **'Hedefler'**
  String get navGoals;

  /// No description provided for @pageTitleHome.
  ///
  /// In tr, this message translates to:
  /// **'Ana Menü'**
  String get pageTitleHome;

  /// No description provided for @pageTitleTransactions.
  ///
  /// In tr, this message translates to:
  /// **'İşlemler'**
  String get pageTitleTransactions;

  /// No description provided for @pageTitleCalendar.
  ///
  /// In tr, this message translates to:
  /// **'Takvim'**
  String get pageTitleCalendar;

  /// No description provided for @pageTitleGoals.
  ///
  /// In tr, this message translates to:
  /// **'Hedefler'**
  String get pageTitleGoals;

  /// No description provided for @pageTitleProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get pageTitleProfile;

  /// No description provided for @pageTitleSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get pageTitleSettings;

  /// No description provided for @pageTitleNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get pageTitleNotifications;

  /// No description provided for @pageTitleAbout.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get pageTitleAbout;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta adresi giriniz.'**
  String get errorInvalidEmail;

  /// No description provided for @errorEmptyField.
  ///
  /// In tr, this message translates to:
  /// **'Bu alan boş bırakılamaz.'**
  String get errorEmptyField;

  /// No description provided for @errorPasswordShort.
  ///
  /// In tr, this message translates to:
  /// **'En az 6 karakter olmalı.'**
  String get errorPasswordShort;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In tr, this message translates to:
  /// **'Şifreler eşleşmiyor.'**
  String get errorPasswordMismatch;

  /// No description provided for @errorOnlyLetters.
  ///
  /// In tr, this message translates to:
  /// **'Sadece harf giriniz.'**
  String get errorOnlyLetters;

  /// No description provided for @errorLoginGeneral.
  ///
  /// In tr, this message translates to:
  /// **'Giriş sırasında bir hata oluştu.'**
  String get errorLoginGeneral;

  /// No description provided for @errorLoginWrongCredentials.
  ///
  /// In tr, this message translates to:
  /// **'Hatalı e-posta veya şifre girdiniz.'**
  String get errorLoginWrongCredentials;

  /// No description provided for @errorRegisterEmailInUse.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta adresi zaten kullanılıyor.'**
  String get errorRegisterEmailInUse;

  /// No description provided for @errorRegisterGeneral.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt sırasında bir hata oluştu.'**
  String get errorRegisterGeneral;

  /// No description provided for @errorLoadingLanguageSettings.
  ///
  /// In tr, this message translates to:
  /// **'Dil ayarları yüklenirken bir hata oluştu.'**
  String get errorLoadingLanguageSettings;

  /// No description provided for @successRegister.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt başarıyla oluşturuldu. Lütfen giriş yapın.'**
  String get successRegister;

  /// No description provided for @successResetEmailSent.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırlama bağlantısı e-posta adresine gönderildi.\nSpam klasörünü kontrol etmeyi unutma!'**
  String get successResetEmailSent;

  /// No description provided for @settingsLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Dili'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageTr.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get settingsLanguageTr;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get settingsLanguageEn;

  /// No description provided for @settingsTheme.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Teması'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In tr, this message translates to:
  /// **'Koyu'**
  String get settingsThemeDark;

  /// No description provided for @tabHistory.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş'**
  String get tabHistory;

  /// No description provided for @tabRecurring.
  ///
  /// In tr, this message translates to:
  /// **'Düzenli'**
  String get tabRecurring;

  /// Hata detayını içeren genel bir hata mesajı.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu: {error}'**
  String errorGeneric(Object error);
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
    'that was used.',
  );
}
