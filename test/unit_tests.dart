import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_budget_flow/core/widgets/custom_text_field.dart';
import 'package:my_budget_flow/core/widgets/gradient_button.dart';
import 'package:my_budget_flow/features/goals/models/goal_model.dart';
import 'package:my_budget_flow/features/transactions/models/recurring_transaction_model.dart';
import 'package:my_budget_flow/features/transactions/models/transaction_filter_state.dart';
import 'package:my_budget_flow/features/transactions/models/transaction_model.dart';

void main() {
  // =================================================================
  // GRUP 1: MODEL & SERIALIZATION TESTLERİ (VERİ KATMANI)
  // =================================================================
  group('Goal Model Testleri', () {
    /// TEST 1: Goal modelinin bir Map yapısına (Firestore'a yazılacak formata)
    /// doğru şekilde dönüştürülüp dönüştürülmediğini kontrol eder.
    test('toMap Goal nesnesini geçerli bir Map\'e dönüştürmeli', () {
      final goal = Goal(
        id: '1',
        userId: 'user1',
        title: 'Tatil',
        targetAmount: 1000.0,
        startDate: DateTime(2026, 1, 1),
        type: GoalType.investment,
        categoryIds: ['cat1'],
        colorValue: 0xFF0000,
        collectedAmount: 500.0,
      );

      final map = goal.toMap();

      expect(map['id'], '1');
      expect(map['userId'], 'user1');
      expect(map['targetAmount'], 1000.0);
      expect(map['type'], 'investment');
      expect(map['categoryIds'], ['cat1']);
      expect(map['startDate'], isA<Timestamp>());
    });

    /// TEST 2: Firestore'dan gelen bir Map yapısının (verinin)
    /// Goal modeline eksiksiz ve doğru bir şekilde dönüştürüldüğünü doğrular.
    test('fromMap Goal nesnesini doğru şekilde oluşturmalı', () {
      final map = {
        'userId': 'user1',
        'title': 'Tatil',
        'targetAmount': 1000.0,
        'startDate': Timestamp.fromDate(DateTime(2026, 1, 1)),
        'type': 'investment',
        'categoryIds': ['cat1'],
        'colorValue': 0xFF0000,
      };

      final goal = Goal.fromMap(map, '1');

      expect(goal.id, '1');
      expect(goal.title, 'Tatil');
      expect(goal.type, GoalType.investment);
      expect(goal.startDate.year, 2026);
      expect(goal.collectedAmount, 0.0); // Varsayılan değer
    });

    /// TEST 3: Hedeflenen tutar ve biriken tutar baz alınarak
    /// ilerleme yüzdesinin (0.0 ile 1.0 arası) doğru hesaplandığını test eder.
    test('İlerleme (progress) hesaplaması doğru olmalı', () {
      final goal = Goal(
        id: '1',
        userId: 'user1',
        title: 'Test',
        targetAmount: 100.0,
        startDate: DateTime.now(),
        type: GoalType.expense,
        categoryIds: [],
        colorValue: 0,
        collectedAmount: 50.0,
      );

      expect(goal.progress, 0.5);
    });

    /// TEST 4: Biriken tutar hedeflenen tutarı geçse bile
    /// ilerleme yüzdesinin UI'ı bozmaması için maksimum 1.0 döndüğünü doğrular.
    test('İlerleme değeri 1.0\'ı aşmamalı', () {
      final goal = Goal(
        id: '1',
        userId: 'user1',
        title: 'Test',
        targetAmount: 100.0,
        startDate: DateTime.now(),
        type: GoalType.expense,
        categoryIds: [],
        colorValue: 0,
        collectedAmount: 150.0,
      );

      expect(goal.progress, 1.0);
    });
  });

  group('Transaction Model Testleri', () {
    /// TEST 5: TransactionModel (İşlem) nesnesinin veritabanına kaydedilecek
    /// Map formatına doğru çevrildiğini test eder.
    test('toMap TransactionModel nesnesini doğru dönüştürmeli', () {
      final tx = TransactionModel(
        id: 'tx1',
        userId: 'user1',
        title: 'Market',
        amount: 150.0,
        type: TransactionType.expense,
        categoryName: 'Gıda',
        date: DateTime(2026, 5, 20),
        description: 'Haftalık alışveriş',
      );

      final map = tx.toMap();

      expect(map['id'], 'tx1');
      expect(map['type'], 'expense');
      expect(map['amount'], 150.0);
      expect(map['description'], 'Haftalık alışveriş');
    });

    /// TEST 6: Veritabanından gelen Map verisinin TransactionModel nesnesine
    /// (Enum dönüşümleri dahil) doğru çevrildiğini kontrol eder.
    test('fromMap TransactionModel nesnesini doğru oluşturmalı', () {
      final map = {
        'userId': 'user1',
        'title': 'Maaş',
        'amount': 5000.0,
        'type': 'income',
        'categoryName': 'İş',
        'date': Timestamp.fromDate(DateTime(2026, 5, 20)),
        'isRecurring': true,
      };

      final tx = TransactionModel.fromMap(map, 'tx2');

      expect(tx.id, 'tx2');
      expect(tx.type, TransactionType.income);
      expect(tx.amount, 5000.0);
      expect(tx.isRecurring, true);
    });
  });

  // =================================================================
  // GRUP 2: İŞ MANTIĞI TESTLERİ (BUSINESS LOGIC)
  // =================================================================
  group('Düzenli İşlem (Recurring Transaction) Mantık Testleri', () {
    /// TEST 7: 'Aylık' tekrarlayan bir işlem için bir sonraki ödeme tarihinin
    /// bir sonraki aya doğru şekilde atandığını test eder.
    test('Aylık ödeme döngüsü tarihi doğru artırmalı', () {
      // 31 Ocak -> 28 Şubat (veya artık yıla göre 29)
      // Mantık en yakın geçerli güne atlayabilir veya ayı artırabilir.
      // Standart mantık varsayımı: 15 Ocak -> 15 Şubat
      final safeDate = DateTime(2026, 1, 15);
      final nextDate = RecurringTransactionModel.calculateNextDueDate(
        safeDate,
        'monthly', // Aylık
      );

      expect(nextDate.year, 2026);
      expect(nextDate.month, 2);
      expect(nextDate.day, 15);
    });

    /// TEST 8: 'Haftalık' tekrarlayan bir işlem için bir sonraki tarihin
    /// tam olarak 7 gün sonrasına ayarlandığını doğrular.
    test('Haftalık ödeme döngüsü tarihi doğru artırmalı', () {
      final date = DateTime(2026, 1, 1);
      final nextDate = RecurringTransactionModel.calculateNextDueDate(
        date,
        'weekly', // Haftalık
      );
      // 1 Ocak + 7 gün = 8 Ocak
      expect(nextDate.day, 8);
    });

    /// TEST 9: Filtreleme durumu (State) değişmezliğini koruyarak (immutable),
    /// copyWith metodunun sadece istenen alanı güncellediğini test eder.
    test('TransactionFilterState copyWith doğru çalışmalı', () {
      const filter = TransactionFilterState();
      final newFilter = filter.copyWith(searchQuery: 'Yeni Arama');

      expect(newFilter.searchQuery, 'Yeni Arama');
      expect(newFilter.type, null);
    });
  });

  // =================================================================
  // GRUP 3: WIDGET TESTLERİ (UI ETKİLEŞİMİ)
  // =================================================================
  group('Widget Testleri', () {
    /// TEST 10: GradientButton bileşeninin normal durumda metni gösterdiğini,
    /// loading durumunda ise CircularProgressIndicator gösterdiğini test eder.
    testWidgets(
      'GradientButton metni göstermeli ve loading durumunu işlemeli',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientButton(onPressed: () {}, text: 'Kaydet'),
            ),
          ),
        );

        // Metnin göründüğünü doğrula
        expect(find.text('Kaydet'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Loading durumunu doğrula
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientButton(
                onPressed: () {},
                text: 'Kaydet',
                isLoading: true,
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(
          find.text('Kaydet'),
          findsNothing,
        ); // Loading iken metin gizlenmeli
      },
    );

    /// TEST 11: CustomTextField bileşeninin ekrana doğru çizildiğini (render)
    /// ve metin girişinin başarılı bir şekilde yapılabildiğini doğrular.
    testWidgets('CustomTextField render edilmeli ve veri girilebilmeli', (
      tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              labelText: 'E-posta',
              prefixIcon: Icons.email,
            ),
          ),
        ),
      );

      // Label ve ikon kontrolü
      expect(find.text('E-posta'), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);

      // Metin girişi
      await tester.enterText(find.byType(CustomTextField), 'test@example.com');
      await tester.pump();

      expect(controller.text, 'test@example.com');
    });

    /// TEST 12: Şifre alanında 'göz' ikonuna tıklandığında,
    /// şifre görünürlüğünün (obscureText) açılıp kapandığını test eder.
    testWidgets('CustomTextField şifre görünürlüğünü değiştirmeli (toggle)', (
      tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              labelText: 'Şifre',
              prefixIcon: Icons.lock,
              isPassword: true,
            ),
          ),
        ),
      );

      // Başlangıç durumunun gizli olduğunu ikon üzerinden kontrol et
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Görünürlük butonuna tıkla
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // İkonun değiştiğini doğrula
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
}
