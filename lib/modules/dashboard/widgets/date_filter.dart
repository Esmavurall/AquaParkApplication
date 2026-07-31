import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class DateFilter extends StatelessWidget {
  final DateTime date1;
  final DateTime date2;
  final ValueChanged<DateTime> onDate1Changed;
  final ValueChanged<DateTime> onDate2Changed;
  final VoidCallback onApply;
  final void Function(DateTime start, DateTime end) onPreset;

  const DateFilter({
    super.key,
    required this.date1,
    required this.date2,
    required this.onDate1Changed,
    required this.onDate2Changed,
    required this.onApply,
    required this.onPreset,
  });

  String _fmt(DateTime d) => DateFormat('dd.MM.yyyy').format(d);

  Future<void> _pick(
    BuildContext context,
    DateTime initial,
    ValueChanged<DateTime> onChanged, {
    DateTime? first,
    DateTime? last,
  }) async {
    final firstDate = first ?? DateTime(2020);
    final lastDate = last ?? DateTime(2100);

    var start = initial;
    if (start.isBefore(firstDate)) start = firstDate;
    if (start.isAfter(lastDate)) start = lastDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: start,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'date.select_date'.tr(),
      cancelText: 'common.cancel'.tr(),
      confirmText: 'common.ok'.tr(),
      barrierColor: Colors.black.withValues(alpha: 0.30),
      builder: (context, child) {
        const turquoise = Color(0xFF00B8D9);
        const dark = Color(0xFF006D77);
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: turquoise,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF0F172A),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 6,
              shadowColor: Colors.black.withValues(alpha: 0.20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              headerBackgroundColor: turquoise,
              headerForegroundColor: Colors.white,
              headerHeadlineStyle: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
              headerHelpStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              todayForegroundColor: const WidgetStatePropertyAll(dark),
              todayBorder: const BorderSide(color: turquoise, width: 1.4),
              dayShape: const WidgetStatePropertyAll(CircleBorder()),
              weekdayStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
              dayStyle: const TextStyle(fontWeight: FontWeight.w500),
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: turquoise,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _dateBox(
                  context,
                  'date.start_date'.tr(),
                  date1,
                  onDate1Changed,
                  last: date2,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dateBox(
                  context,
                  'date.end_date'.tr(),
                  date2,
                  onDate2Changed,
                  first: date1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B8D9), Color(0xFF006D77)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B8D9).withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onApply,
                icon: const Icon(Icons.filter_alt),
                label: Text('date.filter'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _presetButton('date.today'.tr(), () {
                  final today = DateTime(now.year, now.month, now.day);
                  onPreset(today, today);
                }),
                const SizedBox(width: 8),
                _presetButton('date.last_year_today'.tr(), () {
                  final d = DateTime(now.year - 1, now.month, now.day);
                  onPreset(d, d);
                }),
                const SizedBox(width: 8),
                _presetButton('date.last_year_this_month'.tr(), () {
                  final start = DateTime(now.year - 1, now.month, 1);
                  final end = DateTime(now.year - 1, now.month + 1, 0);
                  onPreset(start, end);
                }),
                const SizedBox(width: 8),
                _presetButton('date.last_year'.tr(), () {
                  final start = DateTime(now.year - 1, 1, 1);
                  final end = DateTime(now.year - 1, 12, 31);
                  onPreset(start, end);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _presetButton(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.white,
      labelStyle: const TextStyle(
        color: Color(0xFF006D77),
        fontWeight: FontWeight.w600,
      ),
      side: const BorderSide(color: Color(0x5500B8D9)),
      shape: const StadiumBorder(),
      elevation: 0,
      pressElevation: 2,
    );
  }

  Widget _dateBox(
    BuildContext context,
    String label,
    DateTime value,
    ValueChanged<DateTime> onChanged, {
    DateTime? first,
    DateTime? last,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _pick(context, value, onChanged, first: first, last: last),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _fmt(value),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.calendar_today,
                size: 18,
                color: Color(0xFF00B8D9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
