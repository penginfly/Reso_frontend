import 'dart:io';

import 'package:dio/dio.dart';

import '../domain/entities/user.dart';

class AuthApiClient {
  AuthApiClient({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<User> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/v1/auth/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode != 200) {
        throw AuthApiException('ログインに失敗しました');
      }

      return _parseTokenResponse(
        response.data,
        username: username,
        fallbackEmail: null,
      );
    } on DioException catch (error) {
      throw AuthApiException(_extractApiErrorMessage(error, 'ログインに失敗しました'));
    }
  }

  Future<User> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        '/v1/users/signup',
        data: {'username': username, 'email': email, 'password': password},
      );

      if (response.statusCode != 201) {
        throw AuthApiException('ユーザー作成に失敗しました');
      }

      return _parseTokenResponse(
        response.data,
        username: username,
        fallbackEmail: email,
      );
    } on DioException catch (error) {
      throw AuthApiException(_extractApiErrorMessage(error, 'ユーザー作成に失敗しました'));
    }
  }

  Future<void> logout() async {
    // OpenAPIにlogoutエンドポイントがないため、現状はローカル状態のみ破棄する。
  }

  User _parseTokenResponse(
    dynamic raw, {
    required String username,
    required String? fallbackEmail,
  }) {
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Invalid auth response format');
    }

    final token = _pickString(raw, const ['token', 'Token', 'accessToken']);
    if (token == null) {
      throw const FormatException('Token payload is missing');
    }

    return User(token: token, username: username, email: fallbackEmail);
  }

  String? _pickString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  String _extractApiErrorMessage(DioException error, String fallback) {
    final rootError = error.error;
    if (rootError is SocketException) {
      final message = rootError.message;
      if (message.contains('Failed host lookup')) {
        return 'APIサーバーのドメインが見つかりません。RESO_API_BASE_URL を確認してください。';
      }
      return 'ネットワーク接続に失敗しました。通信環境を確認してください。';
    }

    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = _pickString(data, const ['message', 'error', 'detail']);
      if (message != null) {
        return message;
      }
    }

    return error.message ?? fallback;
  }
}

class AuthApiException implements Exception {
  const AuthApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
