
num _num(dynamic value) {
  if (value is num) return value;

  return num.tryParse(
    value?.toString() ?? '',
  ) ??
      0;
}

String _str(dynamic value) {
  return value?.toString() ?? '';
}

int? _nullableInt(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();

  if (text.isEmpty) return null;

  return num.tryParse(text)?.toInt();
}

double? _nullableDouble(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();

  if (text.isEmpty) return null;

  return num.tryParse(text)?.toDouble();
}

bool _bool(dynamic value) {
  if (value is bool) return value;

  if (value is num) {
    return value != 0;
  }

  if (value is String) {
    final normalizedValue = value.trim().toLowerCase();

    return normalizedValue == 'true' ||
        normalizedValue == '1' ||
        normalizedValue == 'yes';

  }

  return false;
}
String? _nullableStr(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();

  if (text.isEmpty || text.toLowerCase() == 'null') {
    return null;
  }

  return text;
}

class DailySalesRow {
  final int id;
  final int checkId;
  final int hotelId;


  final String checkNo;
  final String tableNo;
  final String checkDate;
  final String openTime;
  final String closeTime;

  final int portalId;
  final String portalName;
  final String hotelName;
  final String tenantName;

  final int depId;
  final String departmentName;

  final int checkTypeId;
  final String posCheckType;
  final bool checkClosed;
  final int? cancelCheckId;

  final int stdUserId;
  final String userCode;

  final int waiterId;
  final String? waiterName;

  final int cashierId;
  final String? cashierName;

  final int posCardId;
  final String? posCardCardNo;
  final String? posCardFullName;

  final String? guestName;
  final int? hotelGuestId;
  final int? resid;
  final int? resNameId;
  final String? hotelFullName;
  final int? hotelResid;
  final String? hotelRoomNo;

  final double expense;
  final double payment;
  final double balance;

  final double expenseEntrance;
  final double paymentEntrance;
  final double balanceEntrance;

  final double expenseGuests;
  final double paymentGuests;
  final double balanceGuests;

  final double linesTotal;
  final double checkTotal;

  final double discountPercent;
  final double? discountAmount;
  final double servicePercent;
  final double? serviceAmount;

  final double paymentsTotal;
  final double paymentCash;
  final double paymentCreditCard;
  final double paymentCityLedger;
  final double paymentDiscount;
  final double paymentTicket;
  final double paymentWireTransfer;

  final int currencyId;
  final String curCode;

  final int? invoiceId;
  final String? cashRegisterDocNo;
  final String? cashRegisterSerialNo;
  final String? docNo;
  final String? docNoType;
  final String? uuid;

  final int peopleCount;
  final bool forTest;
  final String? notes;
  final String? cardNo;
  final int serviceType;
  final int discountType;
  final String? lastOrderTime;

  final int? stateId;
  final String? state;

  final int? addressId;
  final String? addressInfo;

  final int orderStateId;
  final int? rateCodeId;
  final int? sendingStatus;

  final String? checkOtherPinCode;
  final String? checkOtherCardNumber;

  final bool isParkMember;

