import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aquapark/core/di/locator.dart';
import 'package:aquapark/modules/dailysales/daily_sales_service.dart';
import 'package:aquapark/modules/dailysales/daily_sales_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:aquapark/modules/dailysales/daily_sales_detail_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aquapark/core/widgets/global_dialog.dart';

//fiyatların renkleri
Color _getAmountColor(
  double value, {
  bool isCancelled = false,
  Color zeroColor = const Color(0xFF111827),
}) {
  if (isCancelled) return const Color(0xFF94A3B8);
  final rounded = double.parse(value.toStringAsFixed(2));
  if (rounded < 0) return const Color(0xFFEF4444);
  if (rounded > 0) return const Color(0xFF22C55E);
  return zeroColor;
}

class DailySalesPage extends StatefulWidget {
  const DailySalesPage({super.key});

  @override
  State<DailySalesPage> createState() => _DailySalesPageState();
}

class _DailySalesPageState extends State<DailySalesPage>
    with SingleTickerProviderStateMixin {
  final _service = getIt<DailySalesService>();
  final ScrollController _scrollController = ScrollController();

  StreamSubscription<String?>? _errorSub;
  bool _dialogOpen = false;
  final BehaviorSubject<bool> _showSummary = BehaviorSubject<bool>.seeded(true);

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _service.initDate();
    _service.load();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves
          .easeOutCubic,
    );
    //kayma efekti
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.05), //widget boyutuna göre
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
        );

    //animasyonu başlngıçtan sona doğru oynatır
    _fadeController.forward();

    //hata mesajı var mı?
    _errorSub = _service.error.listen((err) {
      if (err != null && mounted) _showErrorDialog(err);
    });
  }

  //sayfa kap<tıldığınnda kaynaklar temizleneir
  @override
  void dispose() {
    _scrollController.dispose();
    _showSummary.close();
    _fadeController.dispose();
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

  String _formatCurrency(double val) {
    final isNegative = val < 0;
    final absVal = val.abs();
    final parts = absVal.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.');
      buf.write(intPart[i]);
    }
    final formattedAbs = '${buf.toString()},$decPart';
    final sign = isNegative ? '-' : '';
    return '$sign$formattedAbs ₺';
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'date.select_date'.tr(),
      cancelText: 'common.cancel'.tr(),
      confirmText: 'common.ok'.tr(),
      barrierColor: Colors.black.withValues(alpha: 0.40),
      builder: (context, child) {
        const primarySky = Color(0xFF0EA5E9);
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: primarySky,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF111827),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              headerBackgroundColor: primarySky,
              headerForegroundColor: Colors.white,
              headerHeadlineStyle: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: primarySky,
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _service.setDate(picked);
         }
  }

  //tarih metni
  String _formatLocalizedDate(BuildContext context, DateTime date) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'date.today'.tr();
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'date.yesterday'.tr();
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'date.tomorrow'.tr();
    }

    return DateFormat('d MMMM EEEE', context.locale.toString()).format(date);
  }

  //tarih gezinme bölümü
  Widget _dayNavigationSection(BuildContext context, DateTime selectedDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          _NavigationArrowButton(
            icon: Icons.chevron_left_rounded,
            onPressed: () {
              final newDate = selectedDate.subtract(const Duration(days: 1));
              _service.setDate(newDate);
              _service.load();
            },
          ),
          const SizedBox(width: 6),

          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                //tarih alanına dokunma özelliği
                onTap: () => _selectDate(context, selectedDate),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 15,
                        color: Color(0xFF0EA5E9),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _formatLocalizedDate(context, selectedDate),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            letterSpacing: -0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_drop_down_rounded,
                        size: 18,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Tarihi 1 gün ileriye götüren buton
          _NavigationArrowButton(
            icon: Icons.chevron_right_rounded,
            onPressed: () {
              final newDate = selectedDate.add(const Duration(days: 1));
              _service.setDate(newDate);
              _service.load();
            },
          ),
          const SizedBox(width: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              //dokunma
              onTap: () => _service.load(),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0EA5E9).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.filter_alt_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'date.filter'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //ekran boşsa gelir
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 48,
        ), //yatay , dikey
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 40,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'daily_sales_page.empty.title'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'daily_sales_page.empty.description'.tr(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  //satış kartı oluşturma
  Widget _buildSalesCard(DailySalesRow row) {
    return _SalesCardWidget(
      row: row,
      formatCurrency: _formatCurrency,
      onTap: () => _openSalesDetail(row),
    );
  }

  //Sadece kartın checkId değeri detay sayfasına gönderilecek.
  Future<void> _openSalesDetail(DailySalesRow row) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailySalesDetailPage(checkId: row.checkId),
      ),
    );
  }

  //gün sonu
  Widget _buildSummarySticky(List<DailySalesRow> list) {
    double totalExpense = 0;
    double totalPayment = 0;
    double totalBalance = 0;

    for (final row in list) {
      totalExpense += row.expense;
      totalPayment += row.payment;
      totalBalance += row.balance;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 54,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'daily_sales_page.summary.title'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const SizedBox(height: 6),
                    //BİLET KUTUSU
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Text(
                        'daily_sales_page.summary.ticket_count'.tr(
                          args: ['${list.length}'],
                        ),
                        style: const TextStyle(
                          color: Color(0xFFF1F5F9),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _showSummary.add(false);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  title: 'daily_sales_page.summary.expense'.tr(),
                  amount: totalExpense,
                  alignment: CrossAxisAlignment.start,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  title: 'daily_sales_page.summary.payment'.tr(),
                  amount: totalPayment,
                  alignment: CrossAxisAlignment.center,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  title: 'daily_sales_page.summary.net_balance'.tr(),
                  amount: totalBalance,
                  alignment: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String title,
    required double amount,
    required CrossAxisAlignment alignment,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _formatCurrency(amount),
            style: TextStyle(
              color: _getAmountColor(amount, zeroColor: Colors.white),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ),
      ],
    );
  }

  // Sekme çubuğu. tüm kayıt üye iptal
  Widget _buildTabBar(
    int allCount,
    int memberCount,
    int activeReservationCount,
    int cancelCount,
    int selectedTab,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Container(
        height: 52,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(26),
        ),
        child: ListView(
          scrollDirection: Axis.horizontal, //yatayda kaydırılabilir
          physics: const BouncingScrollPhysics(),
          children: [
            _buildScrollableTabItem(
              title: 'daily_sales_page.tabs.all_records'.tr(),
              count: allCount,
              tabIndex: 0,
              selectedTab: selectedTab,
              width: 112,
            ),
            _buildScrollableTabItem(
              title: 'daily_sales_page.tabs.active_reservations'.tr(),
              count: activeReservationCount,
              tabIndex: 2,
              selectedTab: selectedTab,
              width: 120,
            ),

            _buildScrollableTabItem(
              title: 'daily_sales_page.tabs.members'.tr(),
              count: memberCount,
              tabIndex: 1,
              selectedTab: selectedTab,
              width: 90,
            ),
            _buildScrollableTabItem(
              title: 'daily_sales_page.tabs.cancelled'.tr(),
              count: cancelCount,
              tabIndex: 3,
              selectedTab: selectedTab,
              width: 90,
              isCancelTab: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableTabItem({
    required String title,
    required int count,
    required int tabIndex,
    required int selectedTab,
    required double width,
    bool isCancelTab = false,
  }) {
    final bool isSelected = selectedTab == tabIndex;

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            _service.selectedTab.add(tabIndex);

            if (tabIndex == 3) {
              await _service.loadCancelled();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF111827)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? isCancelTab
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF0EA5E9)
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text('daily_sales_page.title'.tr()),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleTextStyle: const TextStyle(
          color: Color(0xFF111827),
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        actions: [
          StreamBuilder<bool>(
            stream: _service.loading,
            initialData: false,
            builder: (context, snapshot) {
              final loading = snapshot.data ?? false;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder<bool>(
                    stream: _showSummary,
                    initialData: _showSummary.value,
                    builder: (context, snapshot) {
                      final showSummary = snapshot.data ?? true;

                      if (showSummary) {
                        return const SizedBox.shrink();
                      }

                      return IconButton(
                        tooltip: 'daily_sales_page.show_end_of_day_summary'
                            .tr(),
                        onPressed: () {
                          _showSummary.add(true);
                        },
                        icon: const Icon(
                          Icons.assessment_rounded,
                          size: 23,
                          color: Color(0xFF0EA5E9),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 22),
                    onPressed: loading
                        ? null
                        : _service
                              .load,
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        //sayfanın yavaşca görünmesi
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              StreamBuilder<DateTime>(
                stream:
                    _service.selectedDate,
                builder: (context, snapshot) {
                  final selectedDate =
                      snapshot.data;
                  if (selectedDate == null) return const SizedBox.shrink();
                  return _dayNavigationSection(context, selectedDate);
                },
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              Expanded(
                child: StreamBuilder<bool>(
                  stream: _service.loading,
                  initialData: true,
                  builder: (context, snapshot) {
                    final loading = snapshot.data ?? false;
                    if (loading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0EA5E9),
                        ),
                      );
                    }
                    return StreamBuilder<List<DailySalesRow>>(
                      //satış listesi
                      stream: _service.salesRows,
                      initialData: const [],
                      builder: (context, snapshot) {
                        final list = snapshot.data ?? [];

                        final allList = list;

                        final memberList = allList
                            .where((row) => row.isParkMember)
                            .toList();

                        final activeReservationList = allList
                            .where((row) => !row.checkClosed)
                            .toList();

                            return StreamBuilder<List<DailySalesRow>>(
                              stream: _service.cancelledRows,
                              initialData: const [],
                              builder: (context, cancelledSnapshot) {
                              final cancelList = cancelledSnapshot.data ?? [];

                            return StreamBuilder<int>(
                              stream: _service.selectedTab,
                              initialData: 0,
                              builder: (context, tabSnapshot) {

                            final selectedTab = tabSnapshot.data ?? 0;
                            final List<DailySalesRow> currentList;

                            switch (selectedTab) {
                              case 0:
                                currentList = allList;
                                break;

                              case 1:
                                currentList = memberList;
                                break;

                              case 2:
                                currentList = activeReservationList;
                                break;

                              case 3:
                                currentList = cancelList;
                                break;

                              default:
                                currentList = allList;
                            }

                            return Column(
                              children: [
                                _buildTabBar(
                                  allList.length,
                                  memberList.length,
                                  activeReservationList.length,
                                  cancelList.length,
                                  selectedTab,
                                ),
                                Expanded(
                                  child: currentList.isEmpty
                                      ? _buildEmptyState()
                                      : Scrollbar(
                                          controller: _scrollController,
                                          thumbVisibility: true,
                                          radius: const Radius.circular(20),
                                          thickness: 6,
                                          child: ListView.builder(
                                            controller: _scrollController,
                                            padding: const EdgeInsets.only(
                                              left: 24,
                                              right: 24,
                                              top: 8,
                                              bottom: 20,
                                            ),
                                            itemCount: currentList.length,
                                            itemBuilder: (context, index) {
                                              return _buildSalesCard(
                                                currentList[index],
                                              );
                                            },
                                          ),
                                        ),
                                ),

                                if (currentList.isNotEmpty)
                                  StreamBuilder<bool>(
                                    stream: _showSummary,
                                    initialData: _showSummary.value,
                                    builder: (context, snapshot) {
                                      final showSummary = snapshot.data ?? true;

                                      if (!showSummary) {
                                        return const SizedBox.shrink();
                                      }

                                      return _buildSummarySticky(currentList);
                                    },
                                  ),
                              ],
                            );

                          },
                        );
                      },
                    );
                              },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//satış kartı dokunma animasyonlu
class _SalesCardWidget extends StatefulWidget {
  final DailySalesRow row;
  final String Function(double) formatCurrency;
  final VoidCallback onTap;

  const _SalesCardWidget({
    super.key,
    required this.row,
    required this.formatCurrency,
    required this.onTap,
  });

  @override
  State<_SalesCardWidget> createState() => _SalesCardWidgetState();
}

class _SalesCardWidgetState extends State<_SalesCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //boş alanları gösterme
    final row = widget.row;
    final hasWaiter =
        row.waiterName != null && row.waiterName!.trim().isNotEmpty;
    final hasCashier =
        row.cashierName != null && row.cashierName!.trim().isNotEmpty;
    final hasAgency =
        row.posCardFullName != null && row.posCardFullName!.trim().isNotEmpty;
    final isCancelled =
        row.cancelCheckId != null &&
        row.cancelCheckId! > 0;

    String timeStr = '';
    if (row.openTime.length >= 16) {
      timeStr = row.openTime.substring(11, 16);
    } else {
      timeStr = row.openTime;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Opacity(
        //iptal kartları daha opak
        opacity: isCancelled ? 0.65 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.01),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTapDown: (_) => _controller.forward(),
                onTapUp: (_) => _controller.reverse(),
                onTapCancel: () => _controller.reverse(),
                onTap: widget.onTap,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: isCancelled
                            ? const Color(0xFF94A3B8)
                            : (row.isParkMember
                                  ? const Color(0xFF0EA5E9)
                                  : Colors.transparent),
                        width: 6,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '#${row.id}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF111827),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (timeStr.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_filled_rounded,
                                        size: 10,
                                        color: Color(0xFF6B7280),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        timeStr,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            children: [
                              // Durum etiketi: İptal / Kapalı / Rezervasyon
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isCancelled
                                      ? const Color(0xFFFEE2E2)
                                      : row.checkClosed
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isCancelled
                                      ? 'daily_sales_page.card.cancelled'.tr()
                                      : row.checkClosed
                                      ? 'daily_sales_page.card.closed'.tr()
                                      : 'daily_sales_page.card.reservation'
                                            .tr(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isCancelled
                                        ? const Color(0xFFEF4444)
                                        : row.checkClosed
                                        ? const Color(0xFF22C55E)
                                        : const Color(0xFFF59E0B),
                                  ),
                                ),
                              ),

                              if (row.isParkMember) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2FE),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'daily_sales_page.card.member'.tr(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0EA5E9),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.storefront_rounded,
                              size: 15,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  row.departmentName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'daily_sales_page.card.transaction_code'.tr(
                                    args: [row.userCode],
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (hasCashier || hasWaiter || hasAgency) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              if (hasCashier)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.point_of_sale_rounded,
                                      size: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'daily_sales_page.card.cashier'.tr(
                                        args: [row.cashierName ?? ''],
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                              if (hasCashier && (hasWaiter || hasAgency))
                                const SizedBox(height: 6),
                              if (hasWaiter)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.restaurant_menu_rounded,
                                      size: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'daily_sales_page.card.waiter'.tr(
                                        args: [row.waiterName ?? ''],
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                              if (hasWaiter && hasAgency)
                                const SizedBox(height: 6),
                              if (hasAgency)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.business_rounded,
                                      size: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'daily_sales_page.card.agency'.tr(
                                        args: [row.posCardFullName ?? ''],
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'daily_sales_page.summary.expense'.tr(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.formatCurrency(row.expense),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _getAmountColor(
                                    row.expense,
                                    isCancelled: isCancelled,
                                  ),
                                  letterSpacing: -0.2,
                                  decoration: isCancelled
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'daily_sales_page.summary.payment'.tr(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.formatCurrency(row.payment),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _getAmountColor(
                                    row.payment,
                                    isCancelled: isCancelled,
                                  ),
                                  letterSpacing: -0.2,
                                  decoration: isCancelled
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'daily_sales_page.card.balance'.tr(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.formatCurrency(row.balance),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: _getAmountColor(
                                    row.balance,
                                    isCancelled: isCancelled,
                                  ),
                                  letterSpacing: -0.2,
                                  decoration: isCancelled
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFBAE6FD),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'daily_sales_page.card.view_details'.tr(),
                                style: const TextStyle(
                                  color: Color(0xFF0284C7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: Color(0xFF0284C7),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _NavigationArrowButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_NavigationArrowButton> createState() => _NavigationArrowButtonState();
}

class _NavigationArrowButtonState extends State<_NavigationArrowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController
  _controller;
  late Animation<double>
  _scaleAnimation;

  @override
  void initState() {
    super.initState();
    //dokunma animasyonu
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.90).animate(
      //ok butonu animasyonu
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onPressed,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(widget.icon, size: 20, color: const Color(0xFF111827)),
        ),
      ),
    );
  }
}
