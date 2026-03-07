import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../app/widgets/glass_panel.dart';
import 'widgets/shop_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _MapBackground()),
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0F1728).withValues(alpha: 0.40),
                    Colors.transparent,
                    const Color(0xFF101827).withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SearchBar(onTap: () {}),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerRight,
                  child: _RoundIconButton(
                    icon: CupertinoIcons.arrow_2_circlepath,
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(14, 0, 14, 94),
            child: const ShopCard(),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Icon(CupertinoIcons.search, size: 20),
              const SizedBox(width: 8),
              Text(
                'どこへ行く？',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(CupertinoIcons.slider_horizontal_3, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(999),
      padding: const EdgeInsets.all(8),
      child: Icon(icon, size: 24, color: const Color(0xFFEAF0F7)),
    );
  }
}

class _MapBackground extends StatelessWidget {
  const _MapBackground();

  @override
  Widget build(BuildContext context) {
    const tokyoStation = LatLng(35.681236, 139.767125);

    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: tokyoStation,
        zoom: 15,
      ),
      markers: {
        const Marker(
          markerId: MarkerId('tokyo_station'),
          position: tokyoStation,
          infoWindow: InfoWindow(title: '東京駅'),
        ),
      },
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
    );
  }
}