  const DailySalesRow({
    required this.id,
    required this.checkId,
    required this.hotelId,
    required this.checkNo,
    required this.tableNo,
    required this.checkDate,
    required this.openTime,
    required this.closeTime,
    required this.portalId,
    required this.portalName,
    required this.hotelName,
    required this.tenantName,
    required this.depId,
    required this.departmentName,
    required this.checkTypeId,
    required this.posCheckType,
    required this.checkClosed,
    this.cancelCheckId,
    required this.stdUserId,
    required this.userCode,
    required this.waiterId,
    this.waiterName,
    required this.cashierId,
    this.cashierName,
    required this.posCardId,
    this.posCardCardNo,
    this.posCardFullName,
    this.guestName,
    this.hotelGuestId,
    this.resid,
    this.resNameId,
    this.hotelFullName,
    this.hotelResid,
    this.hotelRoomNo,
    required this.expense,
    required this.payment,
    required this.balance,
    required this.expenseEntrance,
    required this.paymentEntrance,
    required this.balanceEntrance,
    required this.expenseGuests,
    required this.paymentGuests,
    required this.balanceGuests,
    required this.linesTotal,
    required this.checkTotal,
    required this.discountPercent,
    this.discountAmount,
    required this.servicePercent,
    this.serviceAmount,
    required this.paymentsTotal,
    required this.paymentCash,
    required this.paymentCreditCard,
    required this.paymentCityLedger,
    required this.paymentDiscount,
    required this.paymentTicket,
    required this.paymentWireTransfer,
    required this.currencyId,
    required this.curCode,
    this.invoiceId,
    this.cashRegisterDocNo,
    this.cashRegisterSerialNo,
    this.docNo,
    this.docNoType,
    this.uuid,
    required this.peopleCount,
    required this.forTest,
    this.notes,
    this.cardNo,
    required this.serviceType,
    required this.discountType,
    this.lastOrderTime,
    this.stateId,
    this.state,
    this.addressId,
    this.addressInfo,
    required this.orderStateId,
    this.rateCodeId,
    this.sendingStatus,
    this.checkOtherPinCode,
    this.checkOtherCardNumber,
    required this.isParkMember,
  });

