import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/services/auth_service.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/models/recurring_transaction_model.dart';
import '../../transactions/providers/transaction_provider.dart';

/// Dosya: calendar_provider.dart
///
/// Takvim ekranının durum yönetimini (State Management) sağlar.
///
/// [Özellikler]
/// - Ay bazlı işlem ve düzenli ödeme verilerini yükler.
/// - Yüklenen ayları önbelleğe (cache) alarak gereksiz ağ trafiğini önler.
/// - Seçili günün işlemlerini ve yaklaşan ödemelerini filtreler.
/// - O Ayın toplam gelir, gider ve net durumunu hesaplar.
///
/// [Performans]
/// - Veriler hafızada tutulduğu için takvim arası geçişler hızlıdır.
/// - Isı haritası (Heatmap) için gerekli hesaplamalar sunucu yerine işlemci tarafında optimize edilmiştir.
class CalendarState {
  /// Odaklanılan Ay (Takvimde hangi ayın görüntülendiği)
  final DateTime focusedDay;

  /// Seçili Gün (Kullanıcının tıkladığı gün)
  final DateTime? selectedDay;

  /// Aya ait tüm işlemler (Gün bazlı haritalanmış)
  /// Key: DateTime (Normalized - 00:00:00), Value: İşlem Listesi
  final Map<DateTime, List<TransactionModel>> monthlyEvents;

  /// Aktif Düzenli İşlemler (Bu ay ve gelecek ödemeler için referans)
  final List<RecurringTransactionModel> activeRecurring;

  /// Önbelleğe Alınan Aylar
  /// Aynı aya tekrar dönüldüğünde sunucuya gitmemek için set içinde tutulur.
  final Set<DateTime> loadedMonths;

  /// Veri yükleniyor mu?
  final bool isLoading;

  /// Yükleme hatası var mı?
  final bool hasError;

  // --- Performans İçin Önceden Hesaplanmış Değerler ---

  /// O ayın toplam geliri
  final double monthlyTotalIncome;

  /// O ayın toplam gideri
  final double monthlyTotalExpense;

  /// Isı Haritası (Heatmap) normalizasyonu için o ayki en yüksek günlük net değişim (Mutlak değer)
  final double maxAbsNetBalance;

  CalendarState({
    required this.focusedDay,
    this.selectedDay,
    this.monthlyEvents = const {},
    this.activeRecurring = const [],
    this.loadedMonths = const {},
    this.isLoading = false,
    this.hasError = false,
    this.monthlyTotalIncome = 0.0,
    this.monthlyTotalExpense = 0.0,
    this.maxAbsNetBalance = 0.0,
  });

  CalendarState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    Map<DateTime, List<TransactionModel>>? monthlyEvents,
    List<RecurringTransactionModel>? activeRecurring,
    Set<DateTime>? loadedMonths,
    bool? isLoading,
    bool? hasError,
    double? monthlyTotalIncome,
    double? monthlyTotalExpense,
    double? maxAbsNetBalance,
  }) {
    return CalendarState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      monthlyEvents: monthlyEvents ?? this.monthlyEvents,
      activeRecurring: activeRecurring ?? this.activeRecurring,
      loadedMonths: loadedMonths ?? this.loadedMonths,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      monthlyTotalIncome: monthlyTotalIncome ?? this.monthlyTotalIncome,
      monthlyTotalExpense: monthlyTotalExpense ?? this.monthlyTotalExpense,
      maxAbsNetBalance: maxAbsNetBalance ?? this.maxAbsNetBalance,
    );
  }

  /// Seçili güne ait işlemleri döndürür.
  List<TransactionModel> get selectedDayTransactions {
    if (selectedDay == null) return [];
    final normalized = DateTime(
      selectedDay!.year,
      selectedDay!.month,
      selectedDay!.day,
    );
    return monthlyEvents[normalized] ?? [];
  }

  /// Seçili güne denk gelen yaklaşan düzenli ödemeleri döndürür.
  List<RecurringTransactionModel> get selectedDayUpcoming {
    if (selectedDay == null) return [];
    final now = DateTime.now();
    final selectedNormalized = DateTime(
      selectedDay!.year,
      selectedDay!.month,
      selectedDay!.day,
    );

    // Geçmiş tarihlerde "Yaklaşan Ödeme" gösterilmez.
    if (selectedNormalized.isBefore(DateTime(now.year, now.month, now.day))) {
      return [];
    }

    return activeRecurring.where((item) {
      final nextDue = item.nextDueDate;
      final nextDueNormalized = DateTime(
        nextDue.year,
        nextDue.month,
        nextDue.day,
      );
      return nextDueNormalized == selectedNormalized;
    }).toList();
  }
}

