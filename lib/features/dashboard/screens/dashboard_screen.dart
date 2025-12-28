import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/providers/user_provider.dart'; // Yeni UserProvider eklendi
import '../../transactions/models/category_model.dart';
import '../../transactions/providers/category_provider.dart';
import '../providers/dashboard_provider.dart';

/// Dashboard Ekranı (Gösterge Paneli)
///
/// Bu ekran kullanıcının finansal durumunun genel özetini sunar.
///
/// Özellikler:
/// - **Net Durum Kartı:** Toplam gelir, gider, yatırım ve net bakiyeyi gösterir.
/// - **Harcama Dağılımı:** Pasta grafiği ile kategorik harcama analizini sunar.
/// - **Trend Grafiği:** Gelir ve gider dengesini görselleştirir.
/// - **Tarih Filtreleri:** Haftalık, Aylık (Varsayılan), 30 Günlük ve Yıllık filtreleme seçenekleri.
///
/// Performans Notu:
/// - Kullanıcı verisi `userProvider` üzerinden önbellekten okunur (Tekrar eden DB çağrıları engellendi).
/// - İşlem verileri `dashboardProvider` üzerinden Stream ile anlık takip edilir.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Yerelleştirme (Localization)
    final l10n = AppLocalizations.of(context)!;

    // Oturum Açmış Kullanıcı (ID için)
    final authUser = ref.watch(authStateChangesProvider).value;

    // Dashboard Durumu (Finansal Veriler)
    final dashboardState = ref.watch(dashboardProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Karşılama Mesajı (Optimize Edildi)
          _buildWelcomeMessage(context, ref, l10n, authUser),
          const SizedBox(height: 20),

          // 2. Finansal Özet Kartı (Beyaz Kart Görünümü)
          _buildSummaryCard(context, ref, dashboardState, l10n),
          const SizedBox(height: 20),

          // 3. Grafikler (Veri varsa göster)
          if (!dashboardState.isLoading &&
              dashboardState.transactions.isNotEmpty) ...[
            // Harcama Dağılımı (Pasta Grafik)
            _buildExpensePieChartWithLegend(context, ref, dashboardState, l10n),
            const SizedBox(height: 16),

            // Finansal Trend (Bar - Progress)
            _buildMonthlyComparisonChart(context, dashboardState, l10n),
          ] else if (!dashboardState.isLoading) ...[
            // Veri Yoksa Boş Durum
            _buildEmptyState(context, l10n),
          ],

          // Alt boşluk (Bottom Navigation Bar payı için güvenlik)
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  /// Karşılama Mesajı Widget'ı
  ///
  /// Kullanıcının adını gösterir. `userProvider` sayesinde veritabanından
  /// sadece gerekli durumlarda veri çeker, performans dostudur.
  Widget _buildWelcomeMessage(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    dynamic authUser,
  ) {
    // Kullanıcı Detay Verisini (Ad, Soyad) Provider'dan Dinle
    final userAsync = ref.watch(userProvider);

    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: userAsync.when(
        data: (userData) {
          String displayName = '';
          if (userData != null) {
            displayName = userData['firstName'] ?? '';
          } else if (authUser != null && authUser.email != null) {
            // Veritabanında kayıt yoksa e-posta başlığını kullan (Fallback)
            displayName = authUser.email!.split('@').first;
          }

          final message = displayName.isNotEmpty
              ? l10n.dashboardWelcomeMessage(displayName)
              : l10n.dashboardWelcomeMessage('').replaceAll(',', '').trim();

          return Text(
            message,
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          );
        },
        loading: () => const Text('...'), // Yükleniyor (Minimalist)
        error: (_, _) => const SizedBox(), // Hata durumunda boş geç
      ),
    );
  }

  /// Özet Kartı
  ///
  /// Net bakiye, Toplam Gelir, Toplam Gider ve Yatırım bilgisini
  /// şık bir kart içerisinde sunar. Tarih filtreleri de buradadır.
  Widget _buildSummaryCard(
    BuildContext context,
    WidgetRef ref,
    DashboardState state,
    AppLocalizations l10n,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 0,
    );

    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: GlassContainer(
        // Belirgin beyaz kart tasarımı
        color: Colors.white,
        opacity: 0.95, // Yüksek opaklık
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // A. Tarih Filtreleri
              _buildDateFilters(context, ref, state, l10n),
              const SizedBox(height: 24),

              // B. Net Durum Başlığı
              Text(
                l10n.dashboardNetStatus.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),

              // C. Net Tutar (Büyük Yazı)
              Text(
                currencyFormat.format(state.netBalance),
                style: GoogleFonts.outfit(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: state.netBalance >= 0
                      ? AppColors.incomeGreen
                      : AppColors.expenseRed,
                ),
              ),
              const SizedBox(height: 24),
              Divider(color: Colors.grey.withValues(alpha: 0.1)),
              const SizedBox(height: 16),

              // D. Alt Özetler (Gelir, Gider, Yatırım)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    context,
                    l10n.dashboardTotalIncome,
                    state.totalIncome,
                    AppColors.incomeGreen,
                    Icons.arrow_upward_rounded,
                    currencyFormat,
                  ),
                  _buildVerticalDivider(),
                  _buildSummaryItem(
                    context,
                    l10n.dashboardTotalExpense,
                    state.totalExpense,
                    AppColors.expenseRed,
                    Icons.arrow_downward_rounded,
                    currencyFormat,
                  ),
                  _buildVerticalDivider(),
                  _buildSummaryItem(
                    context,
                    l10n.dashboardInvestment,
                    state.totalInvestment,
                    AppColors.categoryColors[4], // Mor tonları
                    Icons.savings_outlined,
                    currencyFormat,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dikey Ayırıcı Çizgi (Yardımcı Widget)
  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.withValues(alpha: 0.1),
    );
  }

  /// Tarih Filtreleri Konteynırı
  Widget _buildDateFilters(
    BuildContext context,
    WidgetRef ref,
    DashboardState state,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background, // Hafif gri zemin
        borderRadius: BorderRadius.circular(7),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildFilterTab(
            context,
            ref,
            state,
            DashboardDateFilter.thisWeek,
            l10n.filterThisWeek,
          ),
          _buildFilterTab(
            context,
            ref,
            state,
            DashboardDateFilter.thisMonth,
            l10n.filterThisMonth,
          ),
          _buildFilterTab(
            context,
            ref,
            state,
            DashboardDateFilter.last30Days,
            l10n.filterLast30Days,
          ),
          _buildFilterTab(
            context,
            ref,
            state,
            DashboardDateFilter.thisYear,
            l10n.filterThisYear,
          ),
        ],
      ),
    );
  }

  /// Tekil Filtre Sekmesi (Tab)
  Widget _buildFilterTab(
    BuildContext context,
    WidgetRef ref,
    DashboardState state,
    DashboardDateFilter filter,
    String text,
  ) {
    final isSelected = state.selectedFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(dashboardProvider.notifier).setFilter(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  /// Alt Özet Öğesi (Tekil)
  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    double amount,
    Color color,
    IconData icon,
    NumberFormat formatter,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formatter.format(amount),
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Harcama Dağılımı ve Gösterge (Legend) Kartı
  Widget _buildExpensePieChartWithLegend(
    BuildContext context,
    WidgetRef ref,
    DashboardState state,
    AppLocalizations l10n,
  ) {
    final categoryList = ref.watch(categoryListProvider).asData?.value ?? [];

    // Toplam Tutar için Format
    final currencyFormat = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 0,
    );

    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: GlassContainer(
        color: Colors.white,
        opacity: 0.95,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                l10n.chartSpendingDistribution,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // 1. Grafik ve Ortadaki Toplam Tutar
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 4, // Biraz artırdık
                        centerSpaceRadius: 60, // Boşluğu genişlettik
                        sections: _getPieSections(state, categoryList),
                        startDegreeOffset: 270,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.dashboardTotalExpense, // "Toplam Gider"
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormat.format(state.totalExpense),
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Yatay Kaydırılabilir Legend (Chips)
              _buildScrollableLegend(state, categoryList, context),
            ],
          ),
        ),
      ),
    );
  }

  /// Yatay Kaydırılabilir Chip Listesi (Legend)
  Widget _buildScrollableLegend(
    DashboardState state,
    List<CategoryModel> categoryList,
    BuildContext context,
  ) {
    final sortedEntries = state.expenseCategoryDistribution.entries.toList();
    // En yüksek harcamadan düşüğe doğru
    sortedEntries.sort((a, b) => b.value.compareTo(a.value));

    // Limitsiz tüm kategorileri gösterelim veya ilk 10
    final topList = sortedEntries.take(10).toList();
    final totalExpense = state.totalExpense > 0 ? state.totalExpense : 1;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topList.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = topList[index];
          final category = categoryList.firstWhere(
            (c) => c.name == entry.key,
            orElse: () => CategoryModel(
              id: '',
              name: entry.key,
              iconCode: Icons.category.codePoint,
              colorValue: Colors.grey.toARGB32(),
            ),
          );

          // Rengi biraz açalım ki yazı okunsun diye background olarak kullanalım
          final catColor = Color(category.colorValue);

          // Yüzde Hesapla
          final percentage = (entry.value / totalExpense * 100);
          final percentageText = percentage < 1
              ? '<%1'
              : '%${percentage.toStringAsFixed(0)}';

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: catColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  IconData(category.iconCode, fontFamily: 'MaterialIcons'),
                  size: 16,
                  color: catColor,
                ),
                const SizedBox(width: 6),
                Text(
                  category.getLocalizedName(context),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                // Yüzde Badge'i
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    percentageText,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: catColor, // Kendi renginde
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Pasta Grafik Veri Dilimlerini Oluşturur
  List<PieChartSectionData> _getPieSections(
    DashboardState state,
    List<CategoryModel> categoryList,
  ) {
    final sortedEntries = state.expenseCategoryDistribution.entries.toList();

    return sortedEntries.take(8).map((entry) {
      final catName = entry.key;
      final amount = entry.value;

      final category = categoryList.firstWhere(
        (c) => c.name == catName,
        orElse: () => CategoryModel(
          id: '',
          name: '',
          iconCode: 0,
          colorValue: Colors.grey.toARGB32(),
        ),
      );

      return PieChartSectionData(
        color: Color(category.colorValue),
        value: amount,
        title: '', // Dilim üzerine yazı yazmıyoruz, sade olsun
        radius: 16, // İnceltildi
        showTitle: false,
      );
    }).toList();
  }

  /// Gelir/Gider Karşılaştırma Grafiği
  Widget _buildMonthlyComparisonChart(
    BuildContext context,
    DashboardState state,
    AppLocalizations l10n,
  ) {
    final maxValue = state.totalIncome > state.totalExpense
        ? state.totalIncome
        : state.totalExpense;
    final incomePercent = maxValue > 0 ? state.totalIncome / maxValue : 0.0;
    final expensePercent = maxValue > 0 ? state.totalExpense / maxValue : 0.0;

    final currencyFormat = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 0,
    );

    return GlassContainer(
      color: Colors.white,
      opacity: 0.95,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              l10n.chartFinancialTrend,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            _buildComparisonBar(
              context,
              l10n.dashboardTotalIncome,
              currencyFormat.format(state.totalIncome),
              incomePercent,
              AppColors.incomeGreen,
            ),
            const SizedBox(height: 16),

            _buildComparisonBar(
              context,
              l10n.dashboardTotalExpense,
              currencyFormat.format(state.totalExpense),
              expensePercent,
              AppColors.expenseRed,
            ),
          ],
        ),
      ),
    );
  }

  /// Karşılaştırma Çubuğu (Gelir veya Gider için)
  Widget _buildComparisonBar(
    BuildContext context,
    String label,
    String value,
    double percent,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 12,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  /// Boş Durum (İşlem Yoksa)
  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          l10n.noTransactionsFound,
          style: GoogleFonts.inter(color: Colors.white70),
        ),
      ),
    );
  }
}
