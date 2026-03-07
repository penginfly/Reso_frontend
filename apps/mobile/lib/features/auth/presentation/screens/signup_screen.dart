import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/widgets/glass_panel.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

final _signupUsernameControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
      final controller = TextEditingController();
      ref.onDispose(controller.dispose);
      return controller;
    });

final _signupEmailControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
      final controller = TextEditingController();
      ref.onDispose(controller.dispose);
      return controller;
    });

final _signupPasswordControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
      final controller = TextEditingController();
      ref.onDispose(controller.dispose);
      return controller;
    });

final _signupConfirmPasswordControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
      final controller = TextEditingController();
      ref.onDispose(controller.dispose);
      return controller;
    });

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final usernameController = ref.watch(_signupUsernameControllerProvider);
    final emailController = ref.watch(_signupEmailControllerProvider);
    final passwordController = ref.watch(_signupPasswordControllerProvider);
    final confirmPasswordController = ref.watch(
      _signupConfirmPasswordControllerProvider,
    );
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          tooltip: '戻る',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create Account',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ユーザー情報を入力してアカウントを作成',
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
                        controller: emailController,
                        label: 'メールアドレス',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        controller: passwordController,
                        label: 'パスワード',
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        controller: confirmPasswordController,
                        label: 'パスワード（確認）',
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final ok = await ref
                                    .read(authProvider.notifier)
                                    .signup(
                                      username: usernameController.text,
                                      email: emailController.text,
                                      password: passwordController.text,
                                      confirmPassword:
                                          confirmPasswordController.text,
                                    );
                                if (!context.mounted || !ok) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('ユーザーを作成しました。ログインしてください'),
                                  ),
                                );
                                Navigator.of(context).pop(true);
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
                              : const Text('ユーザー作成'),
                        ),
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
      return error.message ?? 'ユーザー作成に失敗しました';
    }
    return 'ユーザー作成に失敗しました';
  }
}
