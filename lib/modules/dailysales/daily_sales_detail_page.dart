import 'dart:async';

import 'package:flutter/material.dart';

import 'package:aquapark/core/di/locator.dart';
import 'package:aquapark/modules/dailysales/daily_sales_model.dart';
import 'package:aquapark/modules/dailysales/daily_sales_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aquapark/core/widgets/global_dialog.dart';


class DailySalesDetailPage extends StatefulWidget {
  final int checkId;

  const DailySalesDetailPage({super.key, required this.checkId});

  @override
  State<DailySalesDetailPage> createState() => _DailySalesDetailPageState();
}

class _DailySalesDetailPageState extends State<DailySalesDetailPage> {
  final DailySalesService _service = getIt<DailySalesService>();

  StreamSubscription<String?>? _errorSubscription;

  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();

    _service.clearDetailPage();

    _service.loadDetailPage(checkId: widget.checkId);

    _errorSubscription = _service.detailError.listen((error) {
      if (error != null && mounted) {
        _showErrorDialog(error);
      }
    });
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    super.dispose();
  }

  Future<void> _refreshDetail() async {
    await _service.refreshCurrentDetailTab(checkId: widget.checkId);
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

  String _formatCurrency(double value) {
    final isNegative = value < 0;
    final absoluteValue = value.abs();

    final parts = absoluteValue.toStringAsFixed(2).split('.');

    final integerPart = parts[0];
    final decimalPart = parts[1];

    final buffer = StringBuffer();

    for (var i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(integerPart[i]);
    }

    final sign = isNegative ? '-' : '';

    return '$sign${buffer.toString()},$decimalPart ₺';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DailySalesRow?>(
      stream: _service.checkDetail,
      initialData: _service.checkDetail.valueOrNull,
      builder: (context, detailSnapshot) {
        final detail = detailSnapshot.data;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            title: Text(
              detail == null
                  ? 'daily_sales_detail.title'.tr()
                  : detail.checkNo.isEmpty
                  ? 'daily_sales_detail.ticket'.tr(args: ['${detail.id}'])
                  : 'daily_sales_detail.ticket_number'.tr(
                args: [detail.checkNo],
              ),
            ),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF111827),
            surfaceTintColor: Colors.white,
            elevation: 0,
            actions: [
              StreamBuilder<bool>(
                stream: _service.detailExpanded,
                initialData: _service.detailExpanded.value,
                builder: (context, snapshot) {
                  final isExpanded = snapshot.data ?? true;

                  return IconButton(
                    tooltip: 'daily_sales_detail.information.other_ticket_information'.tr(),
                    onPressed: detail == null
                        ? null
                        : _service.toggleDetailExpanded,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isExpanded
                            ? Icons.visibility_off_outlined
                            : Icons.info_outline_rounded,
                        key: ValueKey(isExpanded),
                        color: isExpanded
                            ? const Color(0xFF0284C7)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  );
                },
              ),
              StreamBuilder<bool>(
                stream: _service.detailLoading,
                initialData: _service.detailLoading.value,
                builder: (context, snapshot) {
                  final isLoading = snapshot.data ?? false;

                  return IconButton(
                    tooltip: 'daily_sales_detail.refresh'.tr(),
                    onPressed: isLoading ? null : _refreshDetail,
                    icon: const Icon(Icons.refresh_rounded),
                  );
                },
              ),
            ],
          ),
          body: StreamBuilder<bool>(
            stream: _service.detailLoading,
            initialData: _service.detailLoading.value,
            builder: (context, loadingSnapshot) {
              final isLoading = loadingSnapshot.data ?? false;

              if (isLoading && detail == null) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
                );
              }

              if (detail == null) {
                return _buildEmptyState();
              }

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  _buildInformationPanel(detail),
                  const SizedBox(height: 18),
                  _buildDetailTabs(),

                  const SizedBox(height: 16),

                  _buildSelectedDetailSection(),

                  const SizedBox(height: 30),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 74,
              height: 74,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFE0F2FE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 36,
                color: Color(0xFF0284C7),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'daily_sales_detail.empty.title'.tr(),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'daily_sales_detail.empty.description'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _refreshDetail,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('daily_sales_detail.empty.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationPanel(DailySalesRow detail) {
    return StreamBuilder<bool>(
      stream: _service.detailExpanded,
      initialData: _service.detailExpanded.value,
      builder: (context, snapshot) {
        final isExpanded = snapshot.data ?? true;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 21,
                    color: Color(0xFF0284C7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'daily_sales_detail.title'.tr(),
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _readOnlyField(
                      label: 'daily_sales_detail.information.check_date'.tr(),
                      value: _formatDetailDate(detail.checkDate),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _readOnlyField(
                      label: 'daily_sales_detail.information.address'.tr(),
                      value: detail.addressInfo,
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Column(
                    children: [
                      _readOnlyField(
                        label: 'daily_sales_detail.information.check_id'.tr(),
                        value: detail.checkId,
                      ),
                      const SizedBox(height: 10),
                      _readOnlyField(
                        label: 'daily_sales_detail.information.department_name'.tr(),
                        value: detail.departmentName,
                      ),
                      const SizedBox(height: 10),
                      _readOnlyField(
                        label: 'daily_sales_detail.information.opening_time'.tr(),
                        value: detail.openTime,
                      ),
                      const SizedBox(height: 10),
                      _readOnlyField(
                        label: 'daily_sales_detail.information.closing_time'.tr(),
                        value: detail.closeTime,
                      ),
                      const SizedBox(height: 10),
                      _readOnlyField(
                        label: 'daily_sales_detail.information.table_name'.tr(),
                        value: detail.tableNo,
                      ),
                      const SizedBox(height: 10),
                      _readOnlyField(
                        label: 'daily_sales_detail.information.check_type'.tr(),
                        value: detail.posCheckType,
                      ),
                      const SizedBox(height: 10),
                      _readOnlyField(
                        label: 'daily_sales_detail.information.waiter_name'.tr(),
                        value: detail.waiterName,
                      ),
                      const SizedBox(height: 10),
                      _readOnlyField(
                        label: 'daily_sales_detail.information.cashier_name'.tr(),
                        value: detail.cashierName,
                      ),
                      const SizedBox(height: 10),
                      _readOnlyField(
                        label: 'daily_sales_detail.information.check_number'.tr(),
                        value: detail.checkNo,
                      ),
                      const SizedBox(height: 10),
                      _readOnlyField(
                        label: 'daily_sales_detail.information.document_type'.tr(),
                        value: detail.docNoType,
                      ),
                      const SizedBox(height: 10),
                      _readOnlyField(
                        label: 'daily_sales_detail.information.document_number'.tr(),
                        value: detail.docNo,
                      ),
                      const SizedBox(height: 10),
                      _readOnlyField(
                        label: 'daily_sales_detail.information.pos_card_name'.tr(),
                        value: detail.posCardFullName,
                      ),
                      const SizedBox(height: 10),
                      _readOnlyField(
                        label: 'daily_sales_detail.information.hotel_guest'.tr(),
                        value: detail.hotelFullName ?? detail.guestName,
                      ),
                      const SizedBox(height: 10),
                      _readOnlyField(
                        label: 'daily_sales_detail.information.notes'.tr(),
                        value: detail.notes,
                      ),
                    ],
                  ),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailTabs() {
    return StreamBuilder<int>(
      stream: _service.selectedDetailTab,
      initialData: _service.selectedDetailTab.value,
      builder: (context, snapshot) {
        final selectedTab = snapshot.data ?? 0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF2F6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildDetailTabItem(
                  title: 'daily_sales_detail.tabs.products'.tr(),
                  icon: Icons.shopping_bag_outlined,
                  index: 0,
                  isSelected: selectedTab == 0,
                ),
              ),

              const SizedBox(width: 6),

              Expanded(
                child: _buildDetailTabItem(
                  title: 'daily_sales_detail.tabs.payments'.tr(),
                  icon: Icons.payments_outlined,
                  index: 1,
                  isSelected: selectedTab == 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailTabItem({
    required String title,
    required IconData icon,
    required int index,
    required bool isSelected,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        _service.changeDetailTab(index: index, checkId: widget.checkId);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 19,
              color: isSelected
                  ? const Color(0xFF0284C7)
                  : const Color(0xFF64748B),
            ),

            const SizedBox(width: 7),

            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF0284C7)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDetailSection() {
    return StreamBuilder<int>(
      stream: _service.selectedDetailTab,
      initialData: _service.selectedDetailTab.value,
      builder: (context, tabSnapshot) {
        final selectedTab = tabSnapshot.data ?? 0;

        return StreamBuilder<bool>(
          stream: _service.detailTabLoading,
          initialData: _service.detailTabLoading.value,
          builder: (context, loadingSnapshot) {
            final isLoading = loadingSnapshot.data ?? false;

            if (isLoading) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 45),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF0284C7)),
                    const SizedBox(height: 14),
                    Text(
                      'daily_sales_detail.loading'.tr(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (selectedTab == 0) {
              return _buildProductsSection();
            }

            return _buildPaymentsSection();
          },
        );
      },
    );
  }

  Widget _buildProductsSection() {
    return StreamBuilder<List<DailySalesProduct>>(
      stream: _service.detailProducts,
      initialData: _service.detailProducts.value,
      builder: (context, snapshot) {
        final products = snapshot.data ?? <DailySalesProduct>[];
        final productsTotal = products.fold<double>(
          0,
              (total, product) => total + product.lineTotal,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 22),
                const SizedBox(width: 8),
                Text(
                  'daily_sales_detail.products.title'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${products.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                _buildSectionTotalBadge(productsTotal),
              ],
            ),

            const SizedBox(height: 12),

            if (products.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 34,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'daily_sales_detail.products.empty'.tr(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...products.map(_buildProductCard),
          ],
        );
      },
    );
  }
  Widget _buildSectionTotalBadge(double total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Text(
        _formatCurrency(total),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0369A1),
        ),
      ),
    );
  }

  String _productQuantityText({
    required int quantity,
    required String price,
    required String currency,
  }) {

    //dil bilgisine uyumlu
    final key = quantity == 1
        ? 'daily_sales_detail.products.quantity_price_one'
        : 'daily_sales_detail.products.quantity_price_other';

    return key.tr(
      args: [
        quantity.toString(),
        price,
        currency,
      ],
    );
  }
  Widget _buildProductCard(DailySalesProduct product) {
    final currencyCode = product.currencyCode.isEmpty
        ? 'TRY'
        : product.currencyCode;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFF2E7D32),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName.isEmpty
                      ? 'daily_sales_detail.products.default_name'.tr()
                      : product.productName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _productQuantityText(
                    quantity: product.quantity.round(),
                    price: product.unitPrice.toStringAsFixed(2),
                    currency: currencyCode,
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),

                if (product.revenueName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'daily_sales_detail.products.revenue_type'.tr(
                      args: [product.revenueName],                    ),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],

                if (product.waiterName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'daily_sales_detail.products.waiter'.tr(
                      args: [product.waiterName ?? ''],
                    ),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],

                if (product.notes != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    product.notes!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

          Text(
            '${product.lineTotal.toStringAsFixed(2)} '
                '$currencyCode',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  // Ödemeler bölümü.
  Widget _buildPaymentsSection() {
    return StreamBuilder<List<DailySalesPayment>>(
      stream: _service.detailPayments.stream,
      initialData: _service.detailPayments.value,
      builder: (context, snapshot) {
        final payments = snapshot.data ?? <DailySalesPayment>[];
        final paymentsTotal = payments.fold<double>(
          0,
              (total, payment) => total + payment.paymentLocal,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.payments_outlined, size: 22),
                const SizedBox(width: 8),
                Text(
                  'daily_sales_detail.payments.title'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${payments.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                _buildSectionTotalBadge(paymentsTotal),
              ],
            ),
            const SizedBox(height: 12),

            if (payments.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.payment_outlined,
                      size: 34,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'daily_sales_detail.payments.empty'.tr(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...payments.map(_buildPaymentCard),
          ],
        );
      },
    );
  }

  Widget _buildPaymentCard(DailySalesPayment payment) {
    final currencyCode = payment.paymentCurrencyCode.isEmpty
        ? 'TRY'
        : payment.paymentCurrencyCode;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.paymentDepartmentName.isEmpty
                      ? 'daily_sales_detail.payments.default_name'.tr()
                      :
                  payment.paymentDepartmentName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _formatPaymentDate(payment.paymentDate),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (payment.waiterName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'daily_sales_detail.payments.performed_by'.tr(
                      args: [payment.waiterName ?? ''],
                    ),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
                if (payment.checkGuestCardNo != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'daily_sales_detail.payments.guest_card_number'.tr(
                      args: [payment.checkGuestCardNo ?? ''],
                    ),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
                if (payment.notes != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    payment.notes!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${payment.payment.toStringAsFixed(2)} '
                '$currencyCode',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  String _formatPaymentDate(String value) {
    if (value.trim().isEmpty) {
      return 'daily_sales_detail.date_not_available'.tr();
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day.$month.$year';
  }

  Widget _readOnlyField({required String label, required Object? value}) {
    final String displayValue = (value?.toString().trim().isEmpty ?? true)
        ? '-'
        : value.toString().trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayValue,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }


  String _formatDetailDate(String value) {
    if (value.trim().isEmpty) {
      return '-';
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day.$month.$year';
  }
}
