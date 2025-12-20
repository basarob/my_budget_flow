import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import '../models/recurring_transaction_model.dart';
import '../../auth/services/auth_service.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  // Form State
  bool _isExpense = true; // Gider mi?
  // double? _amount; // Kullanılmıyor, controller kullanılıyor
  String? _categoryName; // Seçilen kategori
  DateTime _selectedDate = DateTime.now();
  String _description = '';

  // Recurring State
  bool _isRecurring = false;
  String _recurringFrequency = 'Aylık'; // Varsayılan

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  // Örnek Kategori Listesi (Normalde Repository'den gelmeli)
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Market', 'icon': Icons.shopping_cart, 'color': Colors.orange},
    {'name': 'Fatura', 'icon': Icons.receipt, 'color': Colors.blue},
    {'name': 'Kira', 'icon': Icons.home, 'color': Colors.indigo},
    {'name': 'Yol', 'icon': Icons.directions_bus, 'color': Colors.green},
    {'name': 'Yemek', 'icon': Icons.restaurant, 'color': Colors.red},
    {'name': 'Maaş', 'icon': Icons.work, 'color': Colors.teal},
    {'name': 'Diğer', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir kategori seçin.')),
      );
      return;
    }

    HapticFeedback.mediumImpact(); // Titreşim

    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    final amount = double.parse(_amountController.text);

    try {
      if (_isRecurring) {
        // Düzenli işlem olarak kaydet
        final recurringItem = RecurringTransactionModel(
          id: '', // Firestore oluşturacak
          userId: user.uid,
          type: _isExpense ? TransactionType.expense : TransactionType.income,
          amount: amount,
          categoryName: _categoryName!,
          frequency: _recurringFrequency,
          startDate: _selectedDate,
          description: _description,
        );

        await ref
            .read(transactionControllerProvider.notifier)
            .addRecurringItem(recurringItem);
      } else {
        // Tekil işlem olarak kaydet
        final transaction = TransactionModel(
          id: '',
          userId: user.uid,
          title: _categoryName!, // Başlık olarak kategori adını kullanıyoruz
          amount: amount,
          type: _isExpense ? TransactionType.expense : TransactionType.income,
          categoryName: _categoryName!,
          date: _selectedDate,
          description: _description,
        );

        await ref
            .read(transactionControllerProvider.notifier)
            .addTransaction(transaction);
      }

      if (mounted) {
        Navigator.pop(context); // Ekranı kapat
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  void _showDatePicker() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: 250,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: _selectedDate,
            maximumDate: DateTime.now().add(
              const Duration(days: 365),
            ), // İleri tarihli işlem olabilir
            minimumYear: 2020,
            maximumYear: 2030,
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                _selectedDate = newDate;
              });
              HapticFeedback.selectionClick(); // Döndürürken titreşim
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = _isExpense ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isExpense ? 'Gider Ekle' : 'Gelir Ekle'),
        actions: [
          TextButton(
            onPressed: () {
              // Şablondan seçme modalı (İleride eklenecek)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Şablonlar yakında...')),
              );
            },
            child: const Text('Şablondan Seç'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Gelir / Gider Anahtarı
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Gelir'),
                Switch(
                  value: _isExpense,
                  activeColor: Colors.red,
                  inactiveThumbColor: Colors.green,
                  inactiveTrackColor: Colors.green.shade200,
                  onChanged: (val) {
                    setState(() {
                      _isExpense = val;
                    });
                  },
                ),
                const Text('Gider'),
              ],
            ),
            const SizedBox(height: 20),

            // Tutar Alanı
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(
                fontSize: 32,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: '₺',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.cardColor,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Tutar giriniz';
                if (double.tryParse(value) == null) return 'Geçersiz tutar';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Kategori Izgarası
            Text('Kategori', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _categories.length + 1, // +1 Ekleme butonu için
              itemBuilder: (context, index) {
                if (index == _categories.length) {
                  // Ekleme Butonu
                  return InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kategori düzenleme yakında...'),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.black),
                    ),
                  );
                }

                final cat = _categories[index];
                final isSelected = _categoryName == cat['name'];

                return InkWell(
                  onTap: () {
                    setState(() {
                      _categoryName = cat['name'];
                    });
                    HapticFeedback.selectionClick();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (cat['color'] as Color).withOpacity(0.2)
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: cat['color'] as Color, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          color: cat['color'] as Color,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat['name'] as String,
                          style: const TextStyle(fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Tarih Seçimi
            ListTile(
              title: const Text('Tarih'),
              subtitle: Text(DateFormat.yMMMd('tr_TR').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: theme.cardColor,
              onTap: _showDatePicker,
            ),
            const SizedBox(height: 16),

            // Not Ekle (Genişleyen Alan)
            ExpansionTile(
              title: const Text('Not Ekle ✏️'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Açıklama giriniz...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => _description = val,
                  ),
                ),
              ],
            ),

            // Düzenli Ödeme Anahtarı
            SwitchListTile(
              title: const Text('Düzenli Ödeme'),
              subtitle: const Text(
                'Bu işlem belirli aralıklarla tekrarlansın.',
              ),
              value: _isRecurring,
              onChanged: (val) {
                setState(() {
                  _isRecurring = val;
                });
              },
            ),

            if (_isRecurring) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String>(
                  value: _recurringFrequency,
                  decoration: const InputDecoration(labelText: 'Sıklık'),
                  items: ['Günlük', 'Haftalık', 'Aylık', 'Yıllık']
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _recurringFrequency = val);
                  },
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Kaydet Butonu
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'KAYDET',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
