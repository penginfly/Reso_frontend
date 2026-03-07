import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/widgets/glass_panel.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';
import '../widgets/auth_text_field.dart';

final _loginUsernameControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
      final controller = TextEditingController();
      ref.onDispose(controller.dispose);
      return controller;
    });

final _loginPasswordControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
      final controller = TextEditingController();
      ref.onDispose(controller.dispose);
      return controller;
    });

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final usernameController = ref.watch(_loginUsernameControllerProvider);
    final passwordController = ref.watch(_loginPasswordControllerProvider);
    final isSubmitting = authState.isLoading;

    ref.listen<AsyncValue<Object?>>(authProvider, (previous, next) {
      final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
      if (!isCurrentRoute) return;
      if (next.hasError) {
        final message = _errorMessage(next.error!);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });

    Future<void> openSignup() async {
      final created = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute(builder: (_) => const SignupScreen()));

      if (!context.mounted || created != true) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('作成完了。ログインしてください')));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: GlassPanel(
                  padding: const EdgeInsets.all(18),
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ログインして TRAPIZZINO をはじめよう',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.78),
                        ),
                      ),
                      const SizedBox(height: 18),
                      AuthTextField(
                        controller: usernameController,
                        label: 'ユーザー名',
                        textInputAction: TextInputAction.next,
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        controller: passwordController,
                        label: 'パスワード',
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                ref
                                    .read(authProvider.notifier)
                                    .login(
                                      username: usernameController.text,
                                      password: passwordController.text,
                                    );
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('ログイン'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: isSubmitting ? null : openSignup,
                        child: const Text('アカウントを作成する'),
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

  String _errorMessage(Object error) {
    if (error is AuthValidationException) {
      return error.message;
    }
    if (error is DioException) {
      return error.message ?? '認証リクエストに失敗しました';
    }
    return 'ログインに失敗しました';
  }
}
