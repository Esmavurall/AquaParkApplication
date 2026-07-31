import 'dart:convert';

import 'package:aquapark/core/network/api_exception.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import 'login_model.dart';

class LoginResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  final String? apiUrl;
  final LoginModel? loginModel;

  const LoginResult({
    required this.success,
    required this.message,
    this.data,
    this.apiUrl,
    this.loginModel,
  });
}

class MasterLoginResult {
  final bool success;
  final String? apiUrl;
  final ApiException? exception;

  const MasterLoginResult({
    required this.success,
    this.apiUrl,
    this.exception,
  });
}

class LoginService {
  static const String _masterUrl =
      'https://wololo.elektraweb.com/GetEndpoint';

  static const Duration _requestTimeout = Duration(seconds: 15);

  final apiUrl$ = BehaviorSubject<String>();

  Future<MasterLoginResult> masterLogin(String hotelId) async {
    try {
      final response = await http
          .post(
        Uri.parse(_masterUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'Action': 'GetEndpoint',
          'Fields': ['TENANTUID', 'API_URL', 'USE_IDP'],
          'Tenant': hotelId,
        }),
      )
          .timeout(_requestTimeout);

      final rawResponse = utf8.decode(response.bodyBytes);

      debugPrint('========== MASTER LOGIN YANITI ==========');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('RESP  : $rawResponse');
      debugPrint('=========================================');

      dynamic decoded;

      try {
        decoded = jsonDecode(rawResponse);
      } on FormatException {
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

      final record = _firstMap(decoded);
      final foundApiUrl = record?['API_URL']?.toString().trim();
      final successValue = record?['SUCCESS'];

      final isSuccessful =
          foundApiUrl != null &&
              foundApiUrl.isNotEmpty &&
              (successValue == null ||
                  successValue == 1 ||
                  successValue == true ||
                  successValue.toString() == '1');

      if (!isSuccessful) {
        return const MasterLoginResult(
          success: false,
          exception: ApiException(
            messageKey: 'errors.tenant_endpoint_not_found',
          ),
        );
      }

      final normalizedApiUrl = foundApiUrl.endsWith('/')
          ? foundApiUrl
          : '$foundApiUrl/';

      apiUrl$.add(normalizedApiUrl);

      return MasterLoginResult(
        success: true,
        apiUrl: normalizedApiUrl,
      );
    } catch (error) {
      final exception = convertToApiException(error);

      if (kDebugMode) {
        debugPrint('MASTER LOGIN HATASI: $exception');
      }

      return MasterLoginResult(
        success: false,
        exception: exception,
      );
    }
  }

  Future<LoginResult> login({
    required String tenant,
    required String usercode,
    required String password,
  }) async {
    try {
      final masterResult = await masterLogin(tenant);

      if (!masterResult.success || masterResult.apiUrl == null) {
        final exception =
            masterResult.exception ??
                const ApiException(
                  messageKey: 'errors.tenant_endpoint_not_found',
                );

        return LoginResult(
          success: false,
          message: _translateException(exception),
        );
      }

      final foundApiUrl = masterResult.apiUrl!;

      final response = await http
          .post(
        Uri.parse(foundApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'Action': 'Login',
          'Usercode': usercode,
          'Password': password,
          'Tenant': tenant,
        }),
      )
          .timeout(_requestTimeout);

      final rawResponse = utf8.decode(response.bodyBytes);

      debugPrint('========== LOGIN YANITI ==========');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('RESP  : $rawResponse');
      debugPrint('==================================');

      dynamic decoded;

      try {
        decoded = jsonDecode(rawResponse);
      } on FormatException {
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

      if (decoded is! Map<String, dynamic>) {
        throw const ApiException(
          messageKey: 'errors.invalid_server_response',
        );
      }

      final loginSucceeded =
          decoded['Success'] == true ||
              decoded['SUCCESS'] == true ||
              decoded['Success'] == 1 ||
              decoded['SUCCESS'] == 1;

      if (!loginSucceeded) {
        final serverMessage = _extractServerMessage(decoded);

        return LoginResult(
          success: false,
          message: serverMessage != null &&
              serverMessage.trim().isNotEmpty
              ? serverMessage
              : 'errors.invalid_credentials'.tr(),
        );
      }

      final model = LoginModel.fromJson(decoded);

      return LoginResult(
        success: true,
        message: 'login.success'.tr(),
        data: decoded,
        apiUrl: foundApiUrl,
        loginModel: model,
      );
    } catch (error) {
      final exception = convertToApiException(error);

      if (kDebugMode) {
        debugPrint('LOGIN HATASI: $exception');
      }

      return LoginResult(
        success: false,
        message: _translateException(exception),
      );
    }
  }

  Map<String, dynamic>? _firstMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    if (data is List) {
      for (final item in data) {
        final map = _firstMap(item);

        if (map != null) {
          return map;
        }
      }
    }

    return null;
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

  void dispose() {
    apiUrl$.close();
  }
}