  factory DailySalesRow.fromJson(Map<String, dynamic> json) {
    return DailySalesRow(
      id: _num(json['ID']).toInt(),

      checkId: _num(
        json['CHECKID'] ?? json['ID'],
      ).toInt(),

      hotelId: _num(json['HOTELID']).toInt(),

      checkNo: _str(json['CHECKNO']),
      tableNo: _str(json['TABLENO']),
      checkDate: _str(json['CHECKDATE']),
      openTime: _str(json['OPENTIME']),
      closeTime: _str(json['CLOSETIME']),

      portalId: _num(json['PORTALID']).toInt(),
      portalName: _str(json['PORTALNAME']),
      hotelName: _str(json['HOTELNAME']),
      tenantName: _str(json['TENANTNAME']),

      depId: _num(json['DEPID']).toInt(),
      departmentName: _str(json['DEPARTMENTNAME']),

      checkTypeId: _num(json['CHECKTYPEID']).toInt(),
      posCheckType: _str(json['POSCHECKTYPE']),
      checkClosed: _bool(json['CHECKCLOSED']),

      cancelCheckId: _nullableInt(
        json['CANCELCHECKID'],
      ),

      stdUserId: _num(json['STDUSERID']).toInt(),
      userCode: _str(json['USERCODE']),

      waiterId: _num(json['WAITERID']).toInt(),
      waiterName: _nullableStr(json['WAITERNAME']),

      cashierId: _num(json['CASHIERID']).toInt(),
      cashierName: _nullableStr(json['CASHIERNAME']),

      posCardId: _num(json['POSCARDID']).toInt(),
      posCardCardNo: _nullableStr(
        json['POSCARD_CARDNO'],
      ),
      posCardFullName: _nullableStr(
        json['POSCARD_FULLNAME'],
      ),

      guestName: _nullableStr(json['GUESTNAME']),
      hotelGuestId: _nullableInt(json['HOTELGUESTID']),
      resid: _nullableInt(json['RESID']),
      resNameId: _nullableInt(json['RESNAMEID']),
      hotelFullName: _nullableStr(json['HOTEL_FULLNAME']),
      hotelResid: _nullableInt(json['HOTEL_RESID']),
      hotelRoomNo: _nullableStr(json['HOTEL_ROOMNO']),

      // Günlük satış servisinde gelen alanlar
      expense: _num(
        json['EXPENSE'] ?? json['LINESTOTAL'],
      ).toDouble(),

      payment: _num(
        json['PAYMENT'] ?? json['PAYMENTSTOTAL'],
      ).toDouble(),

      balance: _num(
        json['BALANCE'] ??
            (_num(json['LINESTOTAL']) -
                _num(json['PAYMENTSTOTAL'])),
      ).toDouble(),

      expenseEntrance: _num(
        json['EXPENSE_ENTRANCE'],
      ).toDouble(),

      paymentEntrance: _num(
        json['PAYMENT_ENTRANCE'],
      ).toDouble(),

      balanceEntrance: _num(
        json['BALANCE_ENTRANCE'],
      ).toDouble(),

      expenseGuests: _num(
        json['EXPENSE_GUESTS'],
      ).toDouble(),

      paymentGuests: _num(
        json['PAYMENT_GUESTS'],
      ).toDouble(),

      balanceGuests: _num(
        json['BALANCE_GUESTS'],
      ).toDouble(),

      linesTotal: _num(json['LINESTOTAL']).toDouble(),
      checkTotal: _num(json['CHECKTOTAL']).toDouble(),

      discountPercent: _num(
        json['DISCOUNTPERCENT'],
      ).toDouble(),

      discountAmount: _nullableDouble(
        json['DISCOUNTAMOUNT'],
      ),

      servicePercent: _num(
        json['SERVICEPERCENT'],
      ).toDouble(),

      serviceAmount: _nullableDouble(
        json['SERVICEAMOUNT'],
      ),

      paymentsTotal: _num(
        json['PAYMENTSTOTAL'],
      ).toDouble(),

      paymentCash: _num(
        json['PAYMENT_CASH'],
      ).toDouble(),

      paymentCreditCard: _num(
        json['PAYMENT_CREDITCARD'],
      ).toDouble(),

      paymentCityLedger: _num(
        json['PAYMENT_CITYLEDGER'],
      ).toDouble(),

      paymentDiscount: _num(
        json['PAYMENT_DISCOUNT'],
      ).toDouble(),

      paymentTicket: _num(
        json['PAYMENT_TICKET'],
      ).toDouble(),

      paymentWireTransfer: _num(
        json['PAYMENT_WIRETRANSFER'],
      ).toDouble(),

      currencyId: _num(json['CURRENCYID']).toInt(),
      curCode: _str(json['CURCODE']),

      invoiceId: _nullableInt(json['INVOICEID']),

      cashRegisterDocNo: _nullableStr(
        json['CASHREGISTERDOCNO'],
      ),

      cashRegisterSerialNo: _nullableStr(
        json['CASHREGISTERSERIALNO'],
      ),

      docNo: _nullableStr(json['DOCNO']),
      docNoType: _nullableStr(json['DOCNOTYPE']),
      uuid: _nullableStr(json['UUID']),

      peopleCount: _num(json['PEOPLECOUNT']).toInt(),
      forTest: _bool(json['FORTEST']),
      notes: _nullableStr(json['NOTES']),
      cardNo: _nullableStr(json['CARDNO']),

      serviceType: _num(json['SERVICETYPE']).toInt(),
      discountType: _num(json['DISCOUNTTYPE']).toInt(),

      lastOrderTime: _nullableStr(
        json['LASTORDERTIME'],
      ),

      stateId: _nullableInt(json['STATEID']),
      state: _nullableStr(json['STATE']),

      addressId: _nullableInt(json['ADDRESSID']),

      addressInfo: _nullableStr(
        json['ADDRESSID_ADDRESSINFO'],
      ),

      orderStateId: _num(json['ORDERSTATEID']).toInt(),
      rateCodeId: _nullableInt(json['RATECODEID']),
      sendingStatus: _nullableInt(json['SENDINGSTATUS']),

      checkOtherPinCode: _nullableStr(
        json['CHECKOTHER_PINCODE'],
      ),

      checkOtherCardNumber: _nullableStr(
        json['CHECKOTHER_CARDNUMBER'],
      ),

      isParkMember: _bool(json['ISPARKMEMBER']),
    );
  }
}
class DailySalesAddress {
  final int id;
  final String addressInfo;

  const DailySalesAddress({
    required this.id,
    required this.addressInfo,
  });

  factory DailySalesAddress.fromJson(
      Map<String, dynamic> json,
      ) {
    return DailySalesAddress(
      id: _num(json['ID']).toInt(),
      addressInfo: _str(json['ADDRESSINFO']).trim(),
    );
  }
}

