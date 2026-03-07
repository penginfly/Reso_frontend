import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';

import '../features/add/presentation/add_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/profile/presentation/profile_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _currentIndex = 1;

  late final List<Widget> _tabs = const [
    AddScreen(),
    HomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: CNTabBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.black.withValues(alpha: 0.92),
        tint: Colors.white,
        items: const [
          CNTabBarItem(label: 'Add', icon: CNSymbol('plus.circle.fill')),
          CNTabBarItem(label: 'Home', icon: CNSymbol('house.fill')),
          CNTabBarItem(
            label: 'Profile',
            icon: CNSymbol('person.crop.circle.fill'),
          ),
        ],
      ),
    );
  }
}
