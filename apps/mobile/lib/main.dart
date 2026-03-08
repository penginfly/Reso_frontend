import 'package:flutter/material.dart';

import 'app/root_shell.dart';
import 'features/auth/auth_secure_storage.dart';
import 'features/auth/presentation/login_screen.dart';

void main() {
  runApp(const TrapizzinoApp());
}

class TrapizzinoApp extends StatelessWidget {
  const TrapizzinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TRAPIZZINO',
      theme: base.copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF9AD2FF),
          secondary: Color(0xFFFFC986),
          surface: Color(0xFF1A2030),
          onPrimary: Color(0xFF0D1320),
          onSurface: Color(0xFFF2F5FA),
        ),
        textTheme: base.textTheme.apply(
          fontFamily: 'SF Pro Text',
          bodyColor: const Color(0xFFEAF0F7),
          displayColor: const Color(0xFFF7FAFF),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFFF7FAFF),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: Color(0xFFF7FAFF),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF9AD2FF), width: 1.3),
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isAuthenticated = false;
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final token = await AuthSecureStorage.instance.readAccessToken();
    if (!mounted) return;

    setState(() {
      _isAuthenticated = token != null && token.isNotEmpty;
      _isCheckingSession = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isAuthenticated) {
      return const RootShell();
    }

    return LoginScreen(
      onLoginSuccess: () => setState(() => _isAuthenticated = true),
    );
  }
}
