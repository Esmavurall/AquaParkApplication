import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aquapark/core/widgets/global_dialog.dart';

import 'package:aquapark/core/di/locator.dart';
import 'package:aquapark/modules/dashboard/dashboard_service.dart';
import 'package:aquapark/modules/dashboard/dashboard_model.dart';
import 'package:aquapark/modules/dashboard/widgets/date_filter.dart';
import 'package:aquapark/modules/dashboard/widgets/dashboard_chart.dart';


class _Metric {
  final String label;
  final IconData icon;
  final Color color;
  final bool isPrice;
  final num Function(DashboardMetrics m) value;

  const _Metric(
    this.label,
    this.icon,
    this.color,
    this.value, {
    this.isPrice = false,
  });
}

final _metrics = <_Metric>[
  _Metric(
    'dashboard_page.metrics.agency_adult',
    Icons.family_restroom,
    const Color(0xFFC62828),
        (m) => m.agencyAdultPax,
  ),
  _Metric(
    'dashboard_page.metrics.agency_child',
    Icons.child_care,
    const Color(0xFF2E7D32),
        (m) => m.agencyChildPax,
  ),
  _Metric(
    'dashboard_page.metrics.walkin_adult',
    Icons.directions_run,
    const Color(0xFFC62828),
        (m) => m.walkinAdultPax,
  ),
  _Metric(
    'dashboard_page.metrics.walkin_child',
    Icons.directions_walk,
    const Color(0xFF2E7D32),
        (m) => m.walkinChildPax,
  ),
  _Metric(
    'dashboard_page.metrics.member_adult',
    Icons.badge,
    const Color(0xFF00897B),
        (m) => m.membershipAdultPax,
  ),
  _Metric(
    'dashboard_page.metrics.member_child',
    Icons.emoji_people,
    const Color(0xFF00897B),
        (m) => m.membershipChildPax,
  ),
  _Metric(
    'dashboard_page.metrics.total_adult',
    Icons.groups,
    const Color(0xFFC62828),
        (m) => m.totalAdultPax,
  ),
  _Metric(
    'dashboard_page.metrics.total_child',
    Icons.groups_2,
    const Color(0xFF2E7D32),
        (m) => m.totalChildPax,
  ),
  _Metric(
    'dashboard_page.metrics.agency_total',
    Icons.attach_money,
    const Color(0xFFEF6C00),
        (m) => m.agencyTotalPrice,
    isPrice: true,
  ),
  _Metric(
    'dashboard_page.metrics.walkin_total',
    Icons.attach_money,
    const Color(0xFFEF6C00),
        (m) => m.walkinTotalPrice,
    isPrice: true,
  ),
  _Metric(
    'dashboard_page.metrics.member_total',
    Icons.attach_money,
    const Color(0xFF00897B),
        (m) => m.membershipTotalPrice,
    isPrice: true,
  ),
  _Metric(
    'dashboard_page.metrics.total_entrance_revenue',
    Icons.payments,
    const Color(0xFF2E7D32),
        (m) => m.totalPrice,
    isPrice: true,
  ),
];

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _service = getIt<DashboardService>();

  StreamSubscription<String?>? _errorSub;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    _service.initDates();
    _service.load();
    
    _errorSub = _service.error.listen((err) {
      if (err != null && mounted) _showErrorDialog(err);
    });
  }

  @override
  void dispose() {
    _errorSub?.cancel();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    if (_dialogOpen) return;

    _dialogOpen = true;

    showDialogBanner(
      DialogType.error,
      message,
      context,
    ).then((_) {
      _dialogOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'dashboard_page.title'.tr(),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleTextStyle: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        actions: [
          StreamBuilder<bool>(
            stream: _service.loading,
            initialData: false,
            builder: (context, snapshot) {
              final loading = snapshot.data ?? false;
              return IconButton(
                tooltip: 'common.refresh'.tr(),
                icon: const Icon(Icons.refresh),
                onPressed: loading ? null : _service.load,
              );
            },
          ),
        ],
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton(
                heroTag: 'geri',
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF00B8D9),
                elevation: 4,
                shape: const CircleBorder(),
                onPressed: () => _service.shift(-1),
                child: const Icon(Icons.chevron_left_rounded, size: 28),
              ),
              FloatingActionButton(
                heroTag: 'ileri',
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF00B8D9),
                elevation: 4,
                shape: const CircleBorder(),
                onPressed: () => _service.shift(1),
                child: const Icon(Icons.chevron_right_rounded, size: 28),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          StreamBuilder<List<DateTime>>(
            stream: Rx.combineLatest2(
              _service.date1,
              _service.date2,
              (DateTime a, DateTime b) => [a, b],
            ),
            builder: (context, snapshot) {
              final dates = snapshot.data;
              if (dates == null) return const SizedBox.shrink();
              return DateFilter(
                date1: dates[0],
                date2: dates[1],
                onDate1Changed: _service.setDate1,
                onDate2Changed: _service.setDate2,
                onApply: _service.load,
                onPreset: _service.setRange,
              );
            },
          ),
          const Divider(height: 1),
          
          Expanded(
            child: StreamBuilder<bool>(
              stream: _service.loading,
              initialData: true,
              builder: (context, snapshot) {
                final loading = snapshot.data ?? false;
                if (loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildContent();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<DashboardMetrics>(
            stream: _service.metrics,
            initialData: DashboardMetrics.empty,
            builder: (context, snapshot) {
              final data = snapshot.data ?? DashboardMetrics.empty;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.3,
                ),
                itemCount: _metrics.length,
                itemBuilder: (context, index) {
                  final metric = _metrics[index];
                  return _metricCard(
                    metric,
                    _formatValue(metric.value(data), metric.isPrice),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),

      _chartCard<TicketRow>(
        'dashboard_page.tickets'.tr(),
        _service.biletler,
            (rows) => _slices([
          for (final row in rows)
            (
            label: row.ticket,
            value: row.quantity,
            ),
        ]),
      ),

      _chartCard<RevenueRow>(
        'dashboard_page.revenues'.tr(),
        _service.gelirler,
            (rows) => _slices([
          for (final row in rows)
            (
            label: row.checkDepartmentName,
            value: row.total,
            ),
        ]),
      ),

      _chartCard<TurnstileRow>(
        'dashboard_page.turnstile_passages'.tr(),
        _service.turnike,
            (rows) => _slices([
          for (final row in rows)
            (
            label: row.groupName,
            value: row.enteranceCount,
            ),
        ]),
      ),

      _chartCard<PaymentRow>(
        'dashboard_page.payments'.tr(),
        _service.odeme,
            (rows) => _slices([
          for (final row in rows)
            (
            label: row.departmentName,
            value: row.payment,
            ),
        ]),
      ),
        ],
      ),
    );
  }

  Widget _chartCard<T>(
    String title,
    Stream<List<T>> arrayStream,
    List<ChartDatum> Function(List<T> rows) toChart,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          // grafik verisini dinler
          StreamBuilder<List<T>>(
            stream: arrayStream,
            builder: (context, snapshot) {
              final rows = snapshot.data ?? <T>[];
              return MiniPieChart(data: toChart(rows));
            },
          ),
        ],
      ),
    );
  }

  static const _chartColors = [
    Color(0xFF1E88E5),
    Color(0xFFEF6C00),
    Color(0xFF00897B),
    Color(0xFFC62828),
    Color(0xFF5E35B1),
    Color(0xFF00ACC1),
    Color(0xFFD81B60),
    Color(0xFF6D4C41),
  ];

  List<ChartDatum> _slices(List<({String label, num value})> items) {
    final out = <ChartDatum>[];
    for (var i = 0; i < items.length; i++) {
      var label = items[i].label;
      if (label.isEmpty) {
        label = 'dashboard_page.default_record'.tr(
          args: ['${i + 1}'],
        );
      }
      if (label.length > 20) label = '${label.substring(0, 20)}…';
      out.add(ChartDatum(
        label,
        items[i].value.toDouble(),
        _chartColors[i % _chartColors.length],
      ));
    }
    return out;
  }

  String _groupThousands(num n) {
    final isInt = n == n.roundToDouble();
    final str = isInt ? n.toInt().toString() : n.toStringAsFixed(3);
    final parts = str.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.');
      buf.write(intPart[i]);
    }
    return parts.length > 1 ? '${buf.toString()},${parts[1]}' : buf.toString();
  }

  String _formatValue(dynamic raw, bool isPrice) {
    final n = raw is num ? raw : num.tryParse('${raw ?? ''}');
    final formatted = n == null ? '0' : _groupThousands(n);
    return isPrice ? '$formatted ₺' : formatted;
  }

  Widget _metricCard(_Metric m, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: m.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(m.icon, color: m.color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                m.label.tr(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
