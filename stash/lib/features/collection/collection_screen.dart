import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/collection.dart';
import '../../core/models/resource.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../add/add_resource_sheet.dart';

class CollectionScreen extends ConsumerWidget {
  final CollectionModel collection;

  const CollectionScreen({super.key, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(resourcesProvider.select(
      (all) => all.where((r) => r.collectionId == collection.id).toList(),
    ));

    const gradients = AppColors.collectionGradients;
    final gradient = gradients[collection.colorIndex % gradients.length];

    return GlassScaffold(
      background: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: AppColors.bg),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    gradient.first.withValues(alpha: 0.30),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      statusBarStyle: GlassStatusBarStyle.light,
      appBar: GlassAppBar(
        leading: GlassButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          width: 40,
          height: 40,
          iconSize: 20,
          onTap: () => Navigator.pop(context),
        ),
        title: Text(
          collection.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          GlassButton(
            icon: const Icon(CupertinoIcons.add_circled, color: AppColors.appleBlue),
            width: 40,
            height: 40,
            iconSize: 22,
            onTap: () => showCupertinoModalPopup(
              context: context,
              builder: (_) => AddResourceSheet(preselectedCollectionId: collection.id),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: gradient.first.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: gradient.first.withValues(alpha: 0.5), width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: gradient.first.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.folder_fill,
                        size: 28,
                        color: gradient.first,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    collection.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                  if (collection.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      collection.description,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (resources.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.folder_fill,
                        size: 54, color: gradient.first.withValues(alpha: 0.6)),
                    const SizedBox(height: 12),
                    const Text(
                      'No resources saved yet',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Share Instagram, YouTube reels or doc links',
                      style: TextStyle(
                          color: AppColors.textTertiary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _ResourceTile(resource: resources[i]),
                  childCount: resources.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _ResourceTile extends ConsumerWidget {
  final ResourceModel resource;

  const _ResourceTile({required this.resource});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer.card(
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
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: resource.thumbnailUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: resource.thumbnailUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _sourceBox(),
                        )
                      : _sourceBox(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.title.isNotEmpty
                            ? resource.title
                            : resource.url,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        resource.notes.isNotEmpty
                            ? resource.notes
                            : resource.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                      if (resource.locationName != null &&
                          resource.locationName!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(CupertinoIcons.location_solid,
                                size: 12, color: AppColors.appleGreen),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                resource.locationName!,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.appleGreen,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    resource.isFavorite
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.heart,
                    color: resource.isFavorite
                        ? AppColors.applePink
                        : AppColors.textTertiary,
                    size: 20,
                  ),
                  onPressed: () => ref
                      .read(resourcesProvider.notifier)
                      .toggleFavorite(resource.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sourceBox() {
    return Container(
      width: 64,
      height: 64,
      color: const Color(0x381C1C28),
      child: Center(
        child: Icon(resource.sourceVectorIcon,
            size: 26, color: AppColors.appleLime),
      ),
    );
  }
}