class DailySalesProduct {
  DailySalesProduct({
    required this.id,
    required this.checkId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.revenueName,
    required this.revenueVat,
    this.waiterName,
    this.notes,
    required this.currencyCode,
    required this.servicePercent,
    required this.serviceAmount,
  });

  final int id;
  final int checkId;
  final int productId;

  final String productName;
  final double quantity;
  final double unitPrice;
  final double lineTotal;

  final String revenueName;
  final double revenueVat;

  final String? waiterName;
  final String? notes;
  final String currencyCode;

  final double servicePercent;
  final double serviceAmount;

  factory DailySalesProduct.fromJson(Map<String, dynamic> json) {
    return DailySalesProduct(
      id: _num(json['ID']).toInt(),
      checkId: _num(json['CHECKID']).toInt(),
      productId: _num(json['PRODUCTID']).toInt(),

      productName: _str(json['PRODUCTID_NAME']),
      quantity: _num(json['QUANTITY']).toDouble(),
      unitPrice: _num(json['UNITPRICE']).toDouble(),
      lineTotal: _num(json['LINE_NET_TOTAL']).toDouble(),

      revenueName: _str(json['PRODUCT_REVENUENAME']),
      revenueVat: _num(json['PRODUCT_REVENUEVAT']).toDouble(),

      waiterName: _nullableStr(json['WAITERNAME']),
      notes: _nullableStr(json['NOTES']),
      currencyCode: _str(json['CHECK_CURCODE']),

      servicePercent:
      _num(json['DETAIL_SERVICEPERCENT']).toDouble(),
      serviceAmount:
      _num(json['DETAIL_SERVICEAMOUNT']).toDouble(),
    );
  }
}
class DailySalesPayment {
  final int id;
  final int checkId;
  final int payDepartmentId;

  final String paymentDepartmentName;
  final int paymentDepartmentType;

  final double payment;
  final double paymentLocal;
  final int paymentCurrencyId;
  final String paymentCurrencyCode;
  final double currencyRate;

  final int waiterId;
  final String? waiterName;

  final String paymentDate;
  final String creationDate;

  final int? checkGuestId;
  final String? checkGuestCardNo;
  final String? notes;

  DailySalesPayment({
    required this.id,
    required this.checkId,
    required this.payDepartmentId,
    required this.paymentDepartmentName,
    required this.paymentDepartmentType,
    required this.payment,
    required this.paymentLocal,
    required this.paymentCurrencyId,
    required this.paymentCurrencyCode,
    required this.currencyRate,
    required this.waiterId,
    required this.waiterName,
    required this.paymentDate,
    required this.creationDate,
    required this.checkGuestId,
    required this.checkGuestCardNo,
    required this.notes,
  });

  factory DailySalesPayment.fromJson(Map<String, dynamic> json) {
    return DailySalesPayment(
      id: _num(json['ID']).toInt(),
      checkId: _num(json['CHECKID']).toInt(),
      payDepartmentId: _num(json['PAYDEPID']).toInt(),

      paymentDepartmentName:
      _str(json['PAYMENT_DEPARTMENTNAME']),
      paymentDepartmentType:
      _num(json['PAYMENT_DEPARTMENTTYPE']).toInt(),

      payment: _num(json['PAYMENT']).toDouble(),
      paymentLocal: _num(json['PAYMENT_LOCAL']).toDouble(),
      paymentCurrencyId:
      _num(json['PAYMENT_CURRENCYID']).toInt(),
      paymentCurrencyCode:
      _str(json['PAYMENT_CURCODE']),
      currencyRate: _num(json['CURRENCYRATE']).toDouble(),

      waiterId: _num(json['WAITERID']).toInt(),
      waiterName: _nullableStr(json['WAITERNAME']),

      paymentDate: _str(json['PAYMENTDATE']),
      creationDate: _str(json['CREATION_DATE']),

      checkGuestId: json['CHECKGUESTID'] == null
          ? null
          : _num(json['CHECKGUESTID']).toInt(),

      checkGuestCardNo:
      _nullableStr(json['CHECKGUEST_CARDNO']),

      notes: _nullableStr(json['NOTES']),
    );
  }
}