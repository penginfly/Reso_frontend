import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../app/widgets/glass_panel.dart';
import 'post_card.dart';

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
    this.postCards = const [],
    this.firstPostImageUrl,
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
  final List<PostCardData> postCards;
  final String? firstPostImageUrl;
}

class ShopCard extends StatelessWidget {
  const ShopCard({
    super.key,
    this.data,
    this.isLoading = false,
    this.errorMessage,
    this.onDetailTap,
  });

  final ShopCardData? data;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onDetailTap;

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
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                height: 180,
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
                child:
                    (data!.firstPostImageUrl != null &&
                        data!.firstPostImageUrl!.isNotEmpty)
                    ? Image.network(
                        data!.firstPostImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(CupertinoIcons.photo, size: 28),
                          );
                        },
                      )
                    : const Center(child: Icon(CupertinoIcons.photo, size: 28)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ActionChip(
                    label: '詳細',
                    icon: CupertinoIcons.info_circle_fill,
                    onTap: onDetailTap,
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
  const _ActionChip({required this.label, required this.icon, this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
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
        ),
      ),
    );
  }
}
