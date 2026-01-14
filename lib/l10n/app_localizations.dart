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
  /// **'Zaten hesabın var mı?'**
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
  /// **'Bütçe Akışım'**
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

  /// No description provided for @errorUserDataNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı verisi bulunamadı.'**
  String get errorUserDataNotFound;

  /// No description provided for @errorDataLoad.
  ///
  /// In tr, this message translates to:
  /// **'Veri yüklenemedi.'**
  String get errorDataLoad;

  /// No description provided for @retryButton.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get retryButton;

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

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Profil başarıyla güncellendi.'**
  String get profileUpdateSuccess;

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

  /// No description provided for @searchHint.
  ///
  /// In tr, this message translates to:
  /// **'Ara...'**
  String get searchHint;

  /// No description provided for @filterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Filtrele'**
  String get filterTitle;

  /// No description provided for @clearAllFilters.
  ///
  /// In tr, this message translates to:
  /// **'Hepsini Temizle'**
  String get clearAllFilters;

  /// No description provided for @foundTransactionsPrefix.
  ///
  /// In tr, this message translates to:
  /// **'Bulunan işlemler: '**
  String get foundTransactionsPrefix;

  /// No description provided for @showResultsButton.
  ///
  /// In tr, this message translates to:
  /// **'Sonuçları Göster'**
  String get showResultsButton;

  /// No description provided for @transactionTypeHeader.
  ///
  /// In tr, this message translates to:
  /// **'İŞLEM TÜRÜ'**
  String get transactionTypeHeader;

  /// No description provided for @allTransactions.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get allTransactions;

  /// No description provided for @incomeType.
  ///
  /// In tr, this message translates to:
  /// **'Gelir'**
  String get incomeType;

  /// No description provided for @expenseType.
  ///
  /// In tr, this message translates to:
  /// **'Gider'**
  String get expenseType;

  /// No description provided for @dateHeader.
  ///
  /// In tr, this message translates to:
  /// **'TARİH'**
  String get dateHeader;

  /// No description provided for @dateToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get dateToday;

  /// No description provided for @dateWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu Hafta'**
  String get dateWeek;

  /// No description provided for @dateMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu Ay'**
  String get dateMonth;

  /// No description provided for @date3Months.
  ///
  /// In tr, this message translates to:
  /// **'3 Ay'**
  String get date3Months;

  /// No description provided for @dateCustom.
  ///
  /// In tr, this message translates to:
  /// **'Özel Tarih'**
  String get dateCustom;

  /// No description provided for @categoriesHeader.
  ///
  /// In tr, this message translates to:
  /// **'KATEGORİLER'**
  String get categoriesHeader;

  /// No description provided for @errorCategoriesLoad.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler yüklenemedi'**
  String get errorCategoriesLoad;

  /// No description provided for @addExpenseTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gider Ekle'**
  String get addExpenseTitle;

  /// No description provided for @addIncomeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gelir Ekle'**
  String get addIncomeTitle;

  /// No description provided for @editTransactionTitle.
  ///
  /// In tr, this message translates to:
  /// **'İşlemi Düzenle'**
  String get editTransactionTitle;

  /// No description provided for @addFromRecurring.
  ///
  /// In tr, this message translates to:
  /// **'Düzenliden Ekle'**
  String get addFromRecurring;

  /// No description provided for @errorEnterAmount.
  ///
  /// In tr, this message translates to:
  /// **'Tutar giriniz'**
  String get errorEnterAmount;

  /// No description provided for @amountLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tutar'**
  String get amountLabel;

  /// No description provided for @errorInvalidAmount.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz tutar'**
  String get errorInvalidAmount;

  /// No description provided for @titleHint.
  ///
  /// In tr, this message translates to:
  /// **'Başlık (Örn: Market)'**
  String get titleHint;

  /// No description provided for @errorEnterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başlık giriniz'**
  String get errorEnterTitle;

  /// No description provided for @categoryLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get categoryLabel;

  /// No description provided for @selectLabel.
  ///
  /// In tr, this message translates to:
  /// **'Seçiniz'**
  String get selectLabel;

  /// No description provided for @dateLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tarih'**
  String get dateLabel;

  /// No description provided for @addNoteLabel.
  ///
  /// In tr, this message translates to:
  /// **'Not Ekle'**
  String get addNoteLabel;

  /// No description provided for @noteHint.
  ///
  /// In tr, this message translates to:
  /// **'Notunuzu buraya yazın...'**
  String get noteHint;

  /// No description provided for @categoryFood.
  ///
  /// In tr, this message translates to:
  /// **'Gıda'**
  String get categoryFood;

  /// No description provided for @categoryBills.
  ///
  /// In tr, this message translates to:
  /// **'Fatura'**
  String get categoryBills;

  /// No description provided for @categoryTransport.
  ///
  /// In tr, this message translates to:
  /// **'Ulaşım'**
  String get categoryTransport;

  /// No description provided for @categoryRent.
  ///
  /// In tr, this message translates to:
  /// **'Kira/Aidat'**
  String get categoryRent;

  /// No description provided for @categoryEntertainment.
  ///
  /// In tr, this message translates to:
  /// **'Eğlence'**
  String get categoryEntertainment;

  /// No description provided for @categoryShopping.
  ///
  /// In tr, this message translates to:
  /// **'Alışveriş'**
  String get categoryShopping;

  /// No description provided for @categorySalary.
  ///
  /// In tr, this message translates to:
  /// **'Maaş'**
  String get categorySalary;

  /// No description provided for @categoryInvestment.
  ///
  /// In tr, this message translates to:
  /// **'Yatırım'**
  String get categoryInvestment;

  /// No description provided for @categoryHealth.
  ///
  /// In tr, this message translates to:
  /// **' Sağlık'**
  String get categoryHealth;

  /// No description provided for @categoryOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get categoryOther;

  /// No description provided for @saveButton.
  ///
  /// In tr, this message translates to:
  /// **'KAYDET'**
  String get saveButton;

  /// No description provided for @makeRecurringLabel.
  ///
  /// In tr, this message translates to:
  /// **'Düzenli İşlem Yap'**
  String get makeRecurringLabel;

  /// No description provided for @frequencyLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sıklık'**
  String get frequencyLabel;

  /// No description provided for @selectCategoryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Seç'**
  String get selectCategoryTitle;

  /// No description provided for @addNewCategoryTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kategori Ekle'**
  String get addNewCategoryTooltip;

  /// No description provided for @defaultCategoriesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Varsayılan Kategoriler'**
  String get defaultCategoriesTitle;

  /// No description provided for @userCategoriesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Kategorileri'**
  String get userCategoriesTitle;

  /// No description provided for @deleteCategoryHint.
  ///
  /// In tr, this message translates to:
  /// **'Basılı tutarak silebilirsiniz'**
  String get deleteCategoryHint;

  /// No description provided for @errorMessagePrefix.
  ///
  /// In tr, this message translates to:
  /// **'Hata: {error}'**
  String errorMessagePrefix(Object error);

  /// No description provided for @addNewCategoryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Kategori Ekle'**
  String get addNewCategoryTitle;

  /// No description provided for @categoryNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Adı'**
  String get categoryNameLabel;

  /// No description provided for @selectColorLabel.
  ///
  /// In tr, this message translates to:
  /// **'Renk Seç'**
  String get selectColorLabel;

  /// No description provided for @selectIconLabel.
  ///
  /// In tr, this message translates to:
  /// **'İkon Seç'**
  String get selectIconLabel;

  /// No description provided for @cancelButton.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancelButton;

  /// No description provided for @addButton.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get addButton;

  /// No description provided for @deleteButton.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get deleteButton;

  /// No description provided for @undoAction.
  ///
  /// In tr, this message translates to:
  /// **'Geri Al'**
  String get undoAction;

  /// No description provided for @transactionDeleted.
  ///
  /// In tr, this message translates to:
  /// **'İşlem silindi'**
  String get transactionDeleted;

  /// No description provided for @recurringDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Düzenli işlem silindi'**
  String get recurringDeleted;

  /// No description provided for @noTransactionsFound.
  ///
  /// In tr, this message translates to:
  /// **'İşlem bulunamadı.'**
  String get noTransactionsFound;

  /// No description provided for @addTransactionHint.
  ///
  /// In tr, this message translates to:
  /// **'\"+\" butonu ile yeni bir işlem ekleyebilirsiniz.'**
  String get addTransactionHint;

  /// No description provided for @addRecurringHint.
  ///
  /// In tr, this message translates to:
  /// **'Kira, fatura gibi işlemlerinizi ekleyebilirsiniz.'**
  String get addRecurringHint;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriyi Sil?'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryConfirmMessage.
  ///
  /// In tr, this message translates to:
  /// **'\'{category}\' kategorisini silmek istediğinize emin misiniz?'**
  String deleteCategoryConfirmMessage(Object category);

  /// No description provided for @frequencyMonthly.
  ///
  /// In tr, this message translates to:
  /// **'Aylık'**
  String get frequencyMonthly;

  /// No description provided for @frequencyWeekly.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık'**
  String get frequencyWeekly;

  /// No description provided for @frequencyYearly.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık'**
  String get frequencyYearly;

  /// No description provided for @frequencyDaily.
  ///
  /// In tr, this message translates to:
  /// **'Günlük'**
  String get frequencyDaily;

  /// No description provided for @recurringDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem belirli aralıklarla tekrarlansın.'**
  String get recurringDescription;

  /// No description provided for @selectRecurringTitle.
  ///
  /// In tr, this message translates to:
  /// **'Düzenli İşlem Seç'**
  String get selectRecurringTitle;

  /// No description provided for @noRecurringFound.
  ///
  /// In tr, this message translates to:
  /// **'Düzenli işlem bulunamadı.'**
  String get noRecurringFound;

  /// No description provided for @selectCategoryHint.
  ///
  /// In tr, this message translates to:
  /// **'Kategori Seçiniz'**
  String get selectCategoryHint;

  /// No description provided for @recurringSwitchLabel.
  ///
  /// In tr, this message translates to:
  /// **'Düzenli İşlem'**
  String get recurringSwitchLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama'**
  String get descriptionLabel;

  /// No description provided for @updateButton.
  ///
  /// In tr, this message translates to:
  /// **'GÜNCELLE'**
  String get updateButton;

  /// No description provided for @noInternetTitle.
  ///
  /// In tr, this message translates to:
  /// **'İnternet Bağlantısı Yok'**
  String get noInternetTitle;

  /// No description provided for @noInternetMessage.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen internet bağlantınızı kontrol edip tekrar deneyin.'**
  String get noInternetMessage;

  /// No description provided for @waitingConnection.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı bekleniyor...'**
  String get waitingConnection;

  /// No description provided for @errorAppInit.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama başlatılamadı: {error}'**
  String errorAppInit(Object error);

  /// No description provided for @commonOk.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get commonOk;

  /// No description provided for @recurringActivated.
  ///
  /// In tr, this message translates to:
  /// **'İşlem aktifleştirildi ve vadesi gelen kayıtlar oluşturuldu.'**
  String get recurringActivated;

  /// Hata detayını içeren genel bir hata mesajı.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu: {error}'**
  String errorGeneric(Object error);

  /// No description provided for @dateRangeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tarih Aralığı'**
  String get dateRangeTitle;

  /// No description provided for @dateSelectPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Seçiniz'**
  String get dateSelectPlaceholder;

  /// No description provided for @applySelectionButton.
  ///
  /// In tr, this message translates to:
  /// **'Seçimi Uygula'**
  String get applySelectionButton;

  /// No description provided for @shortDayMon.
  ///
  /// In tr, this message translates to:
  /// **'Pzt'**
  String get shortDayMon;

  /// No description provided for @shortDayTue.
  ///
  /// In tr, this message translates to:
  /// **'Sal'**
  String get shortDayTue;

  /// No description provided for @shortDayWed.
  ///
  /// In tr, this message translates to:
  /// **'Çar'**
  String get shortDayWed;

  /// No description provided for @shortDayThu.
  ///
  /// In tr, this message translates to:
  /// **'Per'**
  String get shortDayThu;

  /// No description provided for @shortDayFri.
  ///
  /// In tr, this message translates to:
  /// **'Cum'**
  String get shortDayFri;

  /// No description provided for @shortDaySat.
  ///
  /// In tr, this message translates to:
  /// **'Cmt'**
  String get shortDaySat;

  /// No description provided for @shortDaySun.
  ///
  /// In tr, this message translates to:
  /// **'Paz'**
  String get shortDaySun;

  /// No description provided for @todayButtonTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get todayButtonTooltip;

  /// No description provided for @netBalanceLabel.
  ///
  /// In tr, this message translates to:
  /// **'Net'**
  String get netBalanceLabel;

  /// No description provided for @plannedTransaction.
  ///
  /// In tr, this message translates to:
  /// **'Planlanan İşlemler'**
  String get plannedTransaction;

  /// No description provided for @thisMonthIncome.
  ///
  /// In tr, this message translates to:
  /// **'Bu Ayın Geliri'**
  String get thisMonthIncome;

  /// No description provided for @thisMonthExpense.
  ///
  /// In tr, this message translates to:
  /// **'Bu Ayın Gideri'**
  String get thisMonthExpense;

  /// No description provided for @thisMonthNet.
  ///
  /// In tr, this message translates to:
  /// **'Bu Ayın Neti'**
  String get thisMonthNet;

  /// No description provided for @transactionCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} İşlem'**
  String transactionCount(num count);

  /// No description provided for @upcomingPaymentLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan Ödeme'**
  String get upcomingPaymentLabel;

  /// No description provided for @recurringPaymentLabel.
  ///
  /// In tr, this message translates to:
  /// **'Düzenli Ödeme'**
  String get recurringPaymentLabel;

  /// No description provided for @categoryDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Kategori silindi'**
  String get categoryDeleted;

  /// No description provided for @addRecurringTransactionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Düzenli İşlem Ekle'**
  String get addRecurringTransactionTitle;

  /// No description provided for @dashboardWelcomeMessage.
  ///
  /// In tr, this message translates to:
  /// **'Merhaba, {name} 👋'**
  String dashboardWelcomeMessage(Object name);

  /// No description provided for @dashboardNetStatus.
  ///
  /// In tr, this message translates to:
  /// **'Net Durum'**
  String get dashboardNetStatus;

  /// No description provided for @dashboardTotalIncome.
  ///
  /// In tr, this message translates to:
  /// **'Gelir'**
  String get dashboardTotalIncome;

  /// No description provided for @dashboardTotalExpense.
  ///
  /// In tr, this message translates to:
  /// **'Gider'**
  String get dashboardTotalExpense;

  /// No description provided for @dashboardInvestment.
  ///
  /// In tr, this message translates to:
  /// **'Yatırım'**
  String get dashboardInvestment;

  /// No description provided for @filterThisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu Hafta'**
  String get filterThisWeek;

  /// No description provided for @filterThisMonth.
  ///
  /// In tr, this message translates to:
  /// **'Bu Ay'**
  String get filterThisMonth;

  /// No description provided for @filterLast30Days.
  ///
  /// In tr, this message translates to:
  /// **'Son 30 Gün'**
  String get filterLast30Days;

  /// No description provided for @filterThisYear.
  ///
  /// In tr, this message translates to:
  /// **'Bu Yıl'**
  String get filterThisYear;

  /// No description provided for @chartSpendingDistribution.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Dağılımı'**
  String get chartSpendingDistribution;

  /// No description provided for @chartFinancialTrend.
  ///
  /// In tr, this message translates to:
  /// **'Finansal Trend'**
  String get chartFinancialTrend;

  /// No description provided for @goalsPlaceholder.
  ///
  /// In tr, this message translates to:
  /// **'Hedefleriniz burada görünecek.'**
  String get goalsPlaceholder;

  /// No description provided for @goalAddTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Hedef Ekle'**
  String get goalAddTitle;

  /// No description provided for @goalEditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hedefi Düzenle'**
  String get goalEditTitle;

  /// No description provided for @goalTargetAmount.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Tutar'**
  String get goalTargetAmount;

  /// No description provided for @goalCurrentAmount.
  ///
  /// In tr, this message translates to:
  /// **'Mevcut Birikim'**
  String get goalCurrentAmount;

  /// No description provided for @goalDeadline.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Tarihi'**
  String get goalDeadline;

  /// No description provided for @goalTitleLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Başlığı'**
  String get goalTitleLabel;

  /// No description provided for @goalSavedAmount.
  ///
  /// In tr, this message translates to:
  /// **'Biriken: {amount}'**
  String goalSavedAmount(Object amount);

  /// No description provided for @addMoneyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Para Ekle'**
  String get addMoneyTitle;

  /// No description provided for @withdrawMoneyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Para Çek'**
  String get withdrawMoneyTitle;

  /// No description provided for @goalDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Hedef silindi'**
  String get goalDeleted;

  /// No description provided for @aboutAppDescriptionTitle.
  ///
  /// In tr, this message translates to:
  /// **'My Budget Flow Hakkında'**
  String get aboutAppDescriptionTitle;

  /// No description provided for @aboutAppDescription.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel finans yönetiminizi kolaylaştırmak için tasarlanmış modern bütçe takip uygulaması. Gelir ve giderlerinizi takip edin, hedefler belirleyin ve tasarruf edin.'**
  String get aboutAppDescription;

  /// No description provided for @aboutPrivacyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik ve Güvenlik'**
  String get aboutPrivacyTitle;

  /// No description provided for @aboutPrivacyContent.
  ///
  /// In tr, this message translates to:
  /// **'Verileriniz cihazınızda ve güvenli bulut sunucularımızda şifrelenerek saklanmaktadır. Kişisel verileriniz üçüncü taraflarla asla paylaşılmaz.'**
  String get aboutPrivacyContent;

  /// No description provided for @goalTypeSavings.
  ///
  /// In tr, this message translates to:
  /// **'Birikim Hedefi'**
  String get goalTypeSavings;

  /// No description provided for @goalTypeExpense.
  ///
  /// In tr, this message translates to:
  /// **'Harcama Hedefi'**
  String get goalTypeExpense;

  /// No description provided for @selectGoalType.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Türünü Seçin'**
  String get selectGoalType;

  /// No description provided for @selectCategories.
  ///
  /// In tr, this message translates to:
  /// **'Kategorileri Seçin ({count})'**
  String selectCategories(Object count);

  /// No description provided for @selectCategoriesError.
  ///
  /// In tr, this message translates to:
  /// **'En az 1 kategori seçmelisiniz!'**
  String get selectCategoriesError;

  /// No description provided for @startDate.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç Tarihi'**
  String get startDate;

  /// No description provided for @resetGoal.
  ///
  /// In tr, this message translates to:
  /// **'Hedefi Sıfırla'**
  String get resetGoal;

  /// No description provided for @resetGoalConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Hedefi sıfırlamak istediğinize emin misiniz? Başlangıç tarihi bugüne çekilecek.'**
  String get resetGoalConfirm;

  /// No description provided for @goalReset.
  ///
  /// In tr, this message translates to:
  /// **'Hedef sıfırlandı.'**
  String get goalReset;

  /// No description provided for @collected.
  ///
  /// In tr, this message translates to:
  /// **'Biriken'**
  String get collected;

  /// No description provided for @spent.
  ///
  /// In tr, this message translates to:
  /// **'Harcanan'**
  String get spent;

  /// No description provided for @remaining.
  ///
  /// In tr, this message translates to:
  /// **'Kalan'**
  String get remaining;

  /// No description provided for @goalRemaining.
  ///
  /// In tr, this message translates to:
  /// **'Kalan'**
  String get goalRemaining;

  /// No description provided for @savingsGoalCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Tebrikler, hedefinize ulaştınız! 🎉'**
  String get savingsGoalCompleted;

  /// No description provided for @expenseGoalCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Harcama hedefinize ulaştınız, dikkat edin! ⚠️'**
  String get expenseGoalCompleted;

  /// No description provided for @goalDescriptionSavings.
  ///
  /// In tr, this message translates to:
  /// **'Yatırım ve birikimlerinizi takip edin.'**
  String get goalDescriptionSavings;

  /// No description provided for @goalDescriptionExpense.
  ///
  /// In tr, this message translates to:
  /// **'Belirli harcamalar için limit koyun.'**
  String get goalDescriptionExpense;

  /// No description provided for @goalsEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bir hedefiniz yok'**
  String get goalsEmptyTitle;

  /// No description provided for @goalsEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Finansal özgürlüğünüz için ilk adımı atın! + butonuna basarak yeni bir birikim veya bütçe hedefi oluşturun.'**
  String get goalsEmptyMessage;

  /// No description provided for @errorDefault.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu'**
  String get errorDefault;

  /// No description provided for @categoriesLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler yüklenemedi'**
  String get categoriesLoadError;
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
