import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // HapticFeedback için
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/calendar_provider.dart';
import '../widgets/day_summary_card.dart';
import '../widgets/daily_transaction_list.dart';
import '../../transactions/providers/category_provider.dart';
import '../../transactions/models/transaction_model.dart';
import '../../../core/widgets/glass_container.dart';

/// Takvim Ekranı
///
/// Kullanıcının aylık finansal görünümünü sunar.
///
/// Özellikler:
/// - **Aylık Özet:** Seçili ayın toplam gelir, gider ve net durumunu gösterir.
/// - **Isı Haritası (Heatmap):** Takvim üzerinde günlerin yoğunluğunu renklerle belirtir.
/// - **İşlem Listesi:** Seçilen güne ait işlemleri listeler.
/// - **Yaklaşan Ödemeler:** Düzenli ödemelerin vadesi geldiğinde takvimde işaretler.
///
/// Performans Notu:
/// - Aylık hesaplamalar `CalendarProvider` tarafında yapıldığı için `UI build` metodu hafiftir.
/// - Gereksiz hesaplama ve döngülerden arındırılmıştır.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // Provider'dan durumu dinle (Hesaplanmış verilerle gelir)
    final calendarState = ref.watch(calendarProvider);
    final notifier = ref.read(calendarProvider.notifier);

    // Kategori listesi (İşlem listesinde ikon/renk göstermek için)
    final categoriesAsync = ref.watch(categoryListProvider);

    // 1. Hata Durumu Kontrolü
    if (calendarState.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.expenseRed),
            const SizedBox(height: 16),
            Text(l10n.errorGeneric('Veri yüklenemedi')),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: notifier.retryLoad,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                // 2. Takvim ve Üst Özet Kartı
                GlassContainer(
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // A. Aylık Özet Başlığı (Provider'dan hazır veri)
                      _buildMonthlySummaryHeader(
                        context,
                        l10n,
                        calendarState.monthlyTotalIncome,
                        calendarState.monthlyTotalExpense,
                      ),

                      // B. Takvim Bileşeni
                      _buildCalendar(
                        context,
                        ref,
                        calendarState,
                        l10n,
                        notifier,
                        calendarState.maxAbsNetBalance,
                      ),
                    ],
                  ),
                ),

                // 3. Yükleme Çubuğu (Loading Indicator)
                if (calendarState.isLoading)
                  const LinearProgressIndicator(minHeight: 2),

                // 4. Gün Detay Alanı (Dolu veya Boş Durum)
                if (calendarState.selectedDay != null) ...[
                  // A. Günlük Özet Kartı
                  DaySummaryCard(
                    transactions: calendarState.selectedDayTransactions,
                    upcomingPayments: calendarState.selectedDayUpcoming,
                  ),

                  // B. Seçili Gün Başlığı ve Sayısı
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Text(
                          DateFormat.yMMMMEEEEd(
                            l10n.localeName,
                          ).format(calendarState.selectedDay!),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _getEventCountText(calendarState, l10n),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // C. İşlem Listesi
                  categoriesAsync.when(
                    data: (categories) => DailyTransactionList(
                      transactions: calendarState.selectedDayTransactions,
                      upcomingPayments: calendarState.selectedDayUpcoming,
                      categories: categories,
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, s) =>
                        Center(child: Text(l10n.errorCategoriesLoad)),
                  ),

                  // Liste sonu boşluğu (Bottom bar altında kalmaması için)
                  const SizedBox(height: 80),
                ] else
                  // Gün seçilmediyse kullanıcıyı yönlendiren placeholder
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 48,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.dateSelectPlaceholder,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Seçili gündeki toplam işlem sayısını (işlemler + ödemeler) döndürür.
  String _getEventCountText(CalendarState state, AppLocalizations l10n) {
    final count =
        state.selectedDayTransactions.length + state.selectedDayUpcoming.length;
    return l10n.transactionCount(count);
  }

  /// Aylık Finansal Özet Başlığı
  /// (Gelir, Gider ve Net Durum)
  Widget _buildMonthlySummaryHeader(
    BuildContext context,
    AppLocalizations l10n,
    double income,
    double expense,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: l10n.localeName,
      symbol: '₺',
      decimalDigits: 0,
    );

    final net = income - expense;
    final netColor = net >= 0 ? AppColors.incomeGreen : AppColors.expenseRed;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Gelir Kutusu
            _buildHeaderSummaryItem(
              context,
              l10n.thisMonthIncome,
              income,
              AppColors.incomeGreen,
              currencyFormat,
            ),

            // Dikey Çizgi
            Container(
              width: 1,
              color: AppColors.textSecondary.withValues(alpha: 0.2),
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),

            // Net Durum (Vurgulu Ortalanmış)
            Column(
              children: [
                Text(
                  l10n.thisMonthNet,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: netColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currencyFormat.format(net),
                    style: TextStyle(
                      color: netColor,
                      fontWeight: FontWeight.w900, // Extra Bold
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            // Dikey Çizgi
            Container(
              width: 1,
              color: AppColors.textSecondary.withValues(alpha: 0.2),
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),

            // Gider Kutusu
            _buildHeaderSummaryItem(
              context,
              l10n.thisMonthExpense,
              expense,
              AppColors.expenseRed,
              currencyFormat,
            ),
          ],
        ),
      ),
    );
  }

  /// Özet Başlık Öğesi Yardımcısı
  Widget _buildHeaderSummaryItem(
    BuildContext context,
    String title,
    double amount,
    Color color,
    NumberFormat formatter,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          formatter.format(amount),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// Takvim Widget'ı (TableCalendar Entegrasyonu)
  Widget _buildCalendar(
    BuildContext context,
    WidgetRef ref,
    CalendarState state,
    AppLocalizations l10n,
    CalendarNotifier notifier,
    double maxAbsNetBalance,
  ) {
    // Türkiye için Pazartesi başlangıcı, diğerleri için Pazar
    final startingDayOfWeek = l10n.localeName.startsWith('tr')
        ? StartingDayOfWeek.monday
        : StartingDayOfWeek.sunday;

    return TableCalendar<TransactionModel>(
      locale: l10n.localeName,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: state.focusedDay,
      startingDayOfWeek: startingDayOfWeek,

      // Seçili gün kontrolü
      selectedDayPredicate: (day) {
        return isSameDay(state.selectedDay, day) == true;
      },

      // Etkileşimler
      onDaySelected: (selectedDay, focusedDay) {
        HapticFeedback.selectionClick(); // Titreşim efekti
        notifier.selectDay(selectedDay);
        notifier.onPageChanged(focusedDay);
      },
      onPageChanged: notifier.onPageChanged,

      // Marker Yükleyici
      eventLoader: notifier.getEventsForDay,

      // Görünüm Ayarları
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Ay'},

      // Header Tasarımı
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        leftChevronIcon: Icon(
          Icons.chevron_left_rounded,
          color: AppColors.primary,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.primary,
        ),
      ),

      // Gün İsimleri Tasarımı
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        weekendStyle: TextStyle(
          color: AppColors.expenseRed.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),

      // Takvim Hücre Stilleri
      calendarStyle: CalendarStyle(
        // Bugün işaretçisi
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),

        // Seçili gün işaretçisi
        selectedDecoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),

        outsideDaysVisible: false,
        markersMaxCount: 3,
        markersAlignment: Alignment.bottomCenter,
        markerMargin: const EdgeInsets.symmetric(horizontal: 0.5),
      ),

      // Özel Hücre Tasarımları (Builder)
      calendarBuilders: CalendarBuilders(
        // Varsayılan hücre yerine Heatmap (Isı Haritası) hücresi kullan
        defaultBuilder: (context, day, focusedDay) {
          return _buildDayWithHeatmap(
            day,
            state.monthlyEvents,
            maxAbsNetBalance,
          );
        },
        // Marker (Nokta) Tasarımı
        markerBuilder: (context, day, events) {
          return _buildMarkers(context, ref, day, events);
        },
      ),
    );
  }

  /// Isı Haritası Mantığıyla Gün Hücresi Oluşturur
  ///
  /// Günün net bakiyesine göre (gelir - gider) hücre rengini ve opaklığını ayarlar.
  Widget _buildDayWithHeatmap(
    DateTime day,
    Map<DateTime, List<TransactionModel>> events,
    double maxAbsNetBalance,
  ) {
    // Günü normalize et (Saat farkını sıfırla)
    final normalizedDate = DateTime(day.year, day.month, day.day);
    final dayEvents = events[normalizedDate] ?? [];

    // O güne ait toplamları hesapla
    double totalIncome = 0;
    double totalExpense = 0;

    for (var t in dayEvents) {
      if (t.type == TransactionType.income) {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }

    final net = totalIncome - totalExpense;
    final absNet = net.abs();

    // Renk ve Opaklık Hesapla
    double opacity = 0;
    Color baseColor = Colors.transparent;

    if (maxAbsNetBalance > 0 && absNet > 0) {
      // Net bakiye oranına göre opaklık (Max 0.4)
      opacity = (absNet / maxAbsNetBalance) * 0.4;
      if (opacity < 0.1) opacity = 0.1; // Min görünürlük

      if (net >= 0) {
        baseColor = AppColors.incomeGreen;
      } else {
        baseColor = AppColors.expenseRed;
      }
    }

    return Container(
      margin: const EdgeInsets.all(6.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: opacity > 0 ? baseColor.withValues(alpha: opacity) : null,
        shape: BoxShape.circle,
      ),
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: opacity > 0.2 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  /// Günün altındaki durum işaretçilerini (Marker) oluşturur.
  ///
  /// Yeşil: Gelir var
  /// Kırmızı: Gider var
  /// Sarı: Yaklaşan bir ödeme var
  Widget? _buildMarkers(
    BuildContext context,
    WidgetRef ref,
    DateTime day,
    List<TransactionModel> events,
  ) {
    final notifier = ref.read(calendarProvider.notifier);
    final hasUpcoming = notifier.hasUpcomingPayment(day);

    if (events.isEmpty && !hasUpcoming) return null;

    final hasIncome = events.any((e) => e.type == TransactionType.income);
    final hasExpense = events.any((e) => e.type == TransactionType.expense);

    return Positioned(
      bottom: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasIncome) _buildDot(AppColors.incomeGreen),
          if (hasExpense) _buildDot(AppColors.expenseRed),
          if (hasUpcoming) _buildDot(AppColors.warning),
        ],
      ),
    );
  }

  /// Marker Noktası Yardımcı Metodu
  Widget _buildDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
