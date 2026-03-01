import 'package:flutter/material.dart';

import 'widgets/shop_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const Positioned.fill(child: _MapBackground()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: _SearchBar(onTap: () {}),
            ),
          ),
          Positioned(
            top: 110,
            right: 10,
            child: _RoundIconButton(icon: Icons.sync, onPressed: () {}),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 76),
              child: const ShopCard(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomBar(),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black, width: 1.8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: const Row(
          children: [
            Expanded(child: SizedBox()),
            Icon(Icons.search, size: 34, color: Colors.black87),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 26, color: Colors.white),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: const BoxDecoration(
        color: Color(0xFFF3F3F3),
        border: Border(top: BorderSide(color: Color(0x22000000))),
      ),
      padding: const EdgeInsets.fromLTRB(36, 4, 36, 8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BottomBarAddButton(),
          Icon(Icons.home_outlined, size: 44, color: Colors.black87),
          Icon(Icons.person_outline, size: 44, color: Colors.black87),
        ],
      ),
    );
  }
}

class _BottomBarAddButton extends StatelessWidget {
  const _BottomBarAddButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: const BoxDecoration(
        color: Color(0xFFE60000),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: const [
            Icon(Icons.crop_square_rounded, size: 34, color: Colors.black),
            Icon(Icons.add, size: 30, color: Colors.black),
          ],
        ),
      ),
    );
  }
}

class _MapBackground extends StatelessWidget {
  const _MapBackground();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE4E4E4),
      child: CustomPaint(painter: _MapPainter()),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final streetPaint = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..strokeWidth = 22
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final minorStreetPaint = Paint()
      ..color = const Color(0xFFF6F6F6)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final blockPaint = Paint()..color = const Color(0xFFD6D6D6);

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.02,
        size.height * 0.65,
        size.width * 0.36,
        140,
      ),
      blockPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.73,
        size.height * 0.23,
        size.width * 0.25,
        110,
      ),
      blockPaint,
    );

    _drawStreet(canvas, streetPaint, [
      Offset(size.width * -0.1, size.height * 0.15),
      Offset(size.width * 0.32, size.height * 0.28),
      Offset(size.width * 0.7, size.height * 0.5),
      Offset(size.width * 1.1, size.height * 0.7),
    ]);

    _drawStreet(canvas, streetPaint, [
      Offset(size.width * 0.85, size.height * -0.05),
      Offset(size.width * 0.58, size.height * 0.26),
      Offset(size.width * 0.44, size.height * 0.48),
      Offset(size.width * 0.2, size.height * 0.84),
    ]);

    for (var i = -2; i < 9; i++) {
      final dx = size.width * (0.1 + (i * 0.11));
      _drawStreet(canvas, minorStreetPaint, [
        Offset(dx, size.height * 0.1),
        Offset(dx + size.width * 0.06, size.height * 0.95),
      ]);
    }

    for (var i = 0; i < 8; i++) {
      final dy = size.height * (0.17 + (i * 0.1));
      _drawStreet(canvas, minorStreetPaint, [
        Offset(size.width * -0.05, dy),
        Offset(size.width * 1.05, dy + size.height * 0.03),
      ]);
    }
  }

  void _drawStreet(Canvas canvas, Paint paint, List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
