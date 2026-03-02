import 'package:flutter/material.dart';

import 'app/root_shell.dart';

void main() {
  runApp(const TrapizzinoApp());
}

class TrapizzinoApp extends StatelessWidget {
  const TrapizzinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TRAPIZZINO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const RootShell(),
    );
  }
}
