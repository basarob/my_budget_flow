import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/services/auth_service.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/models/recurring_transaction_model.dart';
import '../../transactions/providers/transaction_provider.dart'; // Import for transactionRepositoryProvider

/// Takvim Durumu
///
/// Takvimde seçili günü, odaklanılan ayı ve o aya ait işlemleri tutar.
class CalendarState {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, List<TransactionModel>> monthlyEvents;
  final List<RecurringTransactionModel> activeRecurring;
  final Set<DateTime> loadedMonths; // Önbelleğe alınan aylar (YYYY-MM-01)
  final bool isLoading;
  final bool hasError;

  CalendarState({
    required this.focusedDay,
    this.selectedDay,
    this.monthlyEvents = const {},
    this.activeRecurring = const [],
    this.loadedMonths = const {},
    this.isLoading = false,
    this.hasError = false,
  });

  CalendarState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    Map<DateTime, List<TransactionModel>>? monthlyEvents,
    List<RecurringTransactionModel>? activeRecurring,
    Set<DateTime>? loadedMonths,
    bool? isLoading,
    bool? hasError,
  }) {
    return CalendarState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      monthlyEvents: monthlyEvents ?? this.monthlyEvents,
      activeRecurring: activeRecurring ?? this.activeRecurring,
      loadedMonths: loadedMonths ?? this.loadedMonths,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }

  /// Seçili güne ait gerçek işlemleri döndürür.
  List<TransactionModel> get selectedDayTransactions {
    if (selectedDay == null) return [];
    final normalized = DateTime(
      selectedDay!.year,
      selectedDay!.month,
      selectedDay!.day,
    );
    return monthlyEvents[normalized] ?? [];
  }

  /// Seçili gün için gelecek (yaklaşan) düzenli işlem var mı kontrol eder.
  List<RecurringTransactionModel> get selectedDayUpcoming {
    if (selectedDay == null) return [];
    final now = DateTime.now();
    final selectedNormalized = DateTime(
      selectedDay!.year,
      selectedDay!.month,
      selectedDay!.day,
    );

    // Geçmiş tarihler için yaklaşan ödeme gösterme
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

/// Takvim Kontrolcüsü
///
/// Aylık veri yükleme, gün seçimi ve ay değiştirme işlemlerini yönetir.
class CalendarNotifier extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    // Başlangıçta mevcut ayın verilerini yükle
    Future.microtask(() => loadMonthData(DateTime.now()));
    return CalendarState(focusedDay: DateTime.now());
  }

  /// Belirtilen ayın işlemlerini veritabanından çeker ve gruplar.
  Future<void> loadMonthData(DateTime month) async {
    final monthKey = DateTime(month.year, month.month, 1);

    // Eğer ay daha önce yüklendiyse tekrar çekme (Cache)
    if (state.loadedMonths.contains(monthKey)) {
      // Sadece ayı güncelle, veriye dokunma
      state = state.copyWith(focusedDay: month);
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
      // 1. O aya ait gerçekleşmiş işlemleri çek
      final transactions = await repository.getTransactionsForMonth(
        user.uid,
        month,
      );

      // 2. Aktif düzenli işlemleri çek (Yaklaşan ödemeler için)
      // Not: Düzenli işlemler her seferinde taze çekilebilir veya ayrı bir cache mekanizması kurulabilir.
      // Şimdilik basitlik adına her ay değişiminde güncelini alıyoruz.
      final recurringItems = await repository.getActiveRecurringTransactions(
        user.uid,
      );

      // 3. Mevcut etkinliklerin üzerine yenilerini ekle (Cumulative)
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
        // Tekrarlı eklemeyi önlemek için kontrol (Basit ID kontrolü)
        if (!updatedEvents[normalizedDate]!.any((t) => t.id == tx.id)) {
          updatedEvents[normalizedDate]!.add(tx);
        }
      }

      state = state.copyWith(
        monthlyEvents: updatedEvents,
        activeRecurring: recurringItems,
        loadedMonths: {...state.loadedMonths, monthKey},
        isLoading: false,
        focusedDay: month,
      );
    } catch (e) {
      debugPrint('Takvim veri yükleme hatası: $e');
      state = state.copyWith(isLoading: false, hasError: true);
    }
  }

  /// Hata durumunda yeniden deneme
  void retryLoad() {
    loadMonthData(state.focusedDay);
  }

  /// Kullanıcı takvimde bir güne tıkladığında çağrılır.
  void selectDay(DateTime day) {
    state = state.copyWith(selectedDay: day);
  }

  /// Ay değişikliğinde çağrılır.
  void onPageChanged(DateTime focusedDay) {
    // Sadece ay değiştiyse çalıştır
    if (focusedDay.month != state.focusedDay.month ||
        focusedDay.year != state.focusedDay.year) {
      loadMonthData(focusedDay);
    } else {
      state = state.copyWith(focusedDay: focusedDay);
    }
  }

  /// Belirli bir gün için işlem (event) sayısını döndürür.
  List<TransactionModel> getEventsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return state.monthlyEvents[normalized] ?? [];
  }

  /// Belirli bir günde yaklaşan düzenli ödeme var mı kontrol eder.
  bool hasUpcomingPayment(DateTime day) {
    final now = DateTime.now();
    final dayNormalized = DateTime(day.year, day.month, day.day);
    final todayNormalized = DateTime(now.year, now.month, now.day);

    // Sadece bugün ve sonrası için yaklaşan ödeme kontrolü
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

/// Takvim Provider (Riverpod 2.x)
final calendarProvider = NotifierProvider<CalendarNotifier, CalendarState>(() {
  return CalendarNotifier();
});
