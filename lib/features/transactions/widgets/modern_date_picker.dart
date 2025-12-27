import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../l10n/app_localizations.dart';

/// Modern Tarih Seçici Widget'ı
///
/// Kullanıcının başlangıç ve bitiş tarihlerini seçmesini sağlayan,
/// özelleştirilmiş, bottom-sheet içerisinde çalışan takvim arayüzü.
///
/// Kullanım:
/// - Tek tarih seçimi için başlangıç ve bitiş aynı gün olabilir.
/// - Aralık seçimi için iki farklı güne tıklanır.
/// - Seçilen aralık `onSaved` callback'i ile geri döndürülür.
class ModernDatePicker extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime start, DateTime end) onSaved;

  const ModernDatePicker({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.onSaved,
  });

  @override
  State<ModernDatePicker> createState() => _ModernDatePickerState();
}

class _ModernDatePickerState extends State<ModernDatePicker> {
  late DateTime _focusedMonth;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    // Eğer başlangıç tarihi varsa o ayı göster, yoksa bu ayı
    _focusedMonth = _startDate != null
        ? DateTime(_startDate!.year, _startDate!.month)
        : DateTime(now.year, now.month);
  }

  /// Gün seçildiğinde tetiklenir
  void _onDaySelected(DateTime day) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_startDate != null && _endDate == null) {
        // İkinci tarih seçimi
        if (day.isBefore(_startDate!)) {
          _startDate = day;
        } else {
          _endDate = day;
        }
      } else {
        // Yeni seçim başlat
        _startDate = day;
        _endDate = null;
      }
    });
  }

  /// Ay değiştirme
  void _changeMonth(int increment) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + increment,
      );
    });
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isInRange(DateTime day) {
    if (_startDate == null || _endDate == null) return false;
    return day.isAfter(_startDate!) && day.isBefore(_endDate!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final weekdayOffset =
        firstDayOfMonth.weekday -
        1; // Pazartesi = 1, Pazar = 7. Biz 0-6 istiyoruz (Pzt=0)

    // Grid oluşturma
    final List<Widget> dayWidgets = [];

    // Boşluklar (Önceki aydan kalan günler için)
    for (int i = 0; i < weekdayOffset; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Günler
    for (int i = 1; i <= daysInMonth; i++) {
      final day = DateTime(_focusedMonth.year, _focusedMonth.month, i);
      final isStart = _isSameDay(day, _startDate);
      final isEnd = _isSameDay(day, _endDate);
      final inRange = _isInRange(day);
      final isToday = _isSameDay(day, DateTime.now());

      BoxDecoration? decoration;
      Color textColor = AppColors.textPrimary;

      if (isStart || isEnd) {
        decoration = BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        );
        textColor = Colors.white;
      } else if (inRange) {
        decoration = BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        );
        textColor = AppColors.primary;
      } else if (isToday) {
        decoration = BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 1),
          shape: BoxShape.circle,
        );
        textColor = AppColors.primary;
      }

      dayWidgets.add(
        GestureDetector(
          onTap: () => _onDaySelected(day),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: decoration,
            alignment: Alignment.center,
            child: Text(
              '$i',
              style: TextStyle(
                fontWeight: (isStart || isEnd || isToday)
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.passive,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header (Tarih Aralığı Gösterimi)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dateRangeTitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _startDate != null
                          ? '${DateFormat('d MMM', locale).format(_startDate!)}${_endDate != null ? ' - ${DateFormat('d MMM', locale).format(_endDate!)}' : ''}'
                          : l10n.dateSelectPlaceholder,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                // Kaydet Butonu (Hızlı onay için)
                if (_startDate != null)
                  IconButton(
                    onPressed: () {
                      if (_startDate != null) {
                        final start = _startDate!;
                        final end =
                            _endDate ??
                            _startDate!.add(
                              const Duration(
                                hours: 23,
                                minutes: 59,
                                seconds: 59,
                              ),
                            );
                        widget.onSaved(start, end);
                        Navigator.pop(context);
                      }
                    },
                    icon: Icon(Icons.check, color: AppColors.primary),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Ay nav ve Grid
          Expanded(
            child: Column(
              children: [
                // Ay Navigasyon
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => _changeMonth(-1),
                      ),
                      Text(
                        // Ay ismi otomatik yerelleşir
                        DateFormat('MMMM yyyy', locale).format(_focusedMonth),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => _changeMonth(1),
                      ),
                    ],
                  ),
                ),

                // Gün İsimleri
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:
                        [
                              l10n.shortDayMon,
                              l10n.shortDayTue,
                              l10n.shortDayWed,
                              l10n.shortDayThu,
                              l10n.shortDayFri,
                              l10n.shortDaySat,
                              l10n.shortDaySun,
                            ]
                            .map(
                              (day) => SizedBox(
                                width: 32,
                                child: Text(
                                  day,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // Takvim Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.count(
                      crossAxisCount: 7,
                      children: dayWidgets,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Alt Buton
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              MediaQuery.of(context).viewPadding.bottom + 16,
            ),
            child: GradientButton(
              text: l10n.applySelectionButton,
              onPressed: (_startDate != null)
                  ? () {
                      final start = _startDate!;
                      // Bitiş günü seçilmediyse o günün sonuna kadar
                      final end = _endDate != null
                          ? DateTime(
                              _endDate!.year,
                              _endDate!.month,
                              _endDate!.day,
                              23,
                              59,
                              59,
                            )
                          : DateTime(
                              start.year,
                              start.month,
                              start.day,
                              23,
                              59,
                              59,
                            );

                      widget.onSaved(start, end);
                      Navigator.pop(context);
                    }
                  : null, // Disabled
              icon: Icons.calendar_month,
            ),
          ),
        ],
      ),
    );
  }
}
