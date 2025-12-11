import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(child: Text(l10n.pageTitleTransactions));
  }
}