/// Takvim Yöneticisi (Notifier)
class CalendarNotifier extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    final now = DateTime.now();
    // İlk açılışta mevcut ayı yükle
    Future.microtask(() => loadMonthData(now));
    return CalendarState(focusedDay: now);
  }

  /// Belirtilen ayın verilerini yükler ve istatistikleri hesaplar.
  Future<void> loadMonthData(DateTime month) async {
    final monthKey = DateTime(month.year, month.month, 1);

    // Cache Kontrolü
    if (state.loadedMonths.contains(monthKey)) {
      state = state.copyWith(focusedDay: month);
      // Cache'den o ayın verilerini bulup tekrar hesaplat
      _recalculateForMonth(month);
      return;
    }

    state = state.copyWith(isLoading: true, hasError: false);

    final user = ref.read(authStateChangesProvider).value;
    if (user == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    final repository = ref.read(transactionRepositoryProvider);

    try {
      // 1. Veritabanından o ayın işlemlerini çek
      final transactions = await repository.getTransactionsForMonth(
        user.uid,
        month,
      );

      // 2. Aktif düzenli işlemleri çek (Gelecek tahminleri için)
      final recurringItems = await repository.getActiveRecurringTransactions(
        user.uid,
      );

      // 3. Mevcut olayların (events) üzerine yenilerini ekle
      final Map<DateTime, List<TransactionModel>> updatedEvents = Map.from(
        state.monthlyEvents,
      );

      for (final tx in transactions) {
        final normalizedDate = DateTime(
          tx.date.year,
          tx.date.month,
          tx.date.day,
        );
        updatedEvents.putIfAbsent(normalizedDate, () => []);

        // Mükerrer eklemeyi önle
        if (!updatedEvents[normalizedDate]!.any((t) => t.id == tx.id)) {
          updatedEvents[normalizedDate]!.add(tx);
        }
      }

      // 4. Hesaplamaları yap ve State'i güncelle
      _calculateAndSetState(
        month: month,
        allEvents: updatedEvents,
        recurring: recurringItems,
        newLoadedMonths: {...state.loadedMonths, monthKey},
      );
    } catch (e) {
      debugPrint('Takvim veri yükleme hatası: $e');
      state = state.copyWith(isLoading: false, hasError: true);
    }
  }

  /// Cache'den gelen veriyle o ayın istatistiklerini yeniden hesaplar (Fetch yapmadan)
  void _recalculateForMonth(DateTime month) {
    _calculateAndSetState(
      month: month,
      allEvents: state.monthlyEvents,
      recurring: state.activeRecurring,
      newLoadedMonths: state.loadedMonths,
    );
  }

  /// İstatistikleri hesaplayıp State'i güncelleyen yardımcı metod
  void _calculateAndSetState({
    required DateTime month,
    required Map<DateTime, List<TransactionModel>> allEvents,
    required List<RecurringTransactionModel> recurring,
    required Set<DateTime> newLoadedMonths,
  }) {
    double totalIncome = 0;
    double totalExpense = 0;
    double maxAbsNet = 0;

    // Sadece görüntülenen (focused) aya ait verileri topla
    for (var date in allEvents.keys) {
      if (date.year == month.year && date.month == month.month) {
        final dayEvents = allEvents[date]!;

        double dailyIncome = 0;
        double dailyExpense = 0;

        for (var t in dayEvents) {
          if (t.type == TransactionType.income) {
            dailyIncome += t.amount;
            totalIncome += t.amount;
          } else {
            dailyExpense += t.amount;
            totalExpense += t.amount;
          }
        }

        // Heatmap için max günlük farkı bul
        final absNet = (dailyIncome - dailyExpense).abs();
        if (absNet > maxAbsNet) maxAbsNet = absNet;
      }
    }

    state = state.copyWith(
      monthlyEvents: allEvents,
      activeRecurring: recurring,
      loadedMonths: newLoadedMonths,
      isLoading: false,
      focusedDay: month,
      monthlyTotalIncome: totalIncome,
      monthlyTotalExpense: totalExpense,
      maxAbsNetBalance: maxAbsNet,
    );
  }

  // --- Kullanıcı Etkileşimleri ---

  /// Hata durumunda tekrar dene
  void retryLoad() {
    loadMonthData(state.focusedDay);
  }

  /// Gün seçimi
  void selectDay(DateTime day) {
    state = state.copyWith(selectedDay: day);
  }

  /// Ay değiştiğinde (Page View değişimi)
  void onPageChanged(DateTime focusedDay) {
    if (focusedDay.month != state.focusedDay.month ||
        focusedDay.year != state.focusedDay.year) {
      loadMonthData(focusedDay);
    } else {
      state = state.copyWith(focusedDay: focusedDay);
    }
  }

  // --- Helper Metodlar (UI Tarafı İçin) ---

  /// Takvim kütüphanesi (table_calendar) için event loader
  List<TransactionModel> getEventsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return state.monthlyEvents[normalized] ?? [];
  }

  /// Belirtilen günde yaklaşan bir ödeme var mı? (Marker göstermek için)
  bool hasUpcomingPayment(DateTime day) {
    final now = DateTime.now();
    final dayNormalized = DateTime(day.year, day.month, day.day);
    final todayNormalized = DateTime(now.year, now.month, now.day);

    if (dayNormalized.isBefore(todayNormalized)) return false;

    return state.activeRecurring.any((item) {
      final nextDue = item.nextDueDate;
      final nextDueNormalized = DateTime(
        nextDue.year,
        nextDue.month,
        nextDue.day,
      );
      return nextDueNormalized == dayNormalized;
    });
  }
}

/// Takvim Provider Tanımı
final calendarProvider = NotifierProvider<CalendarNotifier, CalendarState>(() {
  return CalendarNotifier();
});
