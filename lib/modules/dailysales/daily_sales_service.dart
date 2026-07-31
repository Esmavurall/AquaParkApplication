import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import 'package:aquapark/modules/login/login_model.dart';
import 'daily_sales_model.dart';
import 'package:aquapark/core/network/api_exception.dart';

class DailySalesService {
  DailySalesService();
  static const Duration _requestTimeout = Duration(seconds: 15);

  final selectedDate = BehaviorSubject<DateTime>();
  final loading = BehaviorSubject<bool>.seeded(false);
  final error = BehaviorSubject<String?>.seeded(null);

  final salesRows = BehaviorSubject<List<DailySalesRow>>.seeded([]);
  final cancelledRows =
  BehaviorSubject<List<DailySalesRow>>.seeded([]);
  final cancelledLoading = BehaviorSubject<bool>.seeded(false);
  bool _cancelledLoaded = false;
  bool _cancelledRequestRunning = false;

  final selectedTab = BehaviorSubject<int>.seeded(0);

  final detailLoading = BehaviorSubject<bool>.seeded(false);

  final detailError = BehaviorSubject<String?>.seeded(null);

  final checkDetail = BehaviorSubject<DailySalesRow?>.seeded(null);

  final detailProducts = BehaviorSubject<List<DailySalesProduct>>.seeded([]);

  final detailPayments = BehaviorSubject<List<DailySalesPayment>>.seeded([]);
  final selectedDetailTab = BehaviorSubject<int>.seeded(0);

  final detailTabLoading = BehaviorSubject<bool>.seeded(false);

  bool _productsLoaded = false;
  bool _paymentsLoaded = false;

  bool _productsLoading = false;
  bool _paymentsLoading = false;

  final detailExpanded = BehaviorSubject<bool>.seeded(false);

  void initDate() {
    selectedDate.add(DateTime.now());
  }

  void setDate(DateTime date) {
    selectedDate.add(date);
    cancelledRows.add([]);
    _cancelledLoaded = false;
  }

