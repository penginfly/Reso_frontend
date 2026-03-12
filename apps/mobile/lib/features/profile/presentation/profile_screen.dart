import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../auth/auth_secure_storage.dart';
import '../../home/presentation/widgets/post_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _apiBaseUrl = String.fromEnvironment(
    'TRAPIZZINO_API_BASE_URL',
    defaultValue: 'https://api.sandbox-k.uk',
  );

  bool _isLoading = true;
  String? _errorMessage;
  List<_UserSpotPost> _posts = const [];

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
  }

  Future<void> _loadUserPosts() async {
    final token = (await AuthSecureStorage.instance.readAccessToken() ?? '')
        .trim();

    if (token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'ログイン情報が見つかりません。再ログインしてください。';
      });
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final uri = Uri.parse('$_apiBaseUrl/v1/users/me/spots');

    try {
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          '投稿一覧の取得に失敗しました (status: ${response.statusCode})',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('サーバーレスポンスの形式が不正です');
      }

      final userSpots = decoded['user_spots'];
      if (userSpots is! List) {
        throw Exception('user_spots がレスポンスに含まれていません');
      }

      final posts = userSpots
          .whereType<Map<String, dynamic>>()
          .map(_UserSpotPost.fromJson)
          .toList();

      if (!mounted) return;
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '通信がタイムアウトしました。時間をおいて再試行してください。';
      });
    } on SocketException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'サーバーに接続できません。ネットワークまたはAPI URLを確認してください。';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _openPostFeed(int initialIndex) {
    final posts = _posts
        .map(
          (post) => PostCardData(
            shopName: post.name,
            caption: post.caption ?? '',
            imageUrl: post.imageUrl,
          ),
        )
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _ProfilePostFeedScreen(posts: posts, initialIndex: initialIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _loadUserPosts,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              Text(
                'Post',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 36),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage != null)
                _StatusCard(
                  message: _errorMessage!,
                  actionLabel: '再試行',
                  onAction: _loadUserPosts,
                )
              else if (_posts.isEmpty)
                const _StatusCard(message: '投稿はまだありません')
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _posts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    return _PostGridTile(
                      post: post,
                      onTap: () => _openPostFeed(index),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.message, this.actionLabel, this.onAction});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 10),
            FilledButton.tonal(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _PostGridTile extends StatelessWidget {
  const _PostGridTile({required this.post, required this.onTap});

  final _UserSpotPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: post.imageUrl != null && post.imageUrl!.isNotEmpty
                      ? Image.network(
                          post.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const _ImagePlaceholder();
                          },
                        )
                      : const _ImagePlaceholder(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                post.caption ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
    );
  }
}

class _UserSpotPost {
  const _UserSpotPost({required this.name, required this.caption, this.imageUrl});

  factory _UserSpotPost.fromJson(Map<String, dynamic> json) {
    final spot = json['spot'] as Map<String, dynamic>? ?? const {};
    final post = json['post'] as Map<String, dynamic>? ?? const {};
    return _UserSpotPost(
      name: spot['name']?.toString() ?? 'Unknown Spot',
      caption: post['caption']?.toString(),
      imageUrl: post['image_url']?.toString(),
    );
  }

  final String name;
  final String? caption;
  final String? imageUrl;
}

class _ProfilePostFeedScreen extends StatefulWidget {
  const _ProfilePostFeedScreen({
    required this.posts,
    required this.initialIndex,
  });

  final List<PostCardData> posts;
  final int initialIndex;

  @override
  State<_ProfilePostFeedScreen> createState() => _ProfilePostFeedScreenState();
}

class _ProfilePostFeedScreenState extends State<_ProfilePostFeedScreen> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B12),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0F1A2B).withValues(alpha: 0.65),
                    const Color(0xFF070B12),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(CupertinoIcons.chevron_down),
                      ),
                      const Spacer(),
                      Text(
                        '${_currentIndex + 1}/${widget.posts.length}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    scrollDirection: Axis.vertical,
                    itemCount: widget.posts.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: PostCard(data: widget.posts[index]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
