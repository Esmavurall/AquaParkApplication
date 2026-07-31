num _num(dynamic v) => v is num ? v : (num.tryParse('${v ?? ''}') ?? 0);

String _str(dynamic v) => v?.toString() ?? '';

Map<String, dynamic>? _firstMap(dynamic data) {
  if (data is Map) return Map<String, dynamic>.from(data);
  if (data is List) {
    for (final e in data) {
      final m = _firstMap(e);
      if (m != null) return m;
    }
  }
  return null;
}

class DashboardMetrics {
  final num agencyAdultPax;
  final num agencyChildPax;
  final num walkinAdultPax;
  final num walkinChildPax;
  final num membershipAdultPax;
  final num membershipChildPax;
  final num totalAdultPax;
  final num totalChildPax;
  final num agencyTotalPrice;
  final num walkinTotalPrice;
  final num membershipTotalPrice;
  final num totalPrice;

  const DashboardMetrics({
    this.agencyAdultPax = 0,
    this.agencyChildPax = 0,
    this.walkinAdultPax = 0,
    this.walkinChildPax = 0,
    this.membershipAdultPax = 0,
    this.membershipChildPax = 0,
    this.totalAdultPax = 0,
    this.totalChildPax = 0,
    this.agencyTotalPrice = 0,
    this.walkinTotalPrice = 0,
    this.membershipTotalPrice = 0,
    this.totalPrice = 0,
  });

  static const empty = DashboardMetrics();

  factory DashboardMetrics.fromJson(Map<String, dynamic> j) => DashboardMetrics(
    agencyAdultPax: _num(j['AGENCY_ADULTPAX']),
    agencyChildPax: _num(j['AGENCY_CHILDPAX']),
    walkinAdultPax: _num(j['WALKIN_ADULTPAX']),
    walkinChildPax: _num(j['WALKIN_CHILDPAX']),
    membershipAdultPax: _num(j['MEMBERSHIP_ADULTPAX']),
    membershipChildPax: _num(j['MEMBERSHIP_CHILDPAX']),
    totalAdultPax: _num(j['TOTAL_ADULTPAX']),
    totalChildPax: _num(j['TOTAL_CHILDPAX']),
    agencyTotalPrice: _num(j['AGENCY_TOTALPRICE']),
    walkinTotalPrice: _num(j['WALKIN_TOTALPRICE']),
    membershipTotalPrice: _num(j['MEMBERSHIP_TOTALPRICE']),
    totalPrice: _num(j['TOTALPRICE']),
  );
}

class PaymentRow {
  final String departmentName;
  final num payment;
  const PaymentRow({required this.departmentName, required this.payment});

  factory PaymentRow.fromJson(Map<String, dynamic> j) => PaymentRow(
    departmentName: _str(j['DEPARTMENTNAME']),
    payment: _num(j['PAYMENT']),
  );
}

class RevenueRow {
  final String checkDepartmentName;
  final num total;
  const RevenueRow({required this.checkDepartmentName, required this.total});

  factory RevenueRow.fromJson(Map<String, dynamic> j) => RevenueRow(
    checkDepartmentName: _str(j['CHECK_DEPARTMENTNAME']),
    total: _num(j['TOTAL']),
  );
}

class TicketRow {
  final String ticket;
  final num quantity;
  const TicketRow({required this.ticket, required this.quantity});

  factory TicketRow.fromJson(Map<String, dynamic> j) => TicketRow(
    ticket: _str(j['TICKET']),
    quantity: _num(j['QUANTITY']),
  );
}

class TurnstileRow {
  final String groupName;
  final num enteranceCount;
  const TurnstileRow({required this.groupName, required this.enteranceCount});

  factory TurnstileRow.fromJson(Map<String, dynamic> j) => TurnstileRow(
    groupName: _str(j['GROUPNAME']),
    enteranceCount: _num(j['ENTERANCECOUNT']),
  );
}

class DashboardData {
  final DashboardMetrics metrics;
  final List<PaymentRow> payments;
  final List<RevenueRow> revenues;
  final List<TicketRow> tickets;
  final List<TurnstileRow> turnstiles;

  const DashboardData({
    required this.metrics,
    required this.payments,
    required this.revenues,
    required this.tickets,
    required this.turnstiles,
  });

  static const empty = DashboardData(
    metrics: DashboardMetrics.empty,
    payments: [],
    revenues: [],
    tickets: [],
    turnstiles: [],
  );

  factory DashboardData.fromResponse(dynamic decoded) {
    if (decoded is! List) return empty;

    List<dynamic> arr(int i) =>
        (decoded.length > i && decoded[i] is List)
        ? decoded[i] as List<dynamic>
        : const <dynamic>[];

    List<T> mapRows<T>(int i, T Function(Map<String, dynamic>) fromJson) => [
      for (final e in arr(i))
        if (e is Map) fromJson(Map<String, dynamic>.from(e)),
    ];

    final first = decoded.isNotEmpty ? _firstMap(decoded[0]) : null;

    return DashboardData(
      metrics: first != null
          ? DashboardMetrics.fromJson(first)
          : DashboardMetrics.empty,
      payments: mapRows(1, PaymentRow.fromJson),
      revenues: mapRows(2, RevenueRow.fromJson),
      tickets: mapRows(3, TicketRow.fromJson),
      turnstiles: mapRows(4, TurnstileRow.fromJson),
    );
  }
}
