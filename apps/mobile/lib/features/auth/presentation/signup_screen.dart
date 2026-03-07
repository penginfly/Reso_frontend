import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/widgets/glass_panel.dart';
import 'widgets/auth_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('未入力の項目があります');
      return;
    }

    if (!email.contains('@')) {
      _showMessage('メールアドレスの形式が正しくありません');
      return;
    }

    if (password.length < 8) {
      _showMessage('パスワードは8文字以上にしてください');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('パスワードが一致しません');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // TODO: API 接続時にユーザー作成のリクエストへ置き換える。
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      _showMessage('ユーザーを作成しました。ログインしてください');
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      _showMessage('ユーザー作成に失敗しました');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
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
                        controller: _nameController,
                        label: 'ユーザー名',
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        controller: _emailController,
                        label: 'メールアドレス',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        controller: _passwordController,
                        label: 'パスワード',
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        controller: _confirmPasswordController,
                        label: 'パスワード（確認）',
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: _isSubmitting
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
}
