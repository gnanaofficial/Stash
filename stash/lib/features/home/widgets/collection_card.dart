import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/models/collection.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/liquid_glass.dart';

class CollectionCard extends StatelessWidget {
  final CollectionModel collection;
  final int resourceCount;
  final VoidCallback onTap;

  const CollectionCard({
    super.key,
    required this.collection,
    required this.resourceCount,
    required this.onTap,
  });

  IconData _getIcon() {
    final name = collection.name.toLowerCase();
    final id = collection.id.toLowerCase();
    if (name.contains('git') || name.contains('dev') || name.contains('code') || id.contains('github')) {
      return CupertinoIcons.chevron_left_slash_chevron_right;
    }
    if (name.contains('food') || name.contains('spot') || name.contains('place') || name.contains('cafe')) {
      return CupertinoIcons.compass_fill;
    }
    if (name.contains('design') || name.contains('ui') || name.contains('inspo') || name.contains('art')) {
      return CupertinoIcons.sparkles;
    }
    if (name.contains('learn') || name.contains('doc') || name.contains('tutorial') || name.contains('book')) {
      return CupertinoIcons.doc_text_fill;
    }
    return CupertinoIcons.folder_fill;
  }

  Color _getAccentColor() {
    switch (collection.colorIndex % 5) {
      case 0:
        return AppColors.appleLime;
      case 1:
        return AppColors.appleOrange;
      case 2:
        return AppColors.applePurple;
      case 3:
        return AppColors.appleTeal;
      case 4:
      default:
        return AppColors.appleGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _getAccentColor();
    final icon = _getIcon();

    return LiquidGlass(
      borderRadius: 22,
      blur: 24,
      onTap: onTap,
      tintColor: const Color(0x3314141E),
      border: Border.all(
        color: accent.withValues(alpha: 0.35),
        width: 1.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: 0.16),
              const Color(0x1014141E),
            ],
          ),
        ),
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Folder silhouette icon + count pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Frosted glowing icon container
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.45),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: accent,
                      size: 19,
                    ),
                  ),
                ),
                // Item counter pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0x28FFFFFF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0x38FFFFFF),
                      width: 0.6,
                    ),
                  ),
                  child: Text(
                    '$resourceCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Bottom Info: Title & Subtitle with overflow safety
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  collection.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  collection.description.isNotEmpty
                      ? collection.description
                      : 'Vault collection',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
