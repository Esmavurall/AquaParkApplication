import 'dart:convert';

import 'package:aquapark/core/network/api_exception.dart';
import 'package:aquapark/modules/dashboard/dashboard_model.dart';
import 'package:aquapark/modules/login/login_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class DashboardService {
  DashboardService();

  static const Duration _requestTimeout = Duration(seconds: 15);

  final date1 = BehaviorSubject<DateTime>();
  final date2 = BehaviorSubject<DateTime>();

  final loading = BehaviorSubject<bool>.seeded(false);
  final error = BehaviorSubject<String?>.seeded(null);

  final metrics = BehaviorSubject<DashboardMetrics>.seeded(
    DashboardMetrics.empty,
  );

  final odeme = BehaviorSubject<List<PaymentRow>>.seeded([]);
  final gelirler = BehaviorSubject<List<RevenueRow>>.seeded([]);
  final biletler = BehaviorSubject<List<TicketRow>>.seeded([]);
  final turnike = BehaviorSubject<List<TurnstileRow>>.seeded([]);

  void initDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    date1.add(today);
    date2.add(today);
  }

  void setDate1(DateTime date) {
    date1.add(date);
  }

  void setDate2(DateTime date) {
    date2.add(date);
  }

  void setRange(DateTime startDate, DateTime endDate) {
    date1.add(startDate);
    date2.add(endDate);

    load();
  }

  void shift(int direction) {
    final startDate = date1.value;
    final endDate = date2.value;

    final dayCount = endDate.difference(startDate).inDays + 1;

    date1.add(
      startDate.add(
        Duration(days: dayCount * direction),
      ),
    );

    date2.add(
      endDate.add(
        Duration(days: dayCount * direction),
      ),
    );

    load();
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
      metrics.add(DashboardMetrics.empty);
      odeme.add([]);
      gelirler.add([]);
      biletler.add([]);
      turnike.add([]);

      if (currentUser == null ||
          currentUser!.loginToken.trim().isEmpty ||
          apiUrl.trim().isEmpty) {
        throw const ApiException(
          messageKey: 'errors.session_not_found',
        );
      }

      final decoded = await _execute(
        'SP_POS_PARK_DASHBOARD',
        {
          'DATE1': _fmt(date1.value),
          'DATE2': _fmt(date2.value),
          'HOTELID': currentUser!.hotelId,
        },
      );

      final data = DashboardData.fromResponse(decoded);

      metrics.add(data.metrics);
      odeme.add(data.payments);
      gelirler.add(data.revenues);
      biletler.add(data.tickets);
      turnike.add(data.turnstiles);
    } catch (exception) {
      final apiException = convertToApiException(exception);

      debugPrint('DASHBOARD YÜKLEME HATASI: $apiException');

      error.add(_translateException(apiException));
    } finally {
      loading.add(false);
    }
  }

  Future<dynamic> _execute(
      String spName,
      Map<String, dynamic> params,
      ) async {
    try {
      if (apiUrl.trim().isEmpty) {
        throw const ApiException(
          messageKey: 'errors.server_unreachable',
        );
      }

      final token = currentUser?.loginToken;

      if (token == null || token.trim().isEmpty) {
        throw const ApiException(
          messageKey: 'errors.session_not_found',
        );
      }

      final baseUrl = apiUrl.endsWith('/')
          ? apiUrl.substring(0, apiUrl.length - 1)
          : apiUrl;

      final url = '$baseUrl/Execute/${spName.trim()}';

      final body = jsonEncode({
        'Action': 'Execute',
        'Object': spName.trim(),
        'Parameters': params,
        'LoginToken': token,
      });

      debugPrint('========== DASHBOARD İSTEĞİ ==========');
      debugPrint('URL  : $url');
      debugPrint('BODY : $body');
      debugPrint('======================================');

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

      final rawResponse = utf8.decode(response.bodyBytes);

      debugPrint('========== DASHBOARD YANITI ==========');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('RESP  : $rawResponse');
      debugPrint('======================================');

      dynamic decoded;

      try {
        decoded = jsonDecode(rawResponse);
      } on FormatException {
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw exceptionFromStatusCode(
            response.statusCode,
            serverMessage: rawResponse.trim().isEmpty
                ? null
                : rawResponse,
          );
        }

        throw const ApiException(
          messageKey: 'errors.invalid_server_response',
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw exceptionFromStatusCode(
          response.statusCode,
          serverMessage: _extractServerMessage(decoded),
        );
      }

      return decoded;
    } catch (exception) {
      throw convertToApiException(exception);
    }
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

    if (exception.detail == null ||
        exception.detail!.trim().isEmpty) {
      return translatedMessage;
    }

    return '$translatedMessage\n${exception.detail}';
  }

  void dispose() {
    date1.close();
    date2.close();
    loading.close();
    error.close();
    metrics.close();
    odeme.close();
    gelirler.close();
    biletler.close();
    turnike.close();
  }
}