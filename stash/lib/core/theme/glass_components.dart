import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Reusable Standard Frosted Glass Container (manual BackdropFilter version)
/// Named StashGlassContainer to avoid name clash with liquid_glass_widgets.GlassContainer.
class StashGlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final Color? tintColor;
  final Border? border;
  final VoidCallback? onTap;

  const StashGlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 22.0,
    this.padding,
    this.blur = 24.0,
    this.tintColor,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tintColor ?? const Color(0x331C1C26),
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ??
                Border.all(
                  color: const Color(0x38FFFFFF),
                  width: 0.8,
                ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        pressedOpacity: 0.75,
        child: content,
      );
    }
    return content;
  }
}

/// Standardized iOS 26 Glass Card (manual variant)
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
    this.borderRadius = 22.0,
  });

  @override
  Widget build(BuildContext context) {
    return StashGlassContainer(
      borderRadius: borderRadius,
      padding: padding,
      onTap: onTap,
      tintColor: const Color(0x38181824),
      border: Border.all(
        color: const Color(0x28FFFFFF),
        width: 0.8,
      ),
      child: child,
    );
  }
}

/// Frosted Glass Search Field (manual variant — prefer GlassSearchBar from liquid_glass_widgets)
class GlassSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const GlassSearchField({
    super.key,
    this.controller,
    this.placeholder = 'Search...',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      controller: controller,
      placeholder: placeholder,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      placeholderStyle:
          const TextStyle(color: AppColors.textTertiary, fontSize: 14),
      itemColor: AppColors.textTertiary,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x331C1C28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x28FFFFFF), width: 0.8),
      ),
      onChanged: onChanged,
    );
  }
}

/// Visual Platform Badge (Instagram, YouTube, GitHub, Web)
class PlatformBadge extends StatelessWidget {
  final String source;

  const PlatformBadge({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    final lower = source.toLowerCase();
    Color badgeColor = AppColors.appleBlue;
    IconData icon = CupertinoIcons.link;
    String label = 'WEB';

    if (lower.contains('instagram')) {
      badgeColor = AppColors.applePink;
      icon = CupertinoIcons.camera_fill;
      label = 'REEL';
    } else if (lower.contains('youtube')) {
      badgeColor = const Color(0xFFFF3B30);
      icon = CupertinoIcons.play_arrow_solid;
      label = 'YOUTUBE';
    } else if (lower.contains('github')) {
      badgeColor = AppColors.applePurple;
      icon = CupertinoIcons.chevron_left_slash_chevron_right;
      label = 'GITHUB';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: badgeColor.withValues(alpha: 0.35), width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Standardized Thumbnail Preview with fallback icon
class ThumbnailPreview extends StatelessWidget {
  final String imageUrl;
  final String sourceIcon;
  final IconData? sourceVectorIcon;
  final double width;
  final double height;
  final double borderRadius;

  const ThumbnailPreview({
    super.key,
    required this.imageUrl,
    this.sourceIcon = '',
    this.sourceVectorIcon,
    this.width = 60,
    this.height = 60,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _fallback(),
            )
          : _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: const Color(0x381C1C28),
      child: Center(
        child: sourceVectorIcon != null
            ? Icon(sourceVectorIcon, size: width * 0.45, color: AppColors.appleLime)
            : const Icon(CupertinoIcons.link, size: 24, color: AppColors.appleLime),
      ),
    );
  }
}

/// Processing State Badge for Smart Inbox
class ProcessingStateBadge extends StatelessWidget {
  final String state; // 'pending', 'processing', 'needs_review', 'organized'

  const ProcessingStateBadge({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.appleBlue;
    String text = 'ORGANIZED';

    switch (state) {
      case 'pending':
        color = AppColors.appleOrange;
        text = 'PENDING';
        break;
      case 'processing':
        color = AppColors.appleBlue;
        text = 'PROCESSING';
        break;
      case 'needs_review':
        color = AppColors.applePink;
        text = 'NEEDS REVIEW';
        break;
      case 'organized':
        color = AppColors.appleGreen;
        text = 'ORGANIZED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 0.6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Standardized Empty State (vector-icon version, no emoji)
class GlassEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const GlassEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: AppColors.textTertiary),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 18),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
