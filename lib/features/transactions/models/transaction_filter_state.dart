import 'package:flutter/material.dart';
import 'transaction_model.dart';

/// İşlem Listesi Filtreleme Durumu
///
/// Listeleme ekranındaki filtrelerin (tarih, kategori, tip, arama) durumunu tutar.
class TransactionFilterState {
  final TransactionType? type; // Gelir/Gider fitresi
  final List<String>? selectedCategories; // Çoklu kategori seçimi
  final DateTimeRange? dateRange; // Tarih aralığı
  final String? searchQuery; // Metin arama

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
