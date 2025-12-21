import 'package:flutter/material.dart';
import 'transaction_model.dart';

class TransactionFilterState {
  final TransactionType? type;
  final List<String>? selectedCategories; // Çoklu kategori seçimi
  final DateTimeRange? dateRange;
  final String? searchQuery; // Arama sorgusu

  const TransactionFilterState({
    this.type,
    this.selectedCategories,
    this.dateRange,
    this.searchQuery,
  });

  TransactionFilterState copyWith({
    TransactionType? type,
    List<String>? selectedCategories,
    DateTimeRange? dateRange,
    String? searchQuery,
  }) {
    return TransactionFilterState(
      type: type ?? this.type,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      dateRange: dateRange ?? this.dateRange,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
