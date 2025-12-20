import 'package:flutter/material.dart';
import 'transaction_model.dart';

class TransactionFilterState {
  final TransactionType? type;
  final String? categoryName;
  final DateTimeRange? dateRange;

  const TransactionFilterState({this.type, this.categoryName, this.dateRange});

  TransactionFilterState copyWith({
    TransactionType? type,
    String? categoryName,
    DateTimeRange? dateRange,
  }) {
    return TransactionFilterState(
      type: type ?? this.type,
      categoryName: categoryName ?? this.categoryName,
      dateRange: dateRange ?? this.dateRange,
    );
  }
}
