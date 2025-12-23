---
trigger: always_on
---

# Teknoloji Yığını ve Mimari

- **Framework**: Flutter
- **Dil**: Dart
- **State Management**: Riverpod 2.x (ConsumerWidget, Notifier, AsyncNotifier, StreamProvider, FutureProvider).
- **Backend**: Firebase (Authentication & Cloud Firestore).
- **Mimari**: Feature-First & Layered Architecture

# Klasör Yapısı (Feature-First)

- Yeni bir özellik eklerken şu yapıyı koru:
  `lib/features/<feature_name>/`
  ├── `models/` (Veri modelleri)
  ├── `repositories/` (Veri erişim katmanı)
  ├── `providers/` (State yönetimi)
  └── `screens/` (UI sayfaları)
  └── `widgets/` (O sayfaya özel widgetlar)

# Veri Katmanı ve Mimari Kuralları

1.  **Repository Pattern**:

    - Veri tabanı işlemleri (Firebase/Firestore) asla UI içinde yapılmaz.
    - Her özellik için bir Repository sınıfı oluştur (örn: `TransactionRepository`, `CategoryRepository`).
    - Repository'lere erişim her zaman `Provider` üzerinden sağlanır (örn: `ref.read(transactionRepositoryProvider)`).

2.  **Model Yapısı**:

    - Tüm modellerde `fromMap` (Firestore'dan okuma) ve `toMap` (Firestore'a yazma) metotları bulunmalıdır.
    - Tarih alanları için `Timestamp` <-> `DateTime` dönüşümlerine dikkat et (`Timestamp.fromDate(...)` ve `(map['date'] as Timestamp).toDate()`).
    - Model sınıfları `final` değişkenlerden oluşmalı ve immutable olmalıdır.

3.  **State Management (Riverpod)**:
    - UI tarafında `ConsumerWidget` veya `ConsumerStatefulWidget` kullan.
    - `ref.watch(provider)` ile state dinle, `ref.read(provider.notifier)` ile fonksiyon tetikle.
    - Asenkron işlemler için `AsyncValue` (data, loading, error) yapısını kullan (`.when` ile UI yönetimi).

# Kodlama Standartları

1.  **UI ve Tema**:

    - Asla hardcoded renk kullanma (örn: `Colors.blue`). Her zaman `core/theme/app_theme.dart` içindeki `AppColors` sınıfını kullan (örn: `AppColors.primary`, `AppColors.expenseRed`).
    - Özel widget'ları tercih et:
      - Butonlar için: `GradientButton`
      - Inputlar için: `CustomTextField`
      - AppBar için: `GradientAppBar`
      - Tıklama animasyonları için: `ScaleButton`
    - Yazı tipleri için `GoogleFonts.inter` kullan.
    - Animasyonlar için `animate_do` paketini kullan. Performans için sadece gerekli görülen yerlerde animasyon kullan.

2.  **Yerelleştirme (Localization)**:

    - Asla hardcoded string kullanma (örn: "Giriş Yap").
    - Her zaman `AppLocalizations.of(context)!` (kısaca `l10n`) kullan.
    - Yeni metinleri `lib/l10n/app_en.arb` ve `app_tr.arb` dosyalarına ekle.

3.  **Yorum Satırları**:
    - Projeye dışardan bakan birisinin yapıyı kolay anlayabilmesi için sınıf ve kritik fonksiyonların başına **Türkçe** açıklama satırları (`///`) ekle.
    - Kod içerisinde **Ingilizce** yorum satırları ekleme.
    - Yeni eklediğin kodların veya eklemelerin yanına bunu belirten yorum satırları ekleme. Bu gereksiz yorum satırı oluyor.
