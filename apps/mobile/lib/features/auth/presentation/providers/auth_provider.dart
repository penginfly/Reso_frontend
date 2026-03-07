import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/auth_api_client.dart';
import '../../domain/entities/user.dart';

final dioProvider = Provider<Dio>((ref) {
  const baseUrl = String.fromEnvironment('RESO_API_BASE_URL');
  if (baseUrl.isEmpty) {
    throw const AuthConfigException(
      'RESO_API_BASE_URL が未設定です。--dart-define-from-file=.env を指定して起動してください。',
    );
  }

  return Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: const {'Content-Type': 'application/json'},
    ),
  );
});

final authApiClientProvider = Provider<AuthApiClient>((ref) {
  return AuthApiClient(dio: ref.watch(dioProvider));
});

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    return null;
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final validationError = _validateLogin(
      username: username,
      password: password,
    );
    if (validationError != null) {
      state = AsyncError(
        AuthValidationException(validationError),
        StackTrace.current,
      );
      return false;
    }

    state = const AsyncLoading();
    try {
      final user = await ref
          .read(authApiClientProvider)
          .login(username: username.trim(), password: password);
      state = AsyncData(user);
      return true;
    } catch (error, stackTrace) {
      if (error is AuthApiException) {
        state = AsyncError(AuthValidationException(error.message), stackTrace);
      } else {
        state = AsyncError(error, stackTrace);
      }
      return false;
    }
  }

  Future<bool> signup({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final validationError = _validateSignup(
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    if (validationError != null) {
      state = AsyncError(
        AuthValidationException(validationError),
        StackTrace.current,
      );
      return false;
    }

    final previousUser = state.asData?.value;
    state = const AsyncLoading();
    try {
      await ref
          .read(authApiClientProvider)
          .signup(
            username: username.trim(),
            email: email.trim(),
            password: password,
          );
      state = AsyncData(previousUser);
      return true;
    } catch (error, stackTrace) {
      if (error is AuthApiException) {
        state = AsyncError(AuthValidationException(error.message), stackTrace);
      } else {
        state = AsyncError(error, stackTrace);
      }
      return false;
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await ref.read(authApiClientProvider).logout();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  String? _validateLogin({required String username, required String password}) {
    if (username.trim().isEmpty || password.isEmpty) {
      return 'ユーザー名とパスワードを入力してください';
    }

    return null;
  }

  String? _validateSignup({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    if (username.trim().isEmpty ||
        email.trim().isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return '未入力の項目があります';
    }

    if (!email.contains('@')) {
      return 'メールアドレスの形式が正しくありません';
    }

    if (password.length < 8) {
      return 'パスワードは8文字以上にしてください';
    }

    if (password != confirmPassword) {
      return 'パスワードが一致しません';
    }

    return null;
  }
}

class AuthValidationException implements Exception {
  const AuthValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthConfigException implements Exception {
  const AuthConfigException(this.message);

  final String message;

  @override
  String toString() => message;
}
