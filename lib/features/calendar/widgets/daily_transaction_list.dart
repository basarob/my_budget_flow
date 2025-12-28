import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/models/recurring_transaction_model.dart';
import '../../transactions/screens/add_transaction_screen.dart';
import '../../transactions/models/category_model.dart';

/// Dosya: daily_transaction_list.dart
///
/// Günlük İşlem Listesi Widget'ı.
///
/// [Özellikler]
/// - Takvimde seçilen güne ait işlemleri listeler.
/// - Yaklaşan düzenli ödemeleri ayrı bir bölüm olarak gösterir.
/// - İşlemlere tıklandığında düzenleme ekranına (AddTransactionScreen) yönlendirir.
/// - Kategori ikonlarını ve renklerini dinamik olarak gösterir.
class DailyTransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final List<RecurringTransactionModel> upcomingPayments;
  final List<CategoryModel> categories;

  const DailyTransactionList({
    super.key,
    required this.transactions,
    required this.upcomingPayments,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(
      locale: l10n.localeName,
      symbol: '₺',
    );

    // Performans için kategorileri Map'e çevir
    final categoryMap = {for (var c in categories) c.name: c};

    // Veri Yoksa Boş Durum
    if (transactions.isEmpty && upcomingPayments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_available_rounded,
                size: 48,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.noTransactionsFound,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // 1. Gerçekleşmiş İşlemler
        ...transactions.map(
          (tx) => _TransactionTile(
            transaction: tx,
            category: categoryMap[tx.categoryName],
            onTap: () => _openEditScreen(context, tx),
            l10n: l10n,
            formatter: currencyFormat,
          ),
        ),

        // 2. Yaklaşan Ödemeler (Opsiyonel)
        if (upcomingPayments.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.update, size: 16, color: AppColors.warning),
                const SizedBox(width: 8),
                Text(
                  l10n.plannedTransaction,
                  style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ...upcomingPayments.map(
            (recurring) => _UpcomingPaymentTile(
              recurring: recurring,
              category: categoryMap[recurring.categoryName],
              onTap: () => _openCreateFromRecurring(context, recurring),
              l10n: l10n,
              formatter: currencyFormat,
            ),
          ),
        ],
      ],
    );
  }

  void _openEditScreen(BuildContext context, TransactionModel tx) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(transactionToEdit: tx),
      ),
    );
  }

  void _openCreateFromRecurring(
    BuildContext context,
    RecurringTransactionModel recurring,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AddTransactionScreen(recurringTransactionToEdit: recurring),
      ),
    );
  }
}

/// Helper: Tekil İşlem Kartı
class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final CategoryModel? category;
  final VoidCallback onTap;
  final AppLocalizations l10n;
  final NumberFormat formatter;

  const _TransactionTile({
    required this.transaction,
    required this.category,
    required this.onTap,
    required this.l10n,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = isExpense
        ? AppColors.expenseRed
        : AppColors.incomeGreen;

    final displayCategory = _localizeCategory(transaction.categoryName, l10n);

    final icon = category != null
        ? IconData(category!.iconCode, fontFamily: 'MaterialIcons')
        : Icons.category_outlined;
    final iconColor = category != null
        ? Color(category!.colorValue)
        : AppColors.primary;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: iconColor.withValues(alpha: 0.15),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        transaction.title,
        style: const TextStyle(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayCategory,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          if (transaction.description != null &&
              transaction.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                transaction.description!,
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
      trailing: Text(
        '${isExpense ? "-" : "+"}${formatter.format(transaction.amount)}',
        style: TextStyle(
          color: amountColor,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}

/// Yerelleştirilmiş kategori ismi
String _localizeCategory(String name, AppLocalizations l10n) {
  switch (name) {
    case 'categoryFood':
      return l10n.categoryFood;
    case 'categoryBills':
      return l10n.categoryBills;
    case 'categoryTransport':
      return l10n.categoryTransport;
    case 'categoryRent':
      return l10n.categoryRent;
    case 'categoryShopping':
      return l10n.categoryShopping;
    case 'categoryEntertainment':
      return l10n.categoryEntertainment;
    case 'categorySalary':
      return l10n.categorySalary;
    case 'categoryInvestment':
      return l10n.categoryInvestment;
    case 'categoryOther':
      return l10n.categoryOther;
    default:
      return name;
  }
}

/// Helper: Yaklaşan Ödeme Kartı
class _UpcomingPaymentTile extends StatelessWidget {
  final RecurringTransactionModel recurring;
  final CategoryModel? category;
  final VoidCallback onTap;
  final AppLocalizations l10n;
  final NumberFormat formatter;

  const _UpcomingPaymentTile({
    required this.recurring,
    required this.category,
    required this.onTap,
    required this.l10n,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = recurring.type == TransactionType.expense;
    final amountColor = isExpense ? AppColors.expenseRed : AppColors.info;

    final icon = category != null
        ? IconData(category!.iconCode, fontFamily: 'MaterialIcons')
        : Icons.schedule_rounded;
    final iconColor = category != null
        ? Color(category!.colorValue)
        : AppColors.warning;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withValues(alpha: 0.15),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            // Yön Oku (Küçük rozet)
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: amountColor, width: 1),
              ),
              child: Icon(
                isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                size: 10,
                color: amountColor,
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                recurring.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.access_time_filled, size: 14, color: AppColors.warning),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _localizeCategory(recurring.categoryName, l10n),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (recurring.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  recurring.description,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        trailing: Text(
          '~${formatter.format(recurring.amount)}',
          style: TextStyle(
            color: amountColor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
