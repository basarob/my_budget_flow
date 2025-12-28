import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../auth/services/auth_service.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/providers/transaction_provider.dart';

/// Dosya: dashboard_provider.dart
///
/// Dashboard ekranının veri ve durum yönetimini sağlayan Provider.
///
/// [Özellikler]
/// - Seçili tarih aralığına göre (Haftalık, Aylık, Yıllık) finansal verileri filtreler.
/// - Toplam Gelir, Gider, Yatırım ve Net Bakiye hesaplamalarını yapar.
/// - Trend grafiği ve harcama dağılımı grafiği için verileri hazırlar.
/// - Stream tabanlı yapısı ile anlık veri güncellemelerini destekler.

/// Dashboard Zaman Filtreleri
enum DashboardDateFilter { thisWeek, thisMonth, last30Days, thisYear }

/// Dashboard Durumu (State)
class DashboardState {
  final DashboardDateFilter selectedFilter;
  final double totalIncome;
  final double totalExpense;
  final double totalInvestment;
  final double netBalance;
  final List<TransactionModel> transactions;
  final Map<String, double> expenseCategoryDistribution;
  final List<FlSpot> trendData;
  final bool isLoading;

  const DashboardState({
    this.selectedFilter = DashboardDateFilter.thisMonth,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.totalInvestment = 0,
    this.netBalance = 0,
    this.transactions = const [],
    this.expenseCategoryDistribution = const {},
    this.trendData = const [],
    this.isLoading = true,
  });

  DashboardState copyWith({
    DashboardDateFilter? selectedFilter,
    double? totalIncome,
    double? totalExpense,
    double? totalInvestment,
    double? netBalance,
    List<TransactionModel>? transactions,
    Map<String, double>? expenseCategoryDistribution,
    List<FlSpot>? trendData,
    bool? isLoading,
  }) {
    return DashboardState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      totalInvestment: totalInvestment ?? this.totalInvestment,
      netBalance: netBalance ?? this.netBalance,
      transactions: transactions ?? this.transactions,
      expenseCategoryDistribution:
          expenseCategoryDistribution ?? this.expenseCategoryDistribution,
      trendData: trendData ?? this.trendData,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Dashboard Yöneticisi (Stream tabanlı)
class DashboardNotifier extends Notifier<DashboardState> {
  // Stream aboneliğini takip etmek için
  // Not: Repository Stream'ini dinleyerek state'i günceller.

  @override
  DashboardState build() {
    _subscribeToStream();
    return const DashboardState();
  }

  void _subscribeToStream() {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    final repository = ref.read(transactionRepositoryProvider);

    // Tüm işlemleri (veya geniş bir aralığı) dinle
    // Performans: Dashboard için son 1000 işlem yeterli olacaktır.
    final stream = repository.getTransactionsStream(
      userId: user.uid,
      limit: 1000,
    );

    stream.listen((items) {
      _processData(items);
    });
  }

  /// Filtre değiştiğinde verileri (memory'deki) yeniden hesapla
  void setFilter(DashboardDateFilter filter) {
    if (state.selectedFilter == filter) return;

    state = state.copyWith(selectedFilter: filter);

    if (_lastAllTransactions.isNotEmpty) {
      _processData(_lastAllTransactions);
    } else {
      _subscribeToStream(); // Tekrar abone ol (Gerekirse)
    }
  }

  List<TransactionModel> _lastAllTransactions = [];

  void _processData(List<TransactionModel> allTransactions) {
    _lastAllTransactions = allTransactions;

    final range = _getDateRange(state.selectedFilter);

    // Tarih aralığına göre filtrele
    final filteredTransactions = allTransactions.where((t) {
      return t.date.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(range.end.add(const Duration(days: 1)));
    }).toList();

    // Hesaplamalar
    double income = 0;
    double expense = 0;
    double investment = 0;
    Map<String, double> categoryDist = {};
    Map<int, double> dailyNet = {};

    for (var t in filteredTransactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
        final dayKey = t.date.difference(range.start).inDays;
        dailyNet[dayKey] = (dailyNet[dayKey] ?? 0) + t.amount;
      } else {
        expense += t.amount;
        if (t.categoryName == 'categoryInvestment') {
          investment += t.amount;
        }
        categoryDist[t.categoryName] =
            (categoryDist[t.categoryName] ?? 0) + t.amount;
        final dayKey = t.date.difference(range.start).inDays;
        dailyNet[dayKey] = (dailyNet[dayKey] ?? 0) - t.amount;
      }
    }

    List<FlSpot> spots = [];
    final totalDays = range.end.difference(range.start).inDays;

    if (totalDays > 0) {
      for (int i = 0; i <= totalDays; i++) {
        spots.add(FlSpot(i.toDouble(), dailyNet[i] ?? 0));
      }
    } else {
      // Tek gün ise
      spots.add(FlSpot(0, dailyNet[0] ?? 0));
    }

    final sortedCategories = Map.fromEntries(
      categoryDist.entries.toList()
        ..sort((e1, e2) => e2.value.compareTo(e1.value)),
    );

    state = state.copyWith(
      totalIncome: income,
      totalExpense: expense,
      totalInvestment: investment,
      netBalance: income - expense,
      transactions: filteredTransactions,
      expenseCategoryDistribution: sortedCategories,
      trendData: spots,
      isLoading: false,
    );
  }

  /// Filtreye göre tarih aralığı döndürür
  DateTimeRange _getDateRange(DashboardDateFilter filter) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (filter) {
      case DashboardDateFilter.thisWeek:
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case DashboardDateFilter.thisMonth:
        start = DateTime(now.year, now.month, 1);
        break;
      case DashboardDateFilter.last30Days:
        start = now.subtract(const Duration(days: 30));
        start = DateTime(start.year, start.month, start.day);
        break;
      case DashboardDateFilter.thisYear:
        start = DateTime(now.year, 1, 1);
        break;
    }
    return DateTimeRange(start: start, end: end);
  }
}

/// Dashboard Provider Definition
final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(
  DashboardNotifier.new,
);
