import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/resource.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/liquid_glass.dart';

class RecentItemsRow extends StatelessWidget {
  final List<ResourceModel> resources;

  const RecentItemsRow({super.key, required this.resources});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 125,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: resources.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final res = resources[i];
          return LiquidGlass(
            borderRadius: 20,
            blur: 18,
            onTap: () async {
              final uri = Uri.tryParse(res.url);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            child: SizedBox(
              width: 170,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: res.thumbnailUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: res.thumbnailUrl,
                            height: 75,
                            width: 170,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _placeholder(res),
                          )
                        : _placeholder(res),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      children: [
                        Icon(res.sourceVectorIcon, size: 12, color: AppColors.appleLime),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            res.title.isNotEmpty ? res.title : res.url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _placeholder(ResourceModel res) {
    return Container(
      height: 75,
      width: 170,
      color: const Color(0x331C1C28),
      child: Center(
        child: Icon(res.sourceVectorIcon, size: 26, color: AppColors.appleLime),
      ),
    );
  }
}
