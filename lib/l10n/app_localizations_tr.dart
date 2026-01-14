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
  String get alreadyHaveAccountQuestion => 'Zaten hesabın var mı?';

  @override
  String get navHome => 'Ana Menü';

  @override
  String get navTransactions => 'İşlemler';

  @override
  String get navCalendar => 'Takvim';

  @override
  String get navGoals => 'Hedefler';

  @override
  String get pageTitleHome => 'Bütçe Akışım';

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
  String get errorUserDataNotFound => 'Kullanıcı verisi bulunamadı.';

  @override
  String get errorDataLoad => 'Veri yüklenemedi.';

  @override
  String get retryButton => 'Tekrar Dene';

  @override
  String get successRegister =>
      'Kayıt başarıyla oluşturuldu. Lütfen giriş yapın.';

  @override
  String get successResetEmailSent =>
      'Sıfırlama bağlantısı e-posta adresine gönderildi.\nSpam klasörünü kontrol etmeyi unutma!';

  @override
  String get profileUpdateSuccess => 'Profil başarıyla güncellendi.';

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
  String get tabHistory => 'Geçmiş';

  @override
  String get tabRecurring => 'Düzenli';

  @override
  String get searchHint => 'Ara...';

  @override
  String get filterTitle => 'Filtrele';

  @override
  String get clearAllFilters => 'Hepsini Temizle';

  @override
  String get foundTransactionsPrefix => 'Bulunan işlemler: ';

  @override
  String get showResultsButton => 'Sonuçları Göster';

  @override
  String get transactionTypeHeader => 'İŞLEM TÜRÜ';

  @override
  String get allTransactions => 'Tümü';

  @override
  String get incomeType => 'Gelir';

  @override
  String get expenseType => 'Gider';

  @override
  String get dateHeader => 'TARİH';

  @override
  String get dateToday => 'Bugün';

  @override
  String get dateWeek => 'Bu Hafta';

  @override
  String get dateMonth => 'Bu Ay';

  @override
  String get date3Months => '3 Ay';

  @override
  String get dateCustom => 'Özel Tarih';

  @override
  String get categoriesHeader => 'KATEGORİLER';

  @override
  String get errorCategoriesLoad => 'Kategoriler yüklenemedi';

  @override
  String get addExpenseTitle => 'Gider Ekle';

  @override
  String get addIncomeTitle => 'Gelir Ekle';

  @override
  String get editTransactionTitle => 'İşlemi Düzenle';

  @override
  String get addFromRecurring => 'Düzenliden Ekle';

  @override
  String get errorEnterAmount => 'Tutar giriniz';

  @override
  String get amountLabel => 'Tutar';

  @override
  String get errorInvalidAmount => 'Geçersiz tutar';

  @override
  String get titleHint => 'Başlık (Örn: Market)';

  @override
  String get errorEnterTitle => 'Başlık giriniz';

  @override
  String get categoryLabel => 'Kategori';

  @override
  String get selectLabel => 'Seçiniz';

  @override
  String get dateLabel => 'Tarih';

  @override
  String get addNoteLabel => 'Not Ekle';

  @override
  String get noteHint => 'Notunuzu buraya yazın...';

  @override
  String get categoryFood => 'Gıda';

  @override
  String get categoryBills => 'Fatura';

  @override
  String get categoryTransport => 'Ulaşım';

  @override
  String get categoryRent => 'Kira/Aidat';

  @override
  String get categoryEntertainment => 'Eğlence';

  @override
  String get categoryShopping => 'Alışveriş';

  @override
  String get categorySalary => 'Maaş';

  @override
  String get categoryInvestment => 'Yatırım';

  @override
  String get categoryHealth => ' Sağlık';

  @override
  String get categoryOther => 'Diğer';

  @override
  String get saveButton => 'KAYDET';

  @override
  String get makeRecurringLabel => 'Düzenli İşlem Yap';

  @override
  String get frequencyLabel => 'Sıklık';

  @override
  String get selectCategoryTitle => 'Kategori Seç';

  @override
  String get addNewCategoryTooltip => 'Yeni Kategori Ekle';

  @override
  String get defaultCategoriesTitle => 'Varsayılan Kategoriler';

  @override
  String get userCategoriesTitle => 'Kullanıcı Kategorileri';

  @override
  String get deleteCategoryHint => 'Basılı tutarak silebilirsiniz';

  @override
  String errorMessagePrefix(Object error) {
    return 'Hata: $error';
  }

  @override
  String get addNewCategoryTitle => 'Yeni Kategori Ekle';

  @override
  String get categoryNameLabel => 'Kategori Adı';

  @override
  String get selectColorLabel => 'Renk Seç';

  @override
  String get selectIconLabel => 'İkon Seç';

  @override
  String get cancelButton => 'İptal';

  @override
  String get addButton => 'Ekle';

  @override
  String get deleteButton => 'Sil';

  @override
  String get undoAction => 'Geri Al';

  @override
  String get transactionDeleted => 'İşlem silindi';

  @override
  String get recurringDeleted => 'Düzenli işlem silindi';

  @override
  String get noTransactionsFound => 'İşlem bulunamadı.';

  @override
  String get addTransactionHint =>
      '\"+\" butonu ile yeni bir işlem ekleyebilirsiniz.';

  @override
  String get addRecurringHint =>
      'Kira, fatura gibi işlemlerinizi ekleyebilirsiniz.';

  @override
  String get deleteCategoryTitle => 'Kategoriyi Sil?';

  @override
  String deleteCategoryConfirmMessage(Object category) {
    return '\'$category\' kategorisini silmek istediğinize emin misiniz?';
  }

  @override
  String get frequencyMonthly => 'Aylık';

  @override
  String get frequencyWeekly => 'Haftalık';

  @override
  String get frequencyYearly => 'Yıllık';

  @override
  String get frequencyDaily => 'Günlük';

  @override
  String get recurringDescription =>
      'Bu işlem belirli aralıklarla tekrarlansın.';

  @override
  String get selectRecurringTitle => 'Düzenli İşlem Seç';

  @override
  String get noRecurringFound => 'Düzenli işlem bulunamadı.';

  @override
  String get selectCategoryHint => 'Kategori Seçiniz';

  @override
  String get recurringSwitchLabel => 'Düzenli İşlem';

  @override
  String get descriptionLabel => 'Açıklama';

  @override
  String get updateButton => 'GÜNCELLE';

  @override
  String get noInternetTitle => 'İnternet Bağlantısı Yok';

  @override
  String get noInternetMessage =>
      'Lütfen internet bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get waitingConnection => 'Bağlantı bekleniyor...';

  @override
  String errorAppInit(Object error) {
    return 'Uygulama başlatılamadı: $error';
  }

  @override
  String get commonOk => 'Tamam';

  @override
  String get recurringActivated =>
      'İşlem aktifleştirildi ve vadesi gelen kayıtlar oluşturuldu.';

  @override
  String errorGeneric(Object error) {
    return 'Bir hata oluştu: $error';
  }

  @override
  String get dateRangeTitle => 'Tarih Aralığı';

  @override
  String get dateSelectPlaceholder => 'Seçiniz';

  @override
  String get applySelectionButton => 'Seçimi Uygula';

  @override
  String get shortDayMon => 'Pzt';

  @override
  String get shortDayTue => 'Sal';

  @override
  String get shortDayWed => 'Çar';

  @override
  String get shortDayThu => 'Per';

  @override
  String get shortDayFri => 'Cum';

  @override
  String get shortDaySat => 'Cmt';

  @override
  String get shortDaySun => 'Paz';

  @override
  String get todayButtonTooltip => 'Bugün';

  @override
  String get netBalanceLabel => 'Net';

  @override
  String get plannedTransaction => 'Planlanan İşlemler';

  @override
  String get thisMonthIncome => 'Bu Ayın Geliri';

  @override
  String get thisMonthExpense => 'Bu Ayın Gideri';

  @override
  String get thisMonthNet => 'Bu Ayın Neti';

  @override
  String transactionCount(num count) {
    return '$count İşlem';
  }

  @override
  String get upcomingPaymentLabel => 'Yaklaşan Ödeme';

  @override
  String get recurringPaymentLabel => 'Düzenli Ödeme';

  @override
  String get categoryDeleted => 'Kategori silindi';

  @override
  String get addRecurringTransactionTitle => 'Düzenli İşlem Ekle';

  @override
  String dashboardWelcomeMessage(Object name) {
    return 'Merhaba, $name 👋';
  }

  @override
  String get dashboardNetStatus => 'Net Durum';

  @override
  String get dashboardTotalIncome => 'Gelir';

  @override
  String get dashboardTotalExpense => 'Gider';

  @override
  String get dashboardInvestment => 'Yatırım';

  @override
  String get filterThisWeek => 'Bu Hafta';

  @override
  String get filterThisMonth => 'Bu Ay';

  @override
  String get filterLast30Days => 'Son 30 Gün';

  @override
  String get filterThisYear => 'Bu Yıl';

  @override
  String get chartSpendingDistribution => 'Harcama Dağılımı';

  @override
  String get chartFinancialTrend => 'Finansal Trend';

  @override
  String get goalsPlaceholder => 'Hedefleriniz burada görünecek.';

  @override
  String get goalAddTitle => 'Yeni Hedef Ekle';

  @override
  String get goalEditTitle => 'Hedefi Düzenle';

  @override
  String get goalTargetAmount => 'Hedef Tutar';

  @override
  String get goalCurrentAmount => 'Mevcut Birikim';

  @override
  String get goalDeadline => 'Hedef Tarihi';

  @override
  String get goalTitleLabel => 'Hedef Başlığı';

  @override
  String goalSavedAmount(Object amount) {
    return 'Biriken: $amount';
  }

  @override
  String get addMoneyTitle => 'Para Ekle';

  @override
  String get withdrawMoneyTitle => 'Para Çek';

  @override
  String get goalDeleted => 'Hedef silindi';

  @override
  String get aboutAppDescriptionTitle => 'My Budget Flow Hakkında';

  @override
  String get aboutAppDescription =>
      'Kişisel finans yönetiminizi kolaylaştırmak için tasarlanmış modern bütçe takip uygulaması. Gelir ve giderlerinizi takip edin, hedefler belirleyin ve tasarruf edin.';

  @override
  String get aboutPrivacyTitle => 'Gizlilik ve Güvenlik';

  @override
  String get aboutPrivacyContent =>
      'Verileriniz cihazınızda ve güvenli bulut sunucularımızda şifrelenerek saklanmaktadır. Kişisel verileriniz üçüncü taraflarla asla paylaşılmaz.';

  @override
  String get goalTypeSavings => 'Birikim Hedefi';

  @override
  String get goalTypeExpense => 'Harcama Hedefi';

  @override
  String get selectGoalType => 'Hedef Türünü Seçin';

  @override
  String selectCategories(Object count) {
    return 'Kategorileri Seçin ($count)';
  }

  @override
  String get selectCategoriesError => 'En az 1 kategori seçmelisiniz!';

  @override
  String get startDate => 'Başlangıç Tarihi';

  @override
  String get resetGoal => 'Hedefi Sıfırla';

  @override
  String get resetGoalConfirm =>
      'Hedefi sıfırlamak istediğinize emin misiniz? Başlangıç tarihi bugüne çekilecek.';

  @override
  String get goalReset => 'Hedef sıfırlandı.';

  @override
  String get collected => 'Biriken';

  @override
  String get spent => 'Harcanan';

  @override
  String get remaining => 'Kalan';

  @override
  String get goalRemaining => 'Kalan';

  @override
  String get savingsGoalCompleted => 'Tebrikler, hedefinize ulaştınız! 🎉';

  @override
  String get expenseGoalCompleted =>
      'Harcama hedefinize ulaştınız, dikkat edin! ⚠️';

  @override
  String get goalDescriptionSavings => 'Yatırım ve birikimlerinizi takip edin.';

  @override
  String get goalDescriptionExpense => 'Belirli harcamalar için limit koyun.';

  @override
  String get goalsEmptyTitle => 'Henüz bir hedefiniz yok';

  @override
  String get goalsEmptyMessage =>
      'Finansal özgürlüğünüz için ilk adımı atın! + butonuna basarak yeni bir birikim veya bütçe hedefi oluşturun.';

  @override
  String get errorDefault => 'Bir hata oluştu';

  @override
  String get categoriesLoadError => 'Kategoriler yüklenemedi';
}
