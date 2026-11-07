import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/resource.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/liquid_glass.dart';

class LocationFeedScreen extends ConsumerStatefulWidget {
  const LocationFeedScreen({super.key});

  @override
  ConsumerState<LocationFeedScreen> createState() => _LocationFeedScreenState();
}

class _LocationFeedScreenState extends ConsumerState<LocationFeedScreen> {
  String? _currentCity;
  bool _loading = false;
  String _searchFilter = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() => _loading = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm != LocationPermission.denied && perm != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
        final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty && mounted) {
          setState(() {
            _currentCity = placemarks.first.locality ?? placemarks.first.subLocality ?? placemarks.first.name;
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final allResources = ref.watch(resourcesProvider);
    final locationItems = allResources
        .where((r) => r.locationName != null && r.locationName!.isNotEmpty)
        .toList();

    final filtered = _searchFilter.isNotEmpty
        ? locationItems
            .where((r) => r.locationName!.toLowerCase().contains(_searchFilter.toLowerCase()))
            .toList()
        : locationItems;

    final Map<String, List<ResourceModel>> groups = {};
    for (final r in filtered) {
      groups.putIfAbsent(r.locationName!, () => []).add(r);
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nearby & Food',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -1.0,
                      ),
                    ),
                    if (_loading)
                      const CupertinoActivityIndicator(radius: 10, color: AppColors.appleGreen)
                    else if (_currentCity != null)
                      LiquidGlass(
                        borderRadius: 16,
                        blur: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(CupertinoIcons.location_fill, size: 12, color: AppColors.appleGreen),
                            const SizedBox(width: 4),
                            Text(
                              _currentCity!,
                              style: const TextStyle(
                                color: AppColors.appleGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                CupertinoSearchTextField(
                  controller: _searchController,
                  placeholder: 'Filter by city, area, or street...',
                  style: const TextStyle(color: Colors.white),
                  itemColor: AppColors.textTertiary,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0x331C1C28),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x28FFFFFF)),
                  ),
                  onChanged: (val) => setState(() => _searchFilter = val),
                ),
              ],
            ),
          ),
          Expanded(
            child: locationItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.placemark_fill, size: 48, color: AppColors.appleLime),
                        SizedBox(height: 12),
                        Text(
                          'No location-tagged reels yet',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Tag location when saving food & travel reels',
                          style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    physics: const BouncingScrollPhysics(),
                    itemCount: groups.length,
                    itemBuilder: (context, i) {
                      final loc = groups.keys.elementAt(i);
                      final items = groups[loc]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                const Icon(CupertinoIcons.location_solid, size: 16, color: AppColors.appleGreen),
                                const SizedBox(width: 6),
                                Text(
                                  loc,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${items.length})',
                                  style: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 145,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: items.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, idx) {
                                final res = items[idx];
                                return LiquidGlass(
                                  borderRadius: 18,
                                  blur: 16,
                                  onTap: () async {
                                    final uri = Uri.tryParse(res.url);
                                    if (uri != null && await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    }
                                  },
                                  child: SizedBox(
                                    width: 135,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                          child: res.thumbnailUrl.isNotEmpty
                                              ? CachedNetworkImage(
                                                  imageUrl: res.thumbnailUrl,
                                                  height: 90,
                                                  width: 135,
                                                  fit: BoxFit.cover,
                                                  errorWidget: (_, __, ___) => _fallback(),
                                                )
                                              : _fallback(),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            res.title.isNotEmpty ? res.title : res.url,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Container(
      height: 90,
      width: 135,
      color: const Color(0x381C1C28),
      child: const Center(child: Icon(CupertinoIcons.placemark_fill, size: 28, color: AppColors.appleLime)),
    );
  }
}
