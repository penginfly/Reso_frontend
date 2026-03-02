import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';

import '../features/home/presentation/home_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _currentIndex = 1;

  late final List<Widget> _tabs = const [
    _AddScreen(),
    HomeScreen(),
    _ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: CNTabBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        tint: Colors.black,
        items: const [
          CNTabBarItem(label: 'Add', icon: CNSymbol('plus.circle.fill')),
          CNTabBarItem(label: 'Home', icon: CNSymbol('house.fill')),
          CNTabBarItem(label: 'Profile', icon: CNSymbol('person.fill')),
        ],
      ),
    );
  }
}

class _AddScreen extends StatelessWidget {
  const _AddScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Add Screen')));
  }
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Profile Screen')));
  }
}
