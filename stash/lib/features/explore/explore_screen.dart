import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../core/models/place.dart';
import '../../core/providers/places_provider.dart';
import '../../core/theme/app_theme.dart';
import 'place_detail_screen.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _selectedCategory = 'All';
  String _selectedPrice = 'All';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final _categories = ['All', 'Food', 'Cafe', 'Shopping', 'Experience', 'Hotel'];
  final Map<String, IconData> _categoryIcons = {
    'All': CupertinoIcons.globe,
    'Food': CupertinoIcons.heart_circle_fill,
    'Cafe': Icons.local_cafe,
    'Shopping': CupertinoIcons.bag_fill,
    'Experience': CupertinoIcons.sparkles,
    'Hotel': CupertinoIcons.bed_double_fill,
  };
  final _prices = ['All', '\$', '\$\$', '\$\$\$'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PlaceModel> _filtered(List<PlaceModel> all) {
    return all.where((p) {
      final matchCat = _selectedCategory == 'All' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchPrice = _selectedPrice == 'All' || p.priceLevel == _selectedPrice;
      final matchSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.address.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchPrice && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final places = ref.watch(placesProvider);
    final filtered = _filtered(places);
    final saved = places.where((p) => p.isSaved).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Header ───────────────────────────────────────────────
        SliverSafeArea(
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Explore',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -1.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.appleGreen.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.appleGreen.withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.appleGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Bengaluru',
                              style: TextStyle(
                                color: AppColors.appleGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── GlassSearchBar ────────────────────────────
                  GlassSearchBar(
                    controller: _searchController,
                    placeholder: 'Search places, areas...',
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                  const SizedBox(height: 14),

                  // ── Category chips ────────────────────────────
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final cat = _categories[i];
                        final isSelected = _selectedCategory == cat;
                        return GlassChip(
                          label: cat,
                          selected: isSelected,
                          icon: Icon(_categoryIcons[cat], size: 13),
                          onTap: () =>
                              setState(() => _selectedCategory = cat),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Price chips ───────────────────────────────
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _prices.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final price = _prices[i];
                        final isSelected = _selectedPrice == price;
                        return GlassChip(
                          label: price,
                          selected: isSelected,
                          onTap: () =>
                              setState(() => _selectedPrice = price),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Section header ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
            child: Text(
              filtered.isEmpty
                  ? 'No places found'
                  : 'Discover (${filtered.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),

        // ── Places grid ───────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.78,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => _PlaceCard(place: filtered[i]),
              childCount: filtered.length,
            ),
          ),
        ),

        // ── Saved Places ──────────────────────────────────────────
        if (saved.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: Row(
                children: [
                  Icon(CupertinoIcons.heart_fill,
                      color: AppColors.applePink, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'My Saved Places',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SavedPlaceTile(place: saved[i]),
                ),
                childCount: saved.length,
              ),
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

class _PlaceCard extends ConsumerWidget {
  final PlaceModel place;
  const _PlaceCard({required this.place});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer.card(
      quality: GlassQuality.standard,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (_) => PlaceDetailScreen(placeId: place.id)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    place.imageUrl.isNotEmpty
                        ? Image.network(
                            place.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholderBox(),
                          )
                        : _placeholderBox(),
                    // Save badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => ref
                            .read(placesProvider.notifier)
                            .toggleSaved(place.id),
                        child: GlassButton(
                          icon: Icon(
                            place.isSaved
                                ? CupertinoIcons.heart_fill
                                : CupertinoIcons.heart,
                            color: place.isSaved
                                ? AppColors.applePink
                                : Colors.white,
                            size: 15,
                          ),
                          width: 32,
                          height: 32,
                          iconSize: 15,
                          onTap: () => ref
                              .read(placesProvider.notifier)
                              .toggleSaved(place.id),
                        ),
                      ),
                    ),
                    // Visited badge
                    if (place.isVisited)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.appleGreen.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.checkmark_circle_fill,
                                  size: 10, color: Colors.white),
                              SizedBox(width: 3),
                              Text(
                                'Visited',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.star_fill,
                          size: 11, color: AppColors.appleOrange),
                      const SizedBox(width: 3),
                      Text(
                        place.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        place.priceLevel,
                        style: const TextStyle(
                          color: AppColors.appleGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderBox() {
    return Container(
      color: const Color(0xFF1C2230),
      child: Center(
        child: Icon(place.categoryVectorIcon,
            size: 34, color: AppColors.appleLime),
      ),
    );
  }
}

class _SavedPlaceTile extends ConsumerWidget {
  final PlaceModel place;
  const _SavedPlaceTile({required this.place});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer.card(
      quality: GlassQuality.standard,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (_) => PlaceDetailScreen(placeId: place.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: place.imageUrl.isNotEmpty
                      ? Image.network(place.imageUrl, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF1C2230),
                            child: Center(
                              child: Icon(place.categoryVectorIcon,
                                  size: 24, color: AppColors.appleLime),
                            ),
                          ))
                      : Container(
                          color: const Color(0xFF1C2230),
                          child: Center(
                            child: Icon(place.categoryVectorIcon,
                                size: 24, color: AppColors.appleLime),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      place.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.star_fill,
                            size: 11, color: AppColors.appleOrange),
                        const SizedBox(width: 3),
                        Text(
                          place.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          place.priceLevel,
                          style: const TextStyle(
                              color: AppColors.appleGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                        if (place.isVisited) ...[
                          const SizedBox(width: 8),
                          const Icon(CupertinoIcons.checkmark_circle_fill,
                              size: 11, color: AppColors.appleGreen),
                          const SizedBox(width: 3),
                          const Text('Visited',
                              style: TextStyle(
                                  color: AppColors.appleGreen,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(CupertinoIcons.chevron_right,
                  color: AppColors.textTertiary, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
