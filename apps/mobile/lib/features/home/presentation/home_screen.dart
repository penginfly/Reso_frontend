import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../../app/widgets/glass_panel.dart';
import 'widgets/shop_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _googleApiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
  );
  static const String _apiBaseUrl = String.fromEnvironment(
    'TRAPIZZINO_API_BASE_URL',
    defaultValue: 'https://api.sandbox-k.uk',
  );
  static const String _authToken = String.fromEnvironment(
    'TRAPIZZINO_AUTH_TOKEN',
  );

  static const LatLng _tokyoStation = LatLng(35.681236, 139.767125);

  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  GoogleMapController? _mapController;
  LatLng? _pendingCameraTarget;

  bool _isSearchingPlaces = false;
  bool _isLoadingRecommendation = false;

  List<_PlacePrediction> _predictions = const [];
  LatLng _queryLocation = _tokyoStation;
  ShopCardData? _recommendation;
  String? _errorMessage;

  String _extractServerError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is Map<String, dynamic>) {
          final status = error['status']?.toString();
          final message = error['message']?.toString();
          if (status != null && message != null) return '$status: $message';
          if (message != null && message.isNotEmpty) return message;
        }

        final message = decoded['message']?.toString();
        if (message != null && message.isNotEmpty) return message;
      }
    } catch (_) {
      // noop
    }
    return body;
  }

  @override
  void initState() {
    super.initState();
    _loadInitialRecommendation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadInitialRecommendation() async {
    final position = await _resolveCurrentPosition();
    if (!mounted) return;

    final initial = position != null
        ? LatLng(position.latitude, position.longitude)
        : _tokyoStation;

    setState(() => _queryLocation = initial);
    _moveCamera(initial);
    await _fetchRecommendation(initial);
  }

  Future<Position?> _resolveCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = '位置情報が無効なため東京駅周辺でおすすめを表示しています';
        });
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = '位置情報の許可がないため東京駅周辺でおすすめを表示しています';
        });
        return null;
      }

      return Geolocator.getCurrentPosition();
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = '現在地の取得に失敗したため東京駅周辺で表示しています';
        });
      }
      return null;
    }
  }

  Future<void> _fetchRecommendation(LatLng location) async {
    if (_authToken.trim().isEmpty) {
      setState(() {
        _isLoadingRecommendation = false;
        _recommendation = null;
        _errorMessage = 'TRAPIZZINO_AUTH_TOKEN が未設定です。--dart-define で指定してください';
      });
      return;
    }

    setState(() {
      _isLoadingRecommendation = true;
      _errorMessage = null;
    });

    final uri = Uri.parse('$_apiBaseUrl/v1/recommendation/distill').replace(
      queryParameters: {
        'lat': location.latitude.toString(),
        'lng': location.longitude.toString(),
        'latitude': location.latitude.toString(),
        'longitude': location.longitude.toString(),
      },
    );

    try {
      debugPrint('distill request: ${uri.toString()}');
      final headers = <String, String>{
        'Accept': 'application/json',
        'Authorization': 'Bearer ${_authToken.trim()}',
      };

      final response = await http.get(uri, headers: headers);
      debugPrint('distill response: status=${response.statusCode}');

      if (!mounted) return;

      if (response.statusCode == 401 &&
          response.body.contains('no resonant users found')) {
        setState(() {
          _isLoadingRecommendation = false;
          _recommendation = null;
          _errorMessage =
              'このエリアではまだおすすめを作れません。別の場所で検索してください。';
        });
        return;
      }

      if (response.statusCode != 200) {
        throw Exception(
          'status=${response.statusCode} ${_extractServerError(response.body)}',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final recommendation =
          body['recommendation'] as Map<String, dynamic>? ?? const {};
      final spot = recommendation['spot'] as Map<String, dynamic>? ?? const {};
      final locationJson =
          spot['location'] as Map<String, dynamic>? ?? const {};
      final scores =
          recommendation['distillation_analysis'] as Map<String, dynamic>? ??
          const {};

      setState(() {
        _recommendation = ShopCardData(
          shopId: (spot['id'] as num?)?.toInt() ?? 0,
          name: spot['name'] as String? ?? 'Unknown Shop',
          meshId: spot['mesh_id'] as String? ?? '-',
          latitude:
              (locationJson['latitude'] as num?)?.toDouble() ??
              location.latitude,
          longitude:
              (locationJson['longitude'] as num?)?.toDouble() ??
              location.longitude,
          resonanceScore: (scores['resonance_score'] as num?)?.toInt() ?? 0,
          densityScore: (scores['density_score'] as num?)?.toInt() ?? 0,
          totalScore: (scores['total_score'] as num?)?.toInt() ?? 0,
          reason: scores['reason'] as String? ?? '理由が取得できませんでした',
        );
        _isLoadingRecommendation = false;
      });
    } catch (error) {
      debugPrint('distill error: $error');
      if (!mounted) return;
      setState(() {
        _isLoadingRecommendation = false;
        _recommendation = null;
        _errorMessage = 'おすすめの取得に失敗しました: $error';
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() => _predictions = const []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _searchPlaces(trimmed);
    });
  }

  Future<void> _searchPlaces(String input) async {
    if (_googleApiKey.isEmpty) return;

    setState(() => _isSearchingPlaces = true);

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
        throw Exception('autocomplete failed: ${response.statusCode}');
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
        _isSearchingPlaces = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _predictions = const [];
        _isSearchingPlaces = false;
      });
    }
  }

  Future<void> _selectPlace(_PlacePrediction prediction) async {
    if (_googleApiKey.isEmpty) return;

    final uri = Uri.https(
      'places.googleapis.com',
      '/v1/places/${prediction.placeId}',
    );

    setState(() => _isSearchingPlaces = true);

    try {
      final response = await http.get(
        uri,
        headers: {
          'X-Goog-Api-Key': _googleApiKey,
          'X-Goog-FieldMask': 'displayName,location',
          'Accept': 'application/json',
        },
      );

      if (!mounted) return;
      if (response.statusCode != 200) {
        throw Exception('place detail failed: ${response.statusCode}');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final location = body['location'] as Map<String, dynamic>?;
      final lat = (location?['latitude'] as num?)?.toDouble();
      final lng = (location?['longitude'] as num?)?.toDouble();

      if (lat == null || lng == null) {
        throw Exception('missing location');
      }

      final selected = LatLng(lat, lng);

      setState(() {
        _queryLocation = selected;
        _predictions = const [];
        _isSearchingPlaces = false;
        _searchController.text = prediction.text;
      });

      _moveCamera(selected);
      await _fetchRecommendation(selected);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSearchingPlaces = false);
    }
  }

  void _moveCamera(LatLng target) {
    final controller = _mapController;
    if (controller == null) {
      _pendingCameraTarget = target;
      return;
    }
    controller.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 15)),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    final target = _pendingCameraTarget ?? _queryLocation;
    _pendingCameraTarget = null;
    controller.moveCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 15)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: _MapBackground(
            initialTarget: _queryLocation,
            markerTarget: _queryLocation,
            onMapCreated: _onMapCreated,
          ),
        ),
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
                _SearchBar(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  isLoading: _isSearchingPlaces,
                ),
                if (_predictions.isNotEmpty)
                  _PredictionPanel(
                    predictions: _predictions,
                    onTap: _selectPlace,
                  ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: _RoundIconButton(
                    icon: CupertinoIcons.arrow_2_circlepath,
                    onTap: () => _fetchRecommendation(_queryLocation),
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
            child: ShopCard(
              data: _recommendation,
              isLoading: _isLoadingRecommendation,
              errorMessage: _errorMessage,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.isLoading,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const Icon(CupertinoIcons.search, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: '場所で検索',
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            const Icon(CupertinoIcons.slider_horizontal_3, size: 20),
        ],
      ),
    );
  }
}

