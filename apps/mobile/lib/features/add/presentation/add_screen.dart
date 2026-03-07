import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../app/widgets/glass_panel.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  static const String _googleApiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
  );
  static const String _apiBaseUrl = String.fromEnvironment(
    'TRAPIZZINO_API_BASE_URL',
    defaultValue: 'https://api.sandbox-kc.uk',
  );
  static const String _defaultAuthToken = String.fromEnvironment(
    'TRAPIZZINO_AUTH_TOKEN',
  );
  static const String _cloudinaryName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
  );
  static const String _cloudinaryPreset = String.fromEnvironment(
    'CLOUDINARY_UNSIGNED_UPLOAD_PRESET',
  );

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  Timer? _debounce;

  bool _isSearching = false;
  bool _isLoadingDetail = false;
  bool _isUploadingImage = false;
  bool _isSubmitting = false;

  List<_PlacePrediction> _predictions = const [];
  _PlaceDetails? _selectedPlace;
  List<XFile> _pickedImages = const [];
  List<String> _uploadedImageUrls = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  bool get _isBusy =>
      _isSearching || _isLoadingDetail || _isUploadingImage || _isSubmitting;

  void _onQueryChanged(String value) {
    _debounce?.cancel();

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _predictions = const [];
        _selectedPlace = null;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _searchPlaces(trimmed);
    });
  }

  Future<void> _searchPlaces(String input) async {
    if (_googleApiKey.isEmpty) return;

    setState(() {
      _isSearching = true;
      _selectedPlace = null;
    });

    final uri = Uri.https('places.googleapis.com', '/v1/places:autocomplete');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _googleApiKey,
          'X-Goog-FieldMask':
              'suggestions.placePrediction.placeId,suggestions.placePrediction.text.text',
        },
        body: jsonEncode({
          'input': input,
          'includedPrimaryTypes': ['restaurant', 'cafe', 'bakery'],
          'languageCode': 'ja',
          'regionCode': 'JP',
        }),
      );

      if (!mounted) return;

      if (response.statusCode != 200) {
        throw Exception(
          'autocomplete failed: ${response.statusCode} ${_extractApiError(response.body)}',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final suggestions = (body['suggestions'] as List<dynamic>? ?? const []);

      final predictions = suggestions
          .whereType<Map<String, dynamic>>()
          .map((s) => s['placePrediction'])
          .whereType<Map<String, dynamic>>()
          .map(_PlacePrediction.fromJson)
          .where((p) => p.placeId.isNotEmpty)
          .toList();

      setState(() {
        _predictions = predictions;
        _isSearching = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _predictions = const [];
        _isSearching = false;
      });
      final message = _humanizePlacesError(error);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String _extractApiError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is Map<String, dynamic>) {
          final status = error['status']?.toString();
          final message = error['message']?.toString();
          if (status != null && message != null) {
            return '$status: $message';
          }
          if (message != null) {
            return message;
          }
        }
      }
    } catch (_) {
      // noop
    }
    return body;
  }

  String _humanizePlacesError(Object error) {
    final text = error.toString();
    if (text.contains('REQUEST_DENIED') || text.contains('PERMISSION_DENIED')) {
      return '店舗検索に失敗しました: APIキーの制限/有効化設定を確認してください';
    }
    if (text.contains('API_KEY_INVALID')) {
      return '店舗検索に失敗しました: GOOGLE_PLACES_API_KEY が無効です';
    }
    if (text.contains('SocketException')) {
      return '店舗検索に失敗しました: ネットワーク接続を確認してください';
    }
    return '店舗検索に失敗しました: $text';
  }

  Future<void> _selectPlace(_PlacePrediction prediction) async {
    if (_googleApiKey.isEmpty) return;

    setState(() => _isLoadingDetail = true);

    final uri = Uri.https(
      'places.googleapis.com',
      '/v1/places/${prediction.placeId}',
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'X-Goog-Api-Key': _googleApiKey,
          'X-Goog-FieldMask': 'id,displayName,formattedAddress,location',
          'Accept': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode != 200) {
        throw Exception('place detail failed: ${response.statusCode}');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      setState(() {
        _selectedPlace = _PlaceDetails.fromJson(body);
        _isLoadingDetail = false;
        _predictions = const [];
        _searchController.text = _selectedPlace!.name;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingDetail = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('店舗詳細の取得に失敗しました')));
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 80);

    if (!mounted || files.isEmpty) return;

    setState(() {
      _pickedImages = files;
      _uploadedImageUrls = const [];
    });
  }

  Future<List<String>> _uploadImagesToCloudinary() async {
    if (_pickedImages.isEmpty) return _uploadedImageUrls;

    if (_cloudinaryName.isEmpty || _cloudinaryPreset.isEmpty) {
      throw Exception('Cloudinary config missing');
    }

    setState(() => _isUploadingImage = true);

    try {
      final cloudinary = CloudinaryPublic(
        _cloudinaryName,
        _cloudinaryPreset,
        cache: false,
      );
      final uploadedUrls = <String>[];
      for (final image in _pickedImages) {
        final response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            image.path,
            resourceType: CloudinaryResourceType.Image,
            folder: 'trapizzino/spots',
          ),
        );
        uploadedUrls.add(response.secureUrl);
      }

      if (!mounted) return const [];

      setState(() {
        _uploadedImageUrls = uploadedUrls;
        _isUploadingImage = false;
      });
      return uploadedUrls;
    } catch (_) {
      if (!mounted) return const [];
      setState(() => _isUploadingImage = false);
      rethrow;
    }
  }

  Future<void> _submitSpot() async {
    final selected = _selectedPlace;
    final token = _defaultAuthToken.trim();

    if (selected == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('先に店舗を選択してください')));
      return;
    }

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'TRAPIZZINO_AUTH_TOKEN が未設定です。--dart-define で指定してください。',
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final imageUrls = await _uploadImagesToCloudinary();
      final uri = Uri.parse('$_apiBaseUrl/v1/users/me/spots');

      final payload = {
        'placeId': selected.placeId,
        'name': selected.name,
        'address': selected.address,
        'latitude': selected.lat,
        'longitude': selected.lng,
        if (imageUrls.isNotEmpty) 'imageUrl': imageUrls.first,
        if (imageUrls.isNotEmpty) 'imageUrls': imageUrls,
        if (_commentController.text.trim().isNotEmpty)
          'comment': _commentController.text.trim(),
      };

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (!mounted) return;

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('post failed: ${response.statusCode} ${response.body}');
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('投稿しました')));

      setState(() {
        _commentController.clear();
        _pickedImages = const [];
        _uploadedImageUrls = const [];
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('投稿に失敗しました。設定と通信状態を確認してください')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final missingPlacesKey = _googleApiKey.isEmpty;
    final missingCloudinary =
        _cloudinaryName.isEmpty || _cloudinaryPreset.isEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Add Spot')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
          children: [
            if (missingPlacesKey)
              const _WarningCard(
                message:
                    'GOOGLE_PLACES_API_KEY が未設定です。\n--dart-define=GOOGLE_PLACES_API_KEY=YOUR_KEY を付けて起動してください。',
              ),
            if (missingCloudinary)
              const _WarningCard(
                message:
                    'Cloudinary設定が未設定です。\n--dart-define=CLOUDINARY_CLOUD_NAME=...\n--dart-define=CLOUDINARY_UNSIGNED_UPLOAD_PRESET=...',
              ),
            GlassPanel(
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '追加するスポット',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onChanged: _onQueryChanged,
                    decoration: InputDecoration(
                      hintText: '店名・住所で検索',
                      prefixIcon: const Icon(CupertinoIcons.search),
                      suffixIcon: (_isSearching || _isLoadingDetail)
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  if (_predictions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.separated(
                        itemCount: _predictions.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                        itemBuilder: (_, index) {
                          final prediction = _predictions[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(prediction.text),
                            trailing: const Icon(CupertinoIcons.chevron_right),
                            onTap: () => _selectPlace(prediction),
                          );
                        },
                      ),
                    ),
                  ],
                  if (_selectedPlace != null) ...[
                    const SizedBox(height: 10),
                    _SelectedPlaceCard(place: _selectedPlace!),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isBusy ? null : _pickImages,
                          icon: const Icon(CupertinoIcons.photo_on_rectangle),
                          label: const Text('画像を複数選択'),
                        ),
                      ),
                      if (_pickedImages.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Text(
                          '${_pickedImages.length}枚',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ],
                  ),
                  if (_pickedImages.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 86,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _pickedImages.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final image = _pickedImages[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(image.path),
                              width: 86,
                              height: 86,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'コメント（任意）'),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isBusy ? null : _submitSpot,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFFFFC986),
                        foregroundColor: const Color(0xFF111622),
                        textStyle: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      child: _isBusy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('投稿する'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassPanel(
        borderRadius: BorderRadius.circular(16),
        opacity: 0.26,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _SelectedPlaceCard extends StatelessWidget {
  const _SelectedPlaceCard({required this.place});

  final _PlaceDetails place;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(place.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(place.address),
          const SizedBox(height: 6),
          Text(
            'lat: ${place.lat.toStringAsFixed(6)}, lng: ${place.lng.toStringAsFixed(6)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _PlacePrediction {
  const _PlacePrediction({required this.placeId, required this.text});

  final String placeId;
  final String text;

  factory _PlacePrediction.fromJson(Map<String, dynamic> json) {
    final textMap = json['text'] as Map<String, dynamic>?;
    return _PlacePrediction(
      placeId: json['placeId'] as String? ?? '',
      text: textMap?['text'] as String? ?? 'Unknown',
    );
  }
}

class _PlaceDetails {
  const _PlaceDetails({
    required this.placeId,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });

  final String placeId;
  final String name;
  final String address;
  final double lat;
  final double lng;

  factory _PlaceDetails.fromJson(Map<String, dynamic> json) {
    final displayName = json['displayName'] as Map<String, dynamic>?;
    final location = json['location'] as Map<String, dynamic>?;

    return _PlaceDetails(
      placeId: json['id'] as String? ?? '',
      name: displayName?['text'] as String? ?? 'Unknown',
      address: json['formattedAddress'] as String? ?? '',
      lat: (location?['latitude'] as num?)?.toDouble() ?? 0,
      lng: (location?['longitude'] as num?)?.toDouble() ?? 0,
    );
  }
}
