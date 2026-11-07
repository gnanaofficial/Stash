import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/resource.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/glass_components.dart';
import '../add/add_resource_sheet.dart';

class SmartInboxScreen extends ConsumerStatefulWidget {
  const SmartInboxScreen({super.key});

  @override
  ConsumerState<SmartInboxScreen> createState() => _SmartInboxScreenState();
}

class _SmartInboxScreenState extends ConsumerState<SmartInboxScreen> {
  String _selectedFilter = 'all'; // 'all', 'needs_review', 'pending'

  @override
  Widget build(BuildContext context) {
    final allResources = ref.watch(resourcesProvider);
    final collections = ref.watch(collectionsProvider);

    final inboxItems = allResources.where((r) {
      if (_selectedFilter == 'needs_review') return r.notes.isEmpty || r.tags.isEmpty;
      if (_selectedFilter == 'pending') return r.title.isEmpty || r.title == r.url;
      return true;
    }).toList();

    return GlassScaffold(
      background: Container(color: AppColors.bg),
      statusBarStyle: GlassStatusBarStyle.light,
      appBar: GlassAppBar(
        leading: GlassButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          width: 40,
          height: 40,
          iconSize: 20,
          onTap: () => Navigator.pop(context),
        ),
        title: const Text(
          'Smart Inbox',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          GlassButton(
          icon: const Icon(CupertinoIcons.plus_circle, color: AppColors.appleBlue),
          width: 40,
          height: 40,
          iconSize: 22,
          onTap: () => showCupertinoModalPopup(
            context: context,
            builder: (_) => const AddResourceSheet(),
          ),
        ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filter chips ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _filterChip('all', 'All (${allResources.length})'),
                const SizedBox(width: 8),
                _filterChip('needs_review', 'Needs Review'),
                const SizedBox(width: 8),
                _filterChip('pending', 'Untagged'),
              ],
            ),
          ),

          // ── List ──────────────────────────────────────────────
          Expanded(
            child: inboxItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.sparkles,
                            size: 54, color: AppColors.appleLime),
                        SizedBox(height: 14),
                        Text(
                          'Inbox Zero',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'All items are organized into collections!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.textTertiary, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    physics: const BouncingScrollPhysics(),
                    itemCount: inboxItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final item = inboxItems[i];
                      final state = (item.notes.isEmpty && item.tags.isEmpty)
                          ? 'needs_review'
                          : 'organized';

                      final col = collections.isNotEmpty
                          ? collections.firstWhere(
                              (c) => c.id == item.collectionId,
                              orElse: () => collections.first,
                            )
                          : null;

                      return GlassContainer.card(
                        quality: GlassQuality.standard,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            final uri = Uri.tryParse(item.url);
                            if (uri != null && await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ThumbnailPreview(
                                  imageUrl: item.thumbnailUrl,
                                  sourceIcon: item.sourceIcon,
                                  width: 62,
                                  height: 62,
                                  borderRadius: 14,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          PlatformBadge(source: item.source),
                                          const SizedBox(width: 6),
                                          ProcessingStateBadge(state: state),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.title.isNotEmpty
                                            ? item.title
                                            : item.url,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const Icon(CupertinoIcons.folder_fill,
                                              size: 12, color: AppColors.appleLime),
                                          const SizedBox(width: 5),
                                          if (col != null)
                                            Text(
                                              col.name,
                                              style: const TextStyle(
                                                color: AppColors.textTertiary,
                                                fontSize: 11,
                                              ),
                                            ),
                                          if (item.locationName != null &&
                                              item.locationName!.isNotEmpty) ...[
                                            const SizedBox(width: 6),
                                            const Text('•',
                                                style: TextStyle(
                                                    color: AppColors.textTertiary)),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                item.locationName!,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: AppColors.appleGreen,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                CupertinoButton(
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(CupertinoIcons.ellipsis,
                                      color: AppColors.textTertiary, size: 18),
                                  onPressed: () =>
                                      _showQuickTriage(context, item),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String id, String label) {
    final isSelected = _selectedFilter == id;
    return GlassChip(
      label: label,
      selected: isSelected,
      onTap: () => setState(() => _selectedFilter = id),
    );
  }

  void _showQuickTriage(BuildContext context, ResourceModel item) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(item.title.isNotEmpty ? item.title : item.url),
        message: const Text('Triage and organize this item'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(resourcesProvider.notifier).toggleFavorite(item.id);
            },
            child:
                Text(item.isFavorite ? 'Remove Favorite' : 'Mark as Favorite'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(resourcesProvider.notifier).deleteResource(item.id);
            },
            child: const Text('Delete from Vault'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(ctx),
        ),
      ),
    );
  }
}
