import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String messageKey;
  final String? detail;
  final int? statusCode;

  const ApiException({
    required this.messageKey,
    this.detail,
    this.statusCode,
  });

  @override
  String toString() => detail == null ? messageKey : '$messageKey: $detail';
}

ApiException convertToApiException(Object error) {
  if (error is ApiException) {
    return error;
  }

  if (error is SocketException) {
    return const ApiException(
      messageKey: 'errors.server_unreachable',
    );
  }

  if (error is TimeoutException) {
    return const ApiException(
      messageKey: 'errors.request_timeout',
    );
  }

  if (error is FormatException || error is JsonUnsupportedObjectError) {
    return const ApiException(
      messageKey: 'errors.invalid_server_response',
    );
  }

  if (error is http.ClientException) {
    return ApiException(
      messageKey: 'errors.connection_failed',
      detail: error.message,
    );
  }

  return ApiException(
    messageKey: 'errors.unknown_error',
    detail: error.toString(),
  );
}

ApiException exceptionFromStatusCode(
    int statusCode, {
      String? serverMessage,
    }) {
  if (statusCode == 400) {
    return ApiException(
      messageKey: 'errors.bad_request',
      detail: serverMessage,
      statusCode: statusCode,
    );
  }

  if (statusCode == 401) {
    return ApiException(
      messageKey: 'errors.session_expired',
      detail: serverMessage,
      statusCode: statusCode,
    );
  }

  if (statusCode == 403) {
    return ApiException(
      messageKey: 'errors.access_denied',
      detail: serverMessage,
      statusCode: statusCode,
    );
  }

  if (statusCode == 404) {
    return ApiException(
      messageKey: 'errors.service_not_found',
      detail: serverMessage,
      statusCode: statusCode,
    );
  }

  if (statusCode >= 500) {
    return ApiException(
      messageKey: 'errors.server_error',
      detail: serverMessage,
      statusCode: statusCode,
    );
  }

  return ApiException(
    messageKey: 'errors.request_failed',
    detail: serverMessage ?? 'HTTP $statusCode',
    statusCode: statusCode,
  );
}