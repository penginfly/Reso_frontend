import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // TODO: 本番アイコンが準備できたら、このパスを差し替えてください。
  static const String _avatarAssetPath =
      'assets/images/profile_placeholder.png';
  static const List<_MockPost> _mockPosts = [
    _MockPost(title: 'TRAPIZZINO TOKYO', area: '中目黒', likes: 42),
    _MockPost(title: 'PIZZA LAB', area: '代官山', likes: 31),
    _MockPost(title: 'ROMA SLICE', area: '渋谷', likes: 26),
    _MockPost(title: 'PANINI HOUSE', area: '恵比寿', likes: 55),
    _MockPost(title: 'SICILIA CAFE', area: '表参道', likes: 19),
    _MockPost(title: 'VINO & BITE', area: '広尾', likes: 64),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            Text(
              'Profile',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white24,
                        backgroundImage: AssetImage(_avatarAssetPath),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TRAPIZZINO Collector',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ユーザー名',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.74),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(CupertinoIcons.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '街の空気まで美味しい店を集める。\n次の一皿のためのメモ。',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: const [
                      Expanded(
                        child: _ProfileStat(label: 'Posts', value: '24'),
                      ),
                      Expanded(
                        child: _ProfileStat(label: 'Following', value: '108'),
                      ),
                      Expanded(
                        child: _ProfileStat(label: 'Followers', value: '312'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  '投稿',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_mockPosts.length} items',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _mockPosts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final post = _mockPosts[index];
                return _PostGridTile(post: post);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PostGridTile extends StatelessWidget {
  const _PostGridTile({required this.post});

  final _MockPost post;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.18),
                    Colors.white.withValues(alpha: 0.06),
                  ],
                ),
              ),
              child: const Center(child: Icon(CupertinoIcons.photo, size: 28)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            post.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  post.area,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(CupertinoIcons.heart_fill, size: 12),
              const SizedBox(width: 3),
              Text(
                '${post.likes}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

class _MockPost {
  const _MockPost({
    required this.title,
    required this.area,
    required this.likes,
  });

  final String title;
  final String area;
  final int likes;
}