  String _fmt(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> load() async {
    loading.add(true);
    error.add(null);

    try {
      salesRows.add([]);

      final base = apiUrl.endsWith('/')
          ? apiUrl.substring(0, apiUrl.length - 1)
          : apiUrl;

      final url = '$base/Function/FN_POS_PARK_CHECK_BALANCES';

      final hotelId = currentUser?.hotelId ?? 0;
      final token = currentUser?.loginToken;

      final body = jsonEncode({
        'Parameters': {
          'DATE': _fmt(selectedDate.value),
          'HOTELID': hotelId,
        },
        'Action': 'Function',
        'Object': 'FN_POS_PARK_CHECK_BALANCES',
        'OrderBy': [
          {
            'Column': 'BALANCE',
            'Direction': 'ASC',
          },
        ],
        'Where': [
          {
            'Column': 'CHECKTYPEID',
            'Operator': '=',
            'Value': 0,
          },
        ],
        if (token != null) 'LoginToken': token,
      });

      debugPrint('DAILY SALES İSTEK -> $url');
      debugPrint('DAILY SALES BODY -> $body');

      final response = await http
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      )
          .timeout(_requestTimeout);

      final raw = utf8.decode(response.bodyBytes);

      debugPrint('DAILY SALES STATUS -> ${response.statusCode}');
      debugPrint('DAILY SALES CEVAP -> $raw');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        dynamic decodedError;

        try {
          decodedError = jsonDecode(raw);
        } on FormatException {
          decodedError = raw;
        }

        throw exceptionFromStatusCode(
          response.statusCode,
          serverMessage: _extractServerMessage(decodedError),
        );
      }

      final decoded = jsonDecode(raw);
      final rows = <DailySalesRow>[];


      if (decoded is List && decoded.isNotEmpty) {
        final firstList = decoded.first;

        if (firstList is List) {
          for (final item in firstList) {
            if (item is Map) {
              rows.add(
                DailySalesRow.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              );
            }
          }
        }
      }

      debugPrint('DAILY SALES KAYIT SAYISI -> ${rows.length}');

      salesRows.add(rows);
    } catch (exception) {
      final apiException = convertToApiException(exception);

      debugPrint('GÜNLÜK SATIŞ YÜKLEME HATASI: $apiException');

      error.add(_translateException(apiException));
    } finally {
      loading.add(false);
    }
  }
  Future<void> loadCancelled({bool forceRefresh = false}) async {
    if (_cancelledLoaded && !forceRefresh) {
      return;
    }

    if (_cancelledRequestRunning) {
      return;
    }

    _cancelledRequestRunning = true;
    cancelledLoading.add(true);
    error.add(null);

    try {
      final base = apiUrl.endsWith('/')
          ? apiUrl.substring(0, apiUrl.length - 1)
          : apiUrl;

      final url = '$base/Function/FN_POS_PARK_CHECK_BALANCES';

      final hotelId = currentUser?.hotelId ?? 0;
      final token = currentUser?.loginToken;

      final body = jsonEncode({
        'Parameters': {
          'DATE': _fmt(selectedDate.value),
          'HOTELID': hotelId,
        },
        'Action': 'Function',
        'Object': 'FN_POS_PARK_CHECK_BALANCES',
        'OrderBy': [
          {
            'Column': 'BALANCE',
            'Direction': 'ASC',
          },
        ],
        'Where': [
          {
            'Column': 'CHECKTYPEID',
            'Operator': '=',
            'Value': 0,
          },
          {
            'Column': 'CANCELCHECKID',
            'Operator': '>',
            'Value': 0,
          },
        ],
        if (token != null) 'LoginToken': token,
      });

      debugPrint('İPTAL KAYITLARI İSTEK -> $url');
      debugPrint('İPTAL KAYITLARI BODY -> $body');

      final response = await http
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      )
          .timeout(_requestTimeout);

      final raw = utf8.decode(response.bodyBytes);

      debugPrint('İPTAL KAYITLARI STATUS -> ${response.statusCode}');
      debugPrint('İPTAL KAYITLARI CEVAP -> $raw');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        dynamic decodedError;

        try {
          decodedError = jsonDecode(raw);
        } on FormatException {
          decodedError = raw;
        }

        throw exceptionFromStatusCode(
          response.statusCode,
          serverMessage: _extractServerMessage(decodedError),
        );
      }

      final decoded = jsonDecode(raw);
      final rows = <DailySalesRow>[];

      if (decoded is List && decoded.isNotEmpty) {
        final firstList = decoded.first;

        if (firstList is List) {
          for (final item in firstList) {
            if (item is Map) {
              rows.add(
                DailySalesRow.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              );
            }
          }
        }
      }

      debugPrint('İPTAL KAYIT SAYISI -> ${rows.length}');

      cancelledRows.add(rows);
      _cancelledLoaded = true;
    } catch (exception) {
      final apiException = convertToApiException(exception);

      debugPrint('İPTAL KAYITLARI YÜKLEME HATASI: $apiException');

      error.add(_translateException(apiException));
    } finally {
      _cancelledRequestRunning = false;
      cancelledLoading.add(false);
    }
  }
  void clearDetailPage() {
    detailLoading.add(false);
    detailTabLoading.add(false);
    detailError.add(null);

    checkDetail.add(null);
    detailProducts.add([]);
    detailPayments.add([]);

    selectedDetailTab.add(0);

    detailExpanded.add(false);

    _productsLoaded = false;
    _paymentsLoaded = false;
    _productsLoading = false;
    _paymentsLoading = false;
  }

  void toggleDetailExpanded() {
    detailExpanded.add(!detailExpanded.value);
  }

  Future<void> loadDetailPage({required int checkId}) async {
    detailLoading.add(true);
    detailError.add(null);

    checkDetail.add(null);
    detailProducts.add([]);
    detailPayments.add([]);

    selectedDetailTab.add(0);

    _productsLoaded = false;
    _paymentsLoaded = false;
    _productsLoading = true;
    _paymentsLoading = false;

    try {
      final results = await Future.wait([
        getDailySalesDetail(checkId: checkId),
        getDailySalesProducts(checkId: checkId),
      ]);

      final detail = results[0] as DailySalesRow;

      final products = results[1] as List<DailySalesProduct>;

      checkDetail.add(detail);
      detailProducts.add(products);

      _productsLoaded = true;
    } catch (exception) {
      final apiException = convertToApiException(exception);

      debugPrint('DETAY SAYFASI HATASI: $apiException');

      detailError.add(_translateException(apiException));
    } finally {
      _productsLoading = false;
      detailLoading.add(false);
    }
  }

  Future<void> changeDetailTab({
    required int index,
    required int checkId,
  }) async {
    if (index != 0 && index != 1) {
      return;
    }

    selectedDetailTab.add(index);

    if (index == 0) {
      await loadDetailProductsIfNeeded(checkId: checkId);

      return;
    }

    await loadDetailPaymentsIfNeeded(checkId: checkId);
  }

  Future<void> loadDetailProductsIfNeeded({required int checkId}) async {
    if (_productsLoaded || _productsLoading) {
      return;
    }

    _productsLoading = true;
    detailTabLoading.add(true);
    detailError.add(null);

    try {
      final products = await getDailySalesProducts(checkId: checkId);

      detailProducts.add(products);
      _productsLoaded = true;
    } catch (exception) {
      final apiException = convertToApiException(exception);

      debugPrint('ÜRÜNLER YÜKLENİRKEN HATA: $apiException');

      detailError.add(_translateException(apiException));
    } finally {
      _productsLoading = false;
      detailTabLoading.add(false);
    }
  }

  Future<void> loadDetailPaymentsIfNeeded({required int checkId}) async {
    if (_paymentsLoaded || _paymentsLoading) {
      return;
    }

    _paymentsLoading = true;
    detailTabLoading.add(true);
    detailError.add(null);

    try {
      final payments = await getDailySalesPayments(checkId: checkId);

      detailPayments.add(payments);
      _paymentsLoaded = true;
    } catch (exception) {
      final apiException = convertToApiException(exception);

      debugPrint('ÖDEMELER YÜKLENİRKEN HATA: $apiException');

      detailError.add(_translateException(apiException));
    } finally {
      _paymentsLoading = false;
      detailTabLoading.add(false);
    }
  }

  Future<void> refreshCurrentDetailTab({required int checkId}) async {
    detailLoading.add(true);
    detailError.add(null);

    try {
      final detail = await getDailySalesDetail(checkId: checkId);

      checkDetail.add(detail);

      if (selectedDetailTab.value == 0) {
        final products = await getDailySalesProducts(checkId: checkId);

        detailProducts.add(products);
        _productsLoaded = true;

        return;
      }

      final payments = await getDailySalesPayments(checkId: checkId);

      detailPayments.add(payments);
      _paymentsLoaded = true;
    } catch (exception) {
      final apiException = convertToApiException(exception);

      debugPrint('DETAY YENİLEME HATASI: $apiException');

      detailError.add(_translateException(apiException));
    } finally {
      detailLoading.add(false);
    }
  }

  Future<DailySalesRow> getDailySalesDetail({required int checkId}) async {
    final base = apiUrl.endsWith('/')
        ? apiUrl.substring(0, apiUrl.length - 1)
        : apiUrl;

    final uri = Uri.parse('$base/Select/QPOS_CHECK');

    final response = await http
        .post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'Action': 'Select',
        'Object': 'QPOS_CHECK',
        'Where': [
          {
            'Column': 'ID',
            'Operator': '=',
            'Value': checkId,
          },
          {
            'Column': 'HOTELID',
            'Operator': '=',
            'Value': currentUser?.hotelId ?? 0,
          },
        ],
        'LoginToken': currentUser?.loginToken ?? '',
        'Paging': {
          'Current': 1,
          'ItemsPerPage': 1,
        },
        'Joins': ['QA_ADDRESS'],
      }),
    )
        .timeout(_requestTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final raw = utf8.decode(response.bodyBytes);

      dynamic decoded;

      try {
        decoded = jsonDecode(raw);
      } on FormatException {
        decoded = raw;
      }

      throw exceptionFromStatusCode(
        response.statusCode,
        serverMessage: _extractServerMessage(decoded),
      );
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const ApiException(
        messageKey: 'errors.invalid_detail_response',
      );
    }

    final resultSets = decoded['ResultSets'];

    if (resultSets is! List || resultSets.isEmpty) {
      throw const ApiException(
        messageKey: 'errors.sales_detail_not_found',
      );    }

    final firstResultSet = resultSets.first;

    if (firstResultSet is! List || firstResultSet.isEmpty) {
      throw const ApiException(
        messageKey: 'errors.sales_detail_not_found',
      );    }

    final detailJson = firstResultSet.first;

    if (detailJson is! Map) {
      throw const ApiException(
        messageKey: 'errors.invalid_sales_detail',
      );    }

    return DailySalesRow.fromJson(Map<String, dynamic>.from(detailJson));
  }

  Future<List<DailySalesProduct>> getDailySalesProducts({
    required int checkId,
  }) async {
    final base = apiUrl.endsWith('/')
        ? apiUrl.substring(0, apiUrl.length - 1)
        : apiUrl;

    final uri = Uri.parse('$base/Select/QPOS_CHECK_DETAIL');

    final hotelId = currentUser?.hotelId ?? 0;
    final loginToken = currentUser?.loginToken ?? '';

    final requestBody = {
      'Action': 'Select',
      'Object': 'QPOS_CHECK_DETAIL',
      'Select': [
        'ID',
        'CHECKID',
        'PRODUCTID',
        'PRODUCTPRICE',
        'PRODUCT_REVENUEID',
        'PRODUCT_REVENUECODE',
        'PRODUCT_REVENUENAME',
        'PRODUCT_REVENUEVAT',
        'QUANTITY',
        'PORTION',
        'UNITPRICE',
        'LINE_MID_TOTAL',
        'LINE_DISCOUNTPERCENT',
        'LINE_NET_UNITPRICE',
        'LINE_NET_TOTAL',
        'WAITERID',
        'WAITERNAME',
        'NOTES',
        'DISCOUNTMODENAME',
        'DISCOUNTMODEREASON',
        'HOTELID',
        'CHECK_CURCODE',
        'PRODUCTID_NAME',
        'PRODUCTID_CODE',
        'DETAIL_SERVICEAMOUNT',
        'DETAIL_SERVICEPERCENT',
      ],
      'Where': [
        {'Column': 'CHECKID', 'Operator': '=', 'Value': checkId},
        {'Column': 'HOTELID', 'Operator': '=', 'Value': hotelId},
      ],
      'OrderBy': [
        {'Column': 'HOTELID', 'Direction': 'ASC'},
      ],
      'Paging': {'Current': 1, 'ItemsPerPage': 10000},
      'Joins': [
        {
          'Object': 'POS_PRODUCT',
          'Key': 'ID',
          'Fields': ['NAME', 'CODE'],
          'Field': 'PRODUCTID',
        },
      ],
      'LoginToken': loginToken,
    };

    debugPrint('ÜRÜN DETAY İSTEK -> $uri ${jsonEncode(requestBody)}');

    final response = await http
        .post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    )
        .timeout(_requestTimeout);

    final rawResponse = utf8.decode(response.bodyBytes);

    debugPrint('ÜRÜN DETAY CEVAP -> $rawResponse');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      dynamic errorResponse;

      try {
        errorResponse = jsonDecode(rawResponse);
      } on FormatException {
        errorResponse = rawResponse;
      }

      throw exceptionFromStatusCode(
        response.statusCode,
        serverMessage: _extractServerMessage(errorResponse),
      );
    }

    final decoded = jsonDecode(rawResponse);

    if (decoded is! Map<String, dynamic>) {
      throw const ApiException(
        messageKey: 'errors.invalid_products_response',
      );
    }

    final resultSets = decoded['ResultSets'];

    if (resultSets is! List || resultSets.isEmpty) {
      return [];
    }

    final firstResultSet = resultSets.first;

    if (firstResultSet is! List || firstResultSet.isEmpty) {
      return [];
    }

    final products = <DailySalesProduct>[];

    for (final item in firstResultSet) {
      if (item is Map) {
        products.add(
          DailySalesProduct.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }

    return products;
  }

  Future<List<DailySalesPayment>> getDailySalesPayments({
    required int checkId,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw const ApiException(
        messageKey: 'errors.session_not_found',
      );
    }

    final uri = Uri.parse(
      'https://api.s01.elektraweb.com/Select/QPOS_CHECK_PAYMENT',
    );

    final payload = {
      'Action': 'Select',
      'Object': 'QPOS_CHECK_PAYMENT',
      'Select': [
        'ID',
        'CHECKID',
        'PAYDEPID',
        'PAYMENT_DEPARTMENTNAME',
        'PAYMENT_DEPARTMENTTYPE',
        'PAYMENT',
        'PAYMENT_CURRENCYID',
        'PAYMENT_CURCODE',
        'CURRENCYRATE',
        'PAYMENT_LOCAL',
        'WAITERID',
        'WAITERNAME',
        'CREATION_DATE',
        'PORTALID',
        'PORTALNAME',
        'HOTELID',
        'HOTELNAME',
        'TENANTNAME',
        'CHECK_CHECKCLOSED',
        'CHECK_CHECKTYPEID',
        'CHECK_POSCHECKTYPE',
        'CHECK_DEPID',
        'CHECK_DEPARTMENTNAME',
        'CHECK_TABLENO',
        'CHECK_CHECKDATE',
        'CHECK_CHECKNO',
        'CHECK_STDUSERID',
        'CHECK_USERCODE',
        'CHECK_CURRENCYID',
        'CHECK_CURCODE',
        'CHECK_SERVICETYPE',
        'CHECK_DISCOUNTTYPE',
        'CHECK_DISCOUNTPERCENT',
        'CHECK_DISCOUNTAMOUNT',
        'CHECK_SERVICEPERCENT',
        'CHECK_SERVICEAMOUNT',
        'CHECK_LINESTOTAL',
        'CHECK_CHECKTOTAL',
        'CHECK_WAITERID',
        'CHECK_WAITERNAME',
        'CHECK_CASHIERID',
        'CHECK_CASHIERNAME',
        'CHECKGUEST_CARDNO',
        'CHECKGUESTID',
        'NOTES',
        'PAYMENTDATE',
      ],
      'Where': [
        {'Column': 'CHECKID', 'Operator': '=', 'Value': checkId},
        {'Column': 'HOTELID', 'Operator': '=', 'Value': user.hotelId},
      ],
      'OrderBy': [
        {'Column': 'null', 'Direction': null},
      ],
      'Paging': {'Current': 1, 'ItemsPerPage': 10000},
      'Joins': [],
      'LoginToken': user.loginToken,
    };

    final response = await http
        .post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    )
        .timeout(_requestTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final raw = utf8.decode(response.bodyBytes);

      dynamic decoded;

      try {
        decoded = jsonDecode(raw);
      } on FormatException {
        decoded = raw;
      }

      throw exceptionFromStatusCode(
        response.statusCode,
        serverMessage: _extractServerMessage(decoded),
      );
    }

    final decoded = jsonDecode(
      utf8.decode(response.bodyBytes),//türkçe karaketerler de daha güvenilir okunur
    );

    if (decoded is! Map<String, dynamic>) {
      throw const ApiException(
        messageKey: 'errors.invalid_payments_response',
      );
    }

    final resultSets = decoded['ResultSets'];

    if (resultSets is! List || resultSets.isEmpty) {
      return [];
    }

    final firstResultSet = resultSets.first;

    if (firstResultSet is! List) {
      return [];
    }

    return firstResultSet
        .whereType<Map<String, dynamic>>()
        .map(DailySalesPayment.fromJson)
        .toList();
  }
  String? _extractServerMessage(dynamic decoded) {
    if (decoded is Map) {
      final message =
          decoded['Message'] ??
              decoded['message'] ??
              decoded['Error'] ??
              decoded['error'];

      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    if (decoded is String && decoded.trim().isNotEmpty) {
      return decoded;
    }

    return null;
  }

  String _translateException(ApiException exception) {
    final translatedMessage = exception.messageKey.tr();

    if (exception.detail == null || exception.detail!.trim().isEmpty) {
      return translatedMessage;
    }

    return '$translatedMessage\n${exception.detail}';
  }
}
