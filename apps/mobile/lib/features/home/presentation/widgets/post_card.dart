import 'package:flutter/material.dart';

class PostCardData {
  const PostCardData({
    required this.shopName,
    required this.caption,
    this.imageUrl,
  });

  final String shopName;
  final String caption;
  final String? imageUrl;
}

class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.data});

  final PostCardData data;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _hideImage = false;

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.imageUrl != widget.data.imageUrl) {
      _hideImage = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.data.imageUrl;
    final hasImageUrl = imageUrl != null && imageUrl.trim().isNotEmpty;
    final showImage = hasImageUrl && !_hideImage;
    final isCompact = !showImage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isCompact ? 20 : 26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF12243A).withValues(alpha: 0.94),
            const Color(0xFF0A1322).withValues(alpha: 0.92),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      padding: isCompact
          ? const EdgeInsets.fromLTRB(12, 10, 12, 10)
          : const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF36D1DC),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.data.shopName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          if (showImage) ...[
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 4 / 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted && !_hideImage) {
                            setState(() => _hideImage = true);
                          }
                        });
                        return const SizedBox.shrink();
                      },
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.42),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: isCompact ? 8 : 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(isCompact ? 12 : 14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 10 : 12,
              vertical: isCompact ? 8 : 10,
            ),
            child: Text(
              widget.data.caption.isEmpty ? 'キャプションなし' : widget.data.caption,
              maxLines: isCompact ? 2 : 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(
                height: 1.35,
                fontSize: isCompact ? 12.5 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
