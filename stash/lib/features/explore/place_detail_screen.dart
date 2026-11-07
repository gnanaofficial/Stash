import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/place.dart';
import '../../core/providers/places_provider.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/liquid_glass.dart';

class PlaceDetailScreen extends ConsumerStatefulWidget {
  final String placeId;
  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  ConsumerState<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends ConsumerState<PlaceDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final places = ref.watch(placesProvider);
    final place = places.firstWhere(
      (p) => p.id == widget.placeId,
      orElse: () => defaultCuratedPlaces.first,
    );
    final allResources = ref.watch(resourcesProvider);
    final linkedResources = allResources
        .where((r) => place.linkedResourceIds.contains(r.id))
        .toList();

    return CupertinoPageScaffold(
      backgroundColor: AppColors.bg,
      child: Stack(
        children: [
          // Ambient orb
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.appleOrange.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero image area with back button
              SliverAppBar(
                expandedHeight: 260,
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      place.imageUrl.isNotEmpty
                          ? Image.network(
                              place.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF1A1A2E),
                                child: Center(
                                  child: Icon(
                                    place.categoryVectorIcon,
                                    size: 64,
                                    color: AppColors.appleLime,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: const Color(0xFF1A1A2E),
                              child: Center(
                                child: Icon(
                                  place.categoryVectorIcon,
                                  size: 64,
                                  color: AppColors.appleLime,
                                ),
                              ),
                            ),
                      // Gradient overlay
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xCC0A0A12)],
                            stops: [0.5, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back + actions row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0x44000000),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0x38FFFFFF), width: 0.7),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.arrow_left,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Directions button
                          LiquidGlass(
                            borderRadius: 14,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            tintColor: AppColors.appleBlue.withValues(alpha: 0.3),
                            onTap: () async {
                              final url = Uri.parse(
                                'https://maps.google.com/?q=${place.latitude},${place.longitude}',
                              );
                              if (await canLaunchUrl(url)) launchUrl(url);
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(CupertinoIcons.map_fill, color: Colors.white, size: 15),
                                SizedBox(width: 6),
                                Text(
                                  'Directions',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Name & category
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.appleLime.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(place.categoryVectorIcon, color: AppColors.appleLime, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              place.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        place.address,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Rating, price, city row
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          _InfoPill(
                            icon: CupertinoIcons.star_fill,
                            label: place.rating.toStringAsFixed(1),
                            color: AppColors.appleOrange,
                          ),
                          _InfoPill(
                            label: place.priceLevel,
                            color: AppColors.appleGreen,
                          ),
                          _InfoPill(
                            icon: CupertinoIcons.location_fill,
                            label: place.city,
                            color: AppColors.appleBlue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: LiquidGlassButton(
                              height: 46,
                              backgroundColor: place.isSaved
                                  ? AppColors.applePink.withValues(alpha: 0.35)
                                  : const Color(0x28FFFFFF),
                              onPressed: () => ref.read(placesProvider.notifier).toggleSaved(place.id),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    place.isSaved ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                    color: place.isSaved ? AppColors.applePink : Colors.white,
                                    size: 17,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    place.isSaved ? 'Saved' : 'Save',
                                    style: TextStyle(
                                      color: place.isSaved ? AppColors.applePink : Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: LiquidGlassButton(
                              height: 46,
                              backgroundColor: place.isVisited
                                  ? AppColors.appleGreen.withValues(alpha: 0.35)
                                  : const Color(0x28FFFFFF),
                              onPressed: () => ref.read(placesProvider.notifier).markVisited(place.id),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    place.isVisited ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.checkmark_circle,
                                    color: place.isVisited ? AppColors.appleGreen : Colors.white,
                                    size: 17,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    place.isVisited ? 'Visited ✓' : 'Mark Visited',
                                    style: TextStyle(
                                      color: place.isVisited ? AppColors.appleGreen : Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Notes section
                      if (place.notes.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0x201C1C24),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0x28FFFFFF), width: 0.7),
                              ),
                              child: Text(
                                place.notes,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Linked Resources Section
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Linked Reels & Links',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showLinkResourceSheet(context, place),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.appleBlue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.appleBlue.withValues(alpha: 0.5),
                                  width: 0.7,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(CupertinoIcons.link, color: AppColors.appleBlue, size: 13),
                                  SizedBox(width: 4),
                                  Text(
                                    'Link',
                                    style: TextStyle(
                                      color: AppColors.appleBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (linkedResources.isEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0x161C1C24),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0x22FFFFFF), width: 0.7),
                              ),
                              child: const Center(
                                child: Text(
                                  'No linked content yet.\nTap "Link" to associate saved reels or links.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.textTertiary, fontSize: 13, height: 1.5),
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        ...linkedResources.map(
                          (resource) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0x201C1C24),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0x28FFFFFF), width: 0.7),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.appleIndigo.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            resource.source == 'instagram'
                                                ? CupertinoIcons.camera_fill
                                                : resource.source == 'youtube'
                                                    ? CupertinoIcons.play_arrow_solid
                                                    : resource.source == 'tiktok'
                                                        ? CupertinoIcons.music_note
                                                        : CupertinoIcons.link,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              resource.title.isNotEmpty ? resource.title : resource.url,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13,
                                              ),
                                            ),
                                            if (resource.source.isNotEmpty)
                                              Text(
                                                resource.source,
                                                style: const TextStyle(
                                                  color: AppColors.textTertiary,
                                                  fontSize: 11,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => ref.read(placesProvider.notifier)
                                            .unlinkResource(place.id, resource.id),
                                        child: const Icon(
                                          CupertinoIcons.xmark_circle,
                                          color: AppColors.textTertiary,
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLinkResourceSheet(BuildContext context, PlaceModel place) {
    final allResources = ref.read(resourcesProvider);
    final notLinked = allResources
        .where((r) => !place.linkedResourceIds.contains(r.id))
        .toList();

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 400,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0x55FFFFFF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Link a Reel or Link',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: notLinked.isEmpty
                  ? const Center(
                      child: Text(
                        'All saved content already linked',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: notLinked.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final r = notLinked[i];
                        return CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            ref.read(placesProvider.notifier)
                                .linkResource(place.id, r.id);
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0x22FFFFFF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0x28FFFFFF), width: 0.7),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  r.source == 'instagram'
                                      ? CupertinoIcons.camera_fill
                                      : r.source == 'youtube'
                                          ? CupertinoIcons.play_arrow_solid
                                          : CupertinoIcons.link,
                                  color: AppColors.appleLime,
                                  size: 19,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    r.title.isNotEmpty ? r.title : r.url,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const Icon(CupertinoIcons.plus_circle, color: AppColors.appleBlue, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color color;

  const _InfoPill({this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