class _PredictionPanel extends StatelessWidget {
  const _PredictionPanel({required this.predictions, required this.onTap});

  final List<_PlacePrediction> predictions;
  final Future<void> Function(_PlacePrediction prediction) onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GlassPanel(
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: predictions.length,
            separatorBuilder: (_, _) =>
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.12)),
            itemBuilder: (context, index) {
              final prediction = predictions[index];
              return ListTile(
                title: Text(prediction.text),
                trailing: const Icon(CupertinoIcons.chevron_right),
                onTap: () => onTap(prediction),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassPanel(
        borderRadius: BorderRadius.circular(999),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 24, color: const Color(0xFFEAF0F7)),
      ),
    );
  }
}

class _MapBackground extends StatelessWidget {
  const _MapBackground({
    required this.initialTarget,
    required this.markerTarget,
    required this.onMapCreated,
  });

  final LatLng initialTarget;
  final LatLng markerTarget;
  final ValueChanged<GoogleMapController> onMapCreated;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initialTarget, zoom: 15),
      onMapCreated: onMapCreated,
      markers: {
        Marker(
          markerId: const MarkerId('query_target'),
          position: markerTarget,
          infoWindow: const InfoWindow(title: '検索地点'),
        ),
      },
      mapToolbarEnabled: false,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
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
