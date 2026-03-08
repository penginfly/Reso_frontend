import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../app/widgets/glass_panel.dart';

class ShopCardData {
  const ShopCardData({
    required this.shopId,
    required this.name,
    required this.meshId,
    required this.latitude,
    required this.longitude,
    required this.resonanceScore,
    required this.densityScore,
    required this.totalScore,
    required this.reason,
  });

  final int shopId;
  final String name;
  final String meshId;
  final double latitude;
  final double longitude;
  final int resonanceScore;
  final int densityScore;
  final int totalScore;
  final String reason;
}

class ShopCard extends StatelessWidget {
  const ShopCard({
    super.key,
    this.data,
    this.isLoading = false,
    this.errorMessage,
  });

  final ShopCardData? data;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(28),
      opacity: 0.18,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading)
            const _StatusText(label: 'おすすめを検索中...')
          else if (errorMessage != null)
            _StatusText(label: errorMessage!)
          else if (data == null)
            const _StatusText(label: 'おすすめが見つかりませんでした')
          else ...[
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  child: const Icon(CupertinoIcons.flame_fill, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Text(
                        'mesh:${data!.meshId} / score:${data!.totalScore}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(CupertinoIcons.bookmark, size: 20),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.24),
                      Colors.white.withValues(alpha: 0.08),
                    ],
                  ),
                ),
                child: Text(
                  data!.reason,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ActionChip(
                    label: '共鳴:${data!.resonanceScore}',
                    icon: CupertinoIcons.waveform_path,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionChip(
                    label: '密度:${data!.densityScore}',
                    icon: CupertinoIcons.circle_grid_3x3_fill,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: const _ActionChip(
                    label: '詳細',
                    icon: CupertinoIcons.info_circle_fill,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
