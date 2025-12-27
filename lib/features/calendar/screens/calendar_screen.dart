import 'dart:ui' as ui; // BackdropFilter için
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

/// Takvim Ekranı
///
/// Kullanıcının aylık finansal görünümünü sunar. Günlere tıklayarak detay
/// görüntüler, işlem düzenler veya yaklaşan ödemeleri takip eder.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final calendarState = ref.watch(calendarProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final notifier = ref.read(calendarProvider.notifier);

    // Hata Durumu
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

    // Isı haritası için o ayki maksimum mutlak net bakiyeyi bul (Normalizasyon için)
    double maxAbsNetBalance = 0;
    if (calendarState.monthlyEvents.isNotEmpty) {
      for (var events in calendarState.monthlyEvents.values) {
        double dailyIncome = 0;
        double dailyExpense = 0;
        for (var t in events) {
          if (t.type == TransactionType.income) {
            dailyIncome += t.amount;
          } else {
            dailyExpense += t.amount;
          }
        }
        final absNet = (dailyIncome - dailyExpense).abs();
        if (absNet > maxAbsNetBalance) maxAbsNetBalance = absNet;
      }
    }

    // Aylık Toplamları Hesapla
    double monthlyTotalIncome = 0;
    double monthlyTotalExpense = 0;

    // Görüntülenen ay için filtreleme yap
    // Not: calendarState.monthlyEvents map'inde o aya ait olanlar var ama
    // focusedDay'in ayına ait olanları garantiye almak için kontrol edebiliriz.
    // Ancak provider zaten focusedDay'e göre yükleme yapıyor, bu yüzden mapteki tüm eventleri toplamak yeterli.
    if (calendarState.monthlyEvents.isNotEmpty) {
      for (var date in calendarState.monthlyEvents.keys) {
        // Sadece seçili ayın verilerini topla (Emin olmak için)
        if (date.year == calendarState.focusedDay.year &&
            date.month == calendarState.focusedDay.month) {
          final events = calendarState.monthlyEvents[date]!;
          for (var t in events) {
            if (t.type == TransactionType.expense) {
              monthlyTotalExpense += t.amount;
            } else {
              monthlyTotalIncome += t.amount;
            }
          }
        }
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                // 1. Takvim ve Özet Kartı (Glassmorphism)
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    // Hafif gradient arka plan
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).cardColor.withValues(alpha: 0.7),
                        Theme.of(context).cardColor.withValues(alpha: 0.5),
                      ],
                    ),
                    // Kenarlık (Sınır)
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    // Gölge
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          children: [
                            // A. Aylık Özet Başlığı
                            _buildMonthlySummaryHeader(
                              context,
                              l10n,
                              monthlyTotalIncome,
                              monthlyTotalExpense,
                            ),

                            // B. Takvim
                            _buildCalendar(
                              context,
                              ref,
                              calendarState,
                              l10n,
                              notifier,
                              maxAbsNetBalance,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. Yükleme göstergesi
                if (calendarState.isLoading)
                  const LinearProgressIndicator(minHeight: 2),

                // 3. Seçili gün varsa özet ve liste
                if (calendarState.selectedDay != null) ...[
                  // Özet Kartı
                  DaySummaryCard(
                    transactions: calendarState.selectedDayTransactions,
                    upcomingPayments: calendarState.selectedDayUpcoming,
                  ),

                  // Seçili Gün Başlığı
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

                  // İşlem Listesi
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

                  // Alt boşluk (liste sonu)
                  const SizedBox(height: 80),
                ] else
                  // Gün seçilmemişse bilgi mesajı
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

  String _getEventCountText(CalendarState state, AppLocalizations l10n) {
    final count =
        state.selectedDayTransactions.length + state.selectedDayUpcoming.length;
    return l10n.transactionCount(count);
  }

  /// Aylık Özet Başlığı
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
            // Gelir
            _buildHeaderSummaryItem(
              context,
              l10n.thisMonthIncome,
              income,
              AppColors.incomeGreen,
              currencyFormat,
            ),

            // Ayıraç
            Container(
              width: 1,
              color: AppColors.textSecondary.withValues(alpha: 0.2),
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),

            // Net (Daha belirgin - Özel Tasarım)
            Column(
              children: [
                Text(
                  l10n.thisMonthNet,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold, // Kalın
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
                      fontSize: 16, // Biraz daha büyük
                    ),
                  ),
                ),
              ],
            ),

            // Ayıraç
            Container(
              width: 1,
              color: AppColors.textSecondary.withValues(alpha: 0.2),
              margin: const EdgeInsets.symmetric(vertical: 4),
            ),

            // Gider
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
          title, // "Bu Ayın Geliri" vb.
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10, // Kompakt olması için küçülttüm
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
            fontSize: 14, // Kompakt
          ),
        ),
      ],
    );
  }

  /// Takvim Widget'ı
  Widget _buildCalendar(
    BuildContext context,
    WidgetRef ref,
    CalendarState state,
    AppLocalizations l10n,
    CalendarNotifier notifier,
    double maxAbsNetBalance,
  ) {
    // Hafta başlangıcı (TR: Pazartesi, Diğer: Pazar)
    final startingDayOfWeek = l10n.localeName.startsWith('tr')
        ? StartingDayOfWeek.monday
        : StartingDayOfWeek.sunday;

    return TableCalendar<TransactionModel>(
      // Temel Ayarlar
      locale: l10n.localeName,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: state.focusedDay,
      startingDayOfWeek: startingDayOfWeek,
      selectedDayPredicate: (day) {
        // isSameDay null güvenliği kontrolü (Explicit bool check)
        return isSameDay(state.selectedDay, day) == true;
      },

      // Olaylar
      onDaySelected: (selectedDay, focusedDay) {
        HapticFeedback.selectionClick(); // Titreşim eklendi
        notifier.selectDay(selectedDay);
        notifier.onPageChanged(focusedDay);
      },
      onPageChanged: notifier.onPageChanged,

      // Olay Yükleyici (Marker'lar için)
      eventLoader: notifier.getEventsForDay,

      // Takvim Formatı
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Ay'},

      // Başlık Stili
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

      // Gün İsimleri Stili
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

      // Gün Hücreleri Stili
      calendarStyle: CalendarStyle(
        // Bugün
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),

        // Seçili Gün
        selectedDecoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),

        // Ay Dışı Günler
        outsideDaysVisible: false,

        // Marker Stilleri
        markersMaxCount: 3,
        markersAlignment: Alignment.bottomCenter,
        markerMargin: const EdgeInsets.symmetric(horizontal: 0.5),
      ),

      // Özelleştirilmiş Builder'lar (Isı Haritası ve Marker)
      calendarBuilders: CalendarBuilders(
        // Varsayılan gün görünümü (Isı haritası için override)
        defaultBuilder: (context, day, focusedDay) {
          return _buildDayWithHeatmap(
            day,
            state.monthlyEvents,
            maxAbsNetBalance,
          );
        },

        // Marker (Noktalar)
        markerBuilder: (context, day, events) {
          return _buildMarkers(context, ref, day, events);
        },
      ),
    );
  }

  /// Isı Haritası (Heatmap) Mantığı ile Gün Hücresi
  Widget _buildDayWithHeatmap(
    DateTime day,
    Map<DateTime, List<TransactionModel>> events,
    double maxAbsNetBalance,
  ) {
    // Bu güne ait harcamayı bul
    final normalizedDate = DateTime(day.year, day.month, day.day);
    final dayEvents = events[normalizedDate] ?? [];

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

    // Opaklık hesapla
    // En az 0, en fazla 0.4 opacity olsun
    double opacity = 0;
    Color baseColor = Colors.transparent;

    if (maxAbsNetBalance > 0 && absNet > 0) {
      opacity = (absNet / maxAbsNetBalance) * 0.4;
      if (opacity < 0.1) opacity = 0.1;

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

  /// Gün altındaki renkli noktaları oluşturur.
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
          if (hasIncome)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: AppColors.incomeGreen,
                shape: BoxShape.circle,
              ),
            ),
          if (hasExpense)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: AppColors.expenseRed,
                shape: BoxShape.circle,
              ),
            ),
          if (hasUpcoming)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
