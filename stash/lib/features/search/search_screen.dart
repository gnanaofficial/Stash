import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/resource.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/glass_components.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _sourceFilter = 'all';
  String _stateFilter = 'all';
  String? _selectedTag;

  final _sources = ['all', 'instagram', 'youtube', 'github', 'pdf', 'web'];
  final _states = ['all', 'needs_review', 'organized'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ResourceModel> _filterResults(List<ResourceModel> all) {
    var list = all;
    if (_query.trim().isNotEmpty) {
      final tokens = _query.toLowerCase().trim().split(RegExp(r'\s+'));
      list = list.where((r) {
        final searchable =
            '${r.title} ${r.description} ${r.url} ${r.notes} ${r.locationName ?? ''} ${r.tags.join(' ')}'
                .toLowerCase();
        return tokens.every((token) => searchable.contains(token));
      }).toList();
    }
    if (_sourceFilter != 'all') {
      list = list
          .where((r) => r.source.toLowerCase() == _sourceFilter.toLowerCase())
          .toList();
    }
    if (_stateFilter != 'all') {
      list = list.where((r) => r.processingState == _stateFilter).toList();
    }
    if (_selectedTag != null) {
      list = list.where((r) => r.tags.contains(_selectedTag)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final allResources = ref.watch(resourcesProvider);
    final results = _filterResults(allResources);

    final allTags = <String>{};
    for (final r in allResources) {
      allTags.addAll(r.tags);
    }
    final sortedTags = allTags.toList()..sort();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -1.0,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.appleBlue.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.appleBlue.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '${results.length} found',
                        style: const TextStyle(
                          color: AppColors.appleBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── GlassSearchBar ────────────────────────────────
                GlassSearchBar(
                  controller: _searchController,
                  placeholder: 'Titles, links, tags, or notes...',
                  onChanged: (val) => setState(() => _query = val),
                ),
                const SizedBox(height: 12),

                // ── Source filter chips ───────────────────────────
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _sources.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final src = _sources[i];
                      final isSel = src == _sourceFilter;
                      return GlassChip(
                        label: src.toUpperCase(),
                        selected: isSel,
                        onTap: () => setState(() => _sourceFilter = src),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // ── State filter chips ────────────────────────────
                SizedBox(
                  height: 30,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _states.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final state = _states[i];
                      final isSel = state == _stateFilter;
                      final label = state == 'all'
                          ? 'All States'
                          : state == 'needs_review'
                              ? 'Needs Review'
                              : 'Organized';
                      final labelIcon = state == 'needs_review'
                          ? CupertinoIcons.exclamationmark_triangle
                          : state == 'organized'
                              ? CupertinoIcons.checkmark_circle
                              : null;
                      return GlassChip(
                        label: label,
                        selected: isSel,
                        icon: labelIcon != null ? Icon(labelIcon, size: 12) : null,
                        onTap: () => setState(() => _stateFilter = state),
                      );
                    },
                  ),
                ),

                // ── Tag chips ─────────────────────────────────────
                if (sortedTags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 30,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: sortedTags.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (_, i) {
                        final tag = sortedTags[i];
                        final isSel = _selectedTag == tag;
                        return GlassChip(
                          label: '#$tag',
                          selected: isSel,
                          onTap: () => setState(() {
                            _selectedTag = isSel ? null : tag;
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Results ───────────────────────────────────────────────
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.search,
                            size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: 12),
                        const Text(
                          'No matching items found',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Try a different keyword or filter',
                          style: TextStyle(
                              color: AppColors.textTertiary, fontSize: 13),
                        ),
                        if (_sourceFilter != 'all' ||
                            _selectedTag != null ||
                            _query.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          GlassButton.custom(
                            height: 38,
                            shape: const LiquidRoundedRectangle(borderRadius: 12),
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                _query = '';
                                _sourceFilter = 'all';
                                _stateFilter = 'all';
                                _selectedTag = null;
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Reset Filters',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
                    physics: const BouncingScrollPhysics(),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _SearchResultTile(resource: results[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final ResourceModel resource;
  const _SearchResultTile({required this.resource});

  @override
  Widget build(BuildContext context) {
    return GlassContainer.card(
      quality: GlassQuality.standard,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () async {
          final uri = Uri.tryParse(resource.url);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail or source box
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: resource.thumbnailUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: resource.thumbnailUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _sourceBox(),
                        )
                      : _sourceBox(),
                ),
              ),
              const SizedBox(width: 12),
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
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      resource.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                    if (resource.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        resource.notes,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (resource.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: resource.tags.take(3).map((t) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0x22FFFFFF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#$t',
                              style: const TextStyle(
                                  color: AppColors.textTertiary, fontSize: 10),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(resource.sourceVectorIcon,
                      size: 17, color: AppColors.appleLime),
                  const SizedBox(height: 5),
                  ProcessingStateBadge(state: resource.processingState),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sourceBox() {
    return Container(
      color: const Color(0x381C1C28),
      child: Center(
        child: Icon(resource.sourceVectorIcon,
            size: 22, color: AppColors.appleLime),
      ),
    );
  }
}